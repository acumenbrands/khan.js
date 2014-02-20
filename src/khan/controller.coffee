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
