stik.boundary
  as: 'slugify'
  to: (text) ->
    text
      .toLowerCase()
      .replace(/[^\w ]+/g, '')
      .replace RegExp(' +', 'g'), '-'

stik.controller 'AppConfig', (ctrl) ->
  ctrl.action 'NewEntity', ($template, $courier, $viewBag) ->
    entity = name: '', fields: []

    name = $template.querySelector '[name="entity[name]"]'
    name.addEventListener 'keyup', ->
      entity.name = name.value
      $courier.send 'model:entity:name:changed', entity

    addBtn = $template.querySelector '.add-field'
    addBtn.addEventListener 'click', ->
      entity.fields.push $viewBag.pull()
      $courier.send 'model:entity:fields:changed', entity

    saveBtn = $template.querySelector '.save-entity'
    saveBtn.addEventListener 'click', ->
      $.ajax
        type: 'PUT'
        data: entity: entity

  ctrl.action 'EntityPreview', (tpl, $courier, $viewBag, slugify) ->
    endpoints = tpl.find '.endpoint-preview'
    tables = tpl.find '.endpoint-preview-params tbody'

    toggleEndpoint = (entity) ->
      if entity is undefined or entity.name is ''
        endpoints.hide()
      else
        endpoints.show()

    toggleEndpoint()

    $courier.receive 'model:entity:name:changed', (entity) ->
      toggleEndpoint entity
      $viewBag.push 'entity:name': slugify(entity.name)

    $courier.receive 'model:entity:fields:changed', (entity) ->
      tables.find('tr:not(.default-field)').remove()
      for field in entity.fields
        line = "<tr><td>#{field.name}</td><td>#{field.type}</td></tr>"
        tables.append line

stik.boundary
  as: "appService"
  from: "controller"
  to: (id) ->
    toggleActive: (state) ->
      console.log "toggled app #{id} to #{state}"

stik.controller "AppCtrl", (ctrl) ->
  ctrl.action "Preview", (tpl, $courier) ->
    appId = tpl.data "id"

    $courier.receive "app:#{appId}:state", (state) ->
      tpl.toggleClass "turned-off", !state

  ctrl.action "Enabler", (tpl, $courier, appService) ->
    appId = tpl.data "id"
    btnOn = tpl.find "[data-enabler='on']"
    btnOff = tpl.find "[data-enabler='off']"

    toggleApp = (state) ->
      appService(appId).toggleActive state
      $courier.send "app:#{appId}:state", state

    btnOn.click -> toggleApp true
    btnOff.click -> toggleApp false
