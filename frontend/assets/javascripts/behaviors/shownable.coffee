stik.behavior "js-shownable", (tpl) ->
  button = tpl.find "[data-shownable='button']"
  target = tpl.find "[data-shownable='target']"

  button.click -> target.toggle()
