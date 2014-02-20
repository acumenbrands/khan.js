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
