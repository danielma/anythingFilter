$ = jQuery

class AnythingFilter

  constructor: (@element, @settings) ->
    @element = $(@element)
    @validateSettings()
    @setup()
    @createClearButton()
    @bind()

  validateSettings: ->
    throw 'elements cannot be empty' unless @settings.elements?
    @elements = $(@settings.elements)
    
    throw 'content cannot be empty' if !@settings.content? or @settings.content.trim() == ''
    @settings.contentText = true if @settings.content == 'text'
    @settings.content = @settings.content.toLowerCase()

  setup: ->
    @element.data 'anythingfilter', this
    @filter = @filterFactory()

  createClearButton: ->
    @clearButton = $('<a href="#" class="clear-button" tabindex="-1">✕</a>')
                   .appendTo @element.parent()

  bind: -> 
    @element.on 'keyup', =>
      @value = @element.val().toLowerCase()

      if @value.trim() == ''
        @clearButton.hide()
        @elements.show()
        return

      @clearButton.show()

      passed = $()
      failed = $()
      for e in @elements
        if @filter(e) then passed = passed.add e else failed = failed.add e

      passed.show()
      failed.hide()

    @clearButton.on 'click', @reset

  reset: =>
    @elements.show()
    @element.val ''
    @clearButton.hide()
    false

  filterFactory: ->
    if @settings.contentText
      @filterByText
    else
      @filterByAttribute 

  filterByText: (element) ->
    $(element).text().toLowerCase().indexOf(@value) > -1

  filterByAttribute: (element) ->
    if @settings.child?
      element = $(element).find(@settings.child)
    else
      element = $(element)
    element.attr(@settings.content).toLowerCase().indexOf(@value) > -1

$.fn.anythingFilter = (options) ->
  if typeof(options) == 'string'
    args = [].splice.call(arguments, 0)
    $(this).data('anythingfilter')[options].apply($(this).data('anythingfilter'), args.splice(1, args.length))
    return
  
  settings = $.extend {}, $.fn.anythingFilter.defaults, options

  for element in this
    new AnythingFilter(element, settings)

  this

$.fn.anythingFilter.defaults =
  elements: null
  content:  'text'
  child:    false

$(document).on(
  'focus.anythingfilter.data-api click.anythingfilter.data-api', 
  '[data-provide="anythingfilter"]',
  (e) ->
    $this = $(this)
    return if $this.data 'anythingfilter'

    settings = {}
    for setting of $.fn.anythingFilter.defaults
      value = @getAttribute("data-anythingfilter-#{setting}")
      settings[setting] = value if value?
    $this.anythingFilter(settings)
)