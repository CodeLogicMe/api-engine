TYPES = ['string', 'integer', 'datetime']
VALIDATIONS = ['presence', 'size']

Handlebars.registerHelper 'select_type', ->
  options = for type in TYPES
    if @type is type
      "<option value='#{type}' selected>#{type}</option>"
    else
      "<option value='#{type}'>#{type}</option>"

  new Handlebars.SafeString(
    "<select name='type'>#{options.join('')}</select>"
  )

Handlebars.registerHelper 'validations', ->
  options = for val in VALIDATIONS
    if @validations is undefined or @validations.indexOf(val) is -1
      "<input type='checkbox' name='validations' value='#{val}' />"
    else
      "<input type='checkbox' name='validations' value='#{val}' checked/>"

  new Handlebars.SafeString options.join('')

stik.boundary
  as: 'buildView'
  from: 'controller'
  to: (options = {}) =>
    source = $(options.name).html()
    template = Handlebars.compile source

    render: (data) ->
      options.at.append template data

stik.boundary
  as: 'deepCopy'
  from: 'controller'
  to: (obj) ->
    $.extend true, {}, obj

stik.boundary
  as: 'appConfig'
  from: 'controller'
  resolvable: true
  cacheable: true
  to: (deepCopy) ->
    deepCopy window.appConfig

stik.controller 'AppBuilder', (ctrl) ->
  ctrl.action 'List', (tpl, $courier, appConfig, buildView) ->
    resourceListTemplate = buildView name: '#resource-list', at: tpl

    renderTheWorld = (config) ->
      tpl.html ''
      console.log resourceListTemplate.render config

    tpl.on 'click', '.item', (event) ->
      entities = appConfig.entities.filter (entity) ->
        entity.name is $(event.target).text().trim()
      $courier.send 'config:selected', entities[0]

    $courier.receive 'config:selected', ->
      tpl.hide()
    $courier.receive 'config:unselected', ->
      tpl.show()

    renderTheWorld appConfig

  ctrl.action 'Constructor', (tpl, $courier, buildView) ->
    constructorTemplate = buildView name: '#constructor', at: tpl

    renderTheWorld = (resource) =>
      tpl.html ''
      constructorTemplate.render resource
      tpl.show()
      setupEventHandlers()

    setupEventHandlers = ->
      tpl.find('.back-to-list').click ->
        tpl.hide()
        $courier.send 'config:unselected'

    $courier.receive 'config:selected', renderTheWorld

  ctrl.action 'Preview', (tpl, $courier, buildView, appConfig) ->
    viewTemplate = buildView name: '#resource-preview', at: tpl

    renderTheWorld = (config) =>
      tpl.html ''
      for entity in appConfig.entities
        viewTemplate.render entity
      #stik.lazyBind()

    $courier.receive 'config:changed', renderTheWorld

    renderTheWorld appConfig

  ctrl.action 'ResourcePreview', (tpl, $courier, appConfig) ->
    console.log tpl
    nameTag = tpl.find '.title'
    name = nameTag.text().trim()

    nameTag.click ->
      entity = appConfig.entities.find (entity) ->
        entity.name is name
      $courier.send 'config:selected', entity

    $courier.receive 'config:unselected', ->
      tpl.removeClass 'selected'

    $courier.receive 'config:selected', (entity) ->
      tpl.toggleClass 'selected', (entity.name is name)
