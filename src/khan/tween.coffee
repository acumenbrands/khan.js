# Setup a tweenable property.
#
# Moves the value of 'property' from 'start' to 'end' using the named ease
# function.
#
# Tweens can be set to be mutable by passing the "configurable" and "writable"
# options to the constructor - this allows you to change the destination of a
# tween (say the X coordiate of a translation) after the tweening has begun.
#
# the 'tween' property itself actually returns a generator-like function that
# is called repeatedly from the animation controllers
class Khan.Tween
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

# A subclass of tween that uses the "stretch" generator to always take a given
# number of frames to arrive at it's destination value.
class Khan.Frames extends Khan.Tween
  constructor: (@property, @start, @end, ease = 'linear') ->
    super @property, @start, @end, ease

    if @start == @end
      @steps = 1
    else
      @steps = Math.abs(@start - @end)

  tween: (duration) ->
    Khan.Utilities.stretch @steps, duration, (i) =>
      Math.round(@ease(i, @start, @end - @start, @steps))

# A subclass of tween that uses the "step" generator to take a given start and end
# point and animate in X number of step between them.
class Khan.Range extends Khan.Tween
  constructor:(@property, @start, @end, @steps) ->
    super @property, @start, @end
    @diff = Math.abs(@start - @end) + 1
    @direction = 1

    unless @steps?
      if @start == @end
        @steps = 1
      else
        @steps = @diff

    if(@start > @end)
      @direction = -1
    else if (@start == @end)
      @direction = 0

  tween: () ->
    Khan.Utilities.step @steps, (i) =>
      if @steps > @diff
        i = i * @diff / @steps
      if @steps == 1
        return @end

      Math.round((@start + i * @direction))

# A subclass of tween that loops between the start and end points forever
class Khan.Loop
  constructor: (@property, @steps, @bounce = false) ->

  tween: () ->
    Khan.Utilities.loop @steps, @bounce, (i) =>
      i
