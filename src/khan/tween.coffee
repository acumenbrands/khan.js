class Khan.Tween
  # Setup a tweenable property. 
  #
  # Moves the value of 'property' from 'start' to 'end' using the named ease
  # function. 
  #
  # Tweens can be set to be mutable by passing the "configurable" and "writable"
  # options to the constructor - this allows you to change the destination of a
  # tween (say the X coordiate of a translation) after the tweening has begun.
  #
  constructor: (property, start, end, ease = 'linear', options={}) ->
    @ease = Khan.Ease[ease]

    @properties['property'] = property
    @properties['start']    = start
    @properties['end']      = end

    @defineProperties(options)

  properties: {}

  defineProperties: (options)->
    for prop, value of @properties
      options.value = value
      Object.defineProperty(@, prop, @defaultValues(options))

  defaultValues: (options={}) ->
    defaults =
      configurable: true
      writable: true
      enumerable: true

    if options['updatable'] == false
      _.extend defaults,
        writable: false
        configurable: false

    _.extend defaults, options

  # Method called by an animation controller to get the next value provided by
  # the tween.
  tween: (duration) ->
    Khan.Utilities.tick duration, (i) =>
      @ease(i, @start, @end - @start, duration)

class Khan.Frames extends Khan.Tween
  # A subclass of tween that uses the "stretch" generator to always take a given
  # number of frames to arrive at it's destination value.
  constructor: (@property, @start, @end, ease = 'linear') ->
    super(@property, @start, @end, ease)
    @steps = Math.abs(@start - @end)

  tween: (duration) ->
    Khan.Utilities.stretch @steps, duration, (i) =>
      Math.ceil(@ease(i, @start, @end - @start, @steps))

class Khan.Loop
  # A subclass of tween that loops between the start and end points forever
  constructor: (@property, @steps, @bounce = false) ->

  tween: () ->
    Khan.Utilities.loop @steps, @bounce, (i) =>
      i