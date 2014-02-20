require '../spec_helper'

describe "Khan.Utilities", ->

  describe '.tick', ->
    beforeEach ->
      @tick = ->
        Khan.Utilities.tick 100, (i)->
          if @tick
            @tick = false
            'tick'
          else
            @tick = true
            'tock'

    describe "#tick", ->
      it 'the function is available for execution until the time expires', ->
        u = @tick()
        expect(u.tick()).toBe 'tock'
        expect(u.tick()).toBe 'tick'

        waitsFor ->
          u.tick() == null

    describe "#tock", ->
      it 'calls the given callback with the specified duration', ->
        tick = Khan.Utilities.tick 100, (duration) ->
          duration
        expect(tick.tock()).toBe 100


  describe '.step', ->
    beforeEach ->
      @step = ->
        Khan.Utilities.step 3, (step)->
          step

    describe '#tick', ->
      it 'the function executes step number of times', ->
        u = @step()
        expect(u.tick()).toBe 1
        expect(u.tick()).toBe 2
        expect(u.tick()).toBe 3
        expect(u.tick()).toBe null

    describe '#tock', ->
      it 'calls the callback with the steps', ->
        step = Khan.Utilities.step 100, (steps) ->
          steps
        expect(step.tock()).toBe 100

  describe '.stretch', ->
    beforeEach ->
      @stretch = ->
        Khan.Utilities.stretch 2, 100, (step, elapsed)->
          [step, elapsed]

    describe '#tick', ->
      it 'takes a known amount of time to complete a known amount of steps', ->
        u = @stretch()

        waitsFor ->
          [step, elapsed] = u.tick()
          return true if elapsed >= 33
          expect(step).toBe 0

        waitsFor ->
          [step, elapsed] = u.tick()
          return true if elapsed >= 66
          expect(step).toBe 1

        waitsFor ->
          return true if u.tick() is null
          [step, elapsed] = u.tick()
          expect(step).toBe 2

    describe '#tock', ->
      it 'calls the callback with the total steps and last duration', ->
        stretch = Khan.Utilities.stretch 2, 100, (step, elapsed)->
          [step, elapsed]
        expect(stretch.tock()).toEqual [2, 100]


  describe '.loop', ->
    describe 'without bounce', ->
      beforeEach ->
        @loop = ->
          Khan.Utilities.loop 3, (step) ->
            step

      describe '#tick', ->
        it 'counts to loop and starts over', ->
          u = @loop()
          expect(u.tick()).toBe 1
          expect(u.tick()).toBe 2
          expect(u.tick()).toBe 3
          expect(u.tick()).toBe 1

      describe '#tock', ->
        it 'returns number of steps', ->
          u = @loop()
          expect(u.tock()).toBe 3

    describe 'with bounce', ->
      beforeEach ->
        @loop = ->
          Khan.Utilities.loop 3, true, (step) ->
            step

      describe '#tick', ->
        it 'counts to loop and starts over', ->
          u = @loop()
          expect(u.tick()).toBe 1
          expect(u.tick()).toBe 2
          expect(u.tick()).toBe 3
          expect(u.tick()).toBe 2
          expect(u.tick()).toBe 1
          expect(u.tick()).toBe 2
