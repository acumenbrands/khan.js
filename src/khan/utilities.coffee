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
