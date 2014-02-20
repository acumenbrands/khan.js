Khan = 
  Deferred: jQuery.Deferred

window?.Khan = Khan

class Khan.Controller
  # Called with a duration, and a list of Tween objects describing the effect.
  #
  # A diagonal translation for example involves both the leftoffset and the
  # topoffset of an element, so tweens for both of those properties would need
  # to be provided to this constructor.
  #
  # The controller returns a promise with a progress callback and a done
  # callback.  The code for actually DOING the drawing should be in the promise
  # object progress callback.  Because it's not guaranteed that the animation
  # will end on exactly the last frame available, the "done" callback on the
  # animation promise should render the desired end state.
  #
  # @params [Integer] duration the duration (in ms) of the animation (pass -1 for infinite length)
  # @params [Array] tweens any number of tween objects to be animated
  #
  constructor: (@duration, tweens...) ->
    properties = _.map tweens, (t) -> t.property
    @tweens = _.object(properties, tweens)

  @requestAnimationFrame:
    window.requestAnimationFrame       ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame    ||
    window.msRequestAnimationFrame     ||
    window.oRequestAnimationFrame      ||
    (callback)->
      setTimeout(callback, 10)

  # Update the destination of the animations tweens.
  #
  # @param options - An object describing the new destinations of the tweens
  #
  # @example
  #   animation.update({left: '200', opacity: '100'})
  #
  update: (options) ->
    for key, value of options
      @tweens[key]?.end = value

  # Deletes the animations deferred object and resets all the tweens to their
  # initial state. Any promises set on the animation wil be lost.
  #
  reset: ->
    delete @_deferred
    delete @_ticks

  # Stop the animation at it's current location, and fire the done hook
  #
  stop: ->
    @deferred().resolve()

  # Retrieve the animation's promise.
  #
  # The promise will fire both progress events and a done event when the
  # animation completes.
  #
  # @returns Promise
  #
  promise: ->
    @deferred().promise()

  # The #animate function is recursive. It will call requestAnimationFrame
  # with itself as a parameter, bound to the context of this Khan instance.
  # When there are no longer any 'tick' frames left in the tweened animations
  # then the tween animation will be called one last time and the deferred
  # will be resolved.
  #
  # It will notify the animation's promise object of the results of running the
  # tick funciton of every tween.  It give you an object of the form of:
  #
  # {
  #    'tween1property': value,
  #    'tween2property': value
  # }
  #
  # @returns this
  #
  animate: ->
    results = @tick_all()

    if _.keys(results).length > 0
      @deferred().notify results
      Khan.Controller.requestAnimationFrame.call(window, @animate.bind(@))
    else
      results = @tock_all()
      @deferred().notify results
      @deferred().resolve results

    @

  ### INTERNAL ###

  deferred: ->
    @_deferred ||= new Khan.Deferred()

  tick_all: ->
    @_build @ticks(), (tick) -> tick.tick()

  tock_all: ->
    @_build @ticks(), (tick) -> tick.tock()

  _build: (obj, callback) ->
    reduced = {}
    for prop, value of obj
      val = callback(value)
      reduced[prop] = val unless val is null
    reduced

  # @internal
  #
  # construct an array of tween generators to be called in the main
  # animation function
  ticks: ->
    return @_ticks if @_ticks

    @_ticks = {}
    for prop, a of @tweens
      @_ticks[prop] = a.tween(@duration)

    @_ticks

class Khan.Ease
  # @t is the current time (or position) of the tween. This can be
  #   seconds or frames, steps, seconds, ms, whatever – as long as
  #   the unit is the same as is used for the total time [3].
  # @b is the beginning value of the property.
  # @c is the change between the beginning and destination value of the property.
  # @d is the total time of the tween.
  #
  # only the t is changed.
  #
  # every last one of these is flat out copied from the penner equations

  @linear: (t, b, c, d)->
    (c * (t / d)) + b

  @circinout: (t, b, c, d)->
    t /= d/2
    if t < 1
      return -c/2 * (Math.sqrt(1 - t*t) - 1) + b

    t -= 2
    c/2 * (Math.sqrt(1 - t*t) + 1) + b

  @quintout: (t, b, c, d) ->
    t /= d
    t--
    c*(t*t*t*t*t + 1) + b

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

class Khan.Utilities
  getTime = ->
    new Date().getTime()

  # Tick can be called as many times as you like for 'duration'
  # milliseconds, and will pass the elapsed time to the provied
  # callback.  After 'duration' has passed, the 'tick' function
  # will return null.
  #
  # You can call the 'tock' function on the finished generators
  # and it will execute the callback with 'duration' as the argument
  # this is useful for finalizing any work you may need to do with
  # the generator
  @tick: (duration, callback)->
    do ->
      start_time = getTime()

      tock: ->
        callback(duration)

      tick: ->
        elapsed  = getTime() - start_time
        return null if elapsed > duration
        callback(elapsed)

  # Step can be called "steps" times, passing the step number
  # to the provided callback.
  #
  # After step has been called 'steps' times, the 'tick' function
  # will return null
  #
  # You can call the 'tock' funciton on the finished generator
  # and it will execute the callback with 'tock' as the argument
  @step: (steps, callback)->
    do ->
      step = 0

      tock: ->
        callback(steps)

      tick: ->
        step += 1
        return null if step > steps
        callback(step)

  # Stretch can be called as many times as you like for 'duration',
  # but will quantize the steps. (ie, only return integers) - This means
  # that if given 60 for the first agument, it will always return integers
  # from 1 to 60 - but may return any (or none) of those integers
  # more than once, depending on how often it is called.
  @stretch: (steps, duration, callback)->
    do ->
      start_time = getTime()
      freq = duration / (steps + 1)
      step = 0

      tock: ->
        callback(steps, duration)

      tick: ->
        elapsed = getTime() - start_time
        step = Math.floor(elapsed / freq)
        return null if step > steps
        callback(step, elapsed)

  # Loop can be called as many times as you like
  # it functions exactly like 'step' but has no limit. If given
  # two parameters it will count "up" until it reacehes the second parameter
  # then back down to 0
  # 
  # The loop is infinite without intervention, and will never return
  # null
  @loop: (steps, bounce, callback)->
    do ->
      if typeof bounce == 'function'
        callback = bounce
        bounce = false

      step = 0

      next = (n)->
        n += 1

      prev = (n)->
        n -= 1

      direction = next

      tock: ->
        callback(steps)

      tick: ->
        if direction == next && step >= steps
          if bounce
            direction = prev
          else
            step = 0

        if direction == prev && step <= 1 
          direction = next

        step = direction(step)
        callback(step)
