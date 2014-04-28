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
      it 'the function is available for execution until the time expires', (done)->
        u = @tick()
        expect(u.tick()).to.equal 'tock'
        expect(u.tick()).to.equal 'tick'

        wait 1000, done, ->
          u.tick() == null

    describe "#tock", ->
      it 'calls the given callback with the specified duration', ->
        tick = Khan.Utilities.tick 100, (duration) ->
          duration
        expect(tick.tock()).to.equal 100


  describe '.step', ->
    beforeEach ->
      @step = ->
        Khan.Utilities.step 3, (step)->
          step

    describe '#tick', ->
      it 'the function executes step number of times', ->
        u = @step()
        expect(u.tick()).to.equal 1
        expect(u.tick()).to.equal 2
        expect(u.tick()).to.equal 3
        expect(u.tick()).to.equal null

    describe '#tock', ->
      it 'calls the callback with the steps', ->
        step = Khan.Utilities.step 100, (steps) ->
          steps
        expect(step.tock()).to.equal 100

  describe '.stretch', ->

    beforeEach ->
      @clock = sinon.useFakeTimers()

      @stretch = ->
        Khan.Utilities.stretch 2, 100, (step, elapsed)->
          step

    describe '#tick', ->
      it 'takes a known amount of time to complete a known amount of steps', ->
        u = @stretch()

        expect(u.tick()).to.equal 0

        @clock.tick(34)

        expect(u.tick()).to.equal 1

        @clock.tick(34)

        expect(u.tick()).to.equal 2


    afterEach ->
      @clock.restore()


    describe '#tock', ->
      it 'calls the callback with the total steps and last duration', ->
        stretch = Khan.Utilities.stretch 2, 100, (step, elapsed)->
          [step, elapsed]
        expect(stretch.tock()).to.eql [2, 100]


  describe '.loop', ->
    describe 'without bounce', ->
      beforeEach ->
        @loop = ->
          Khan.Utilities.loop 3, (step) ->
            step

      describe '#tick', ->
        it 'counts to loop and starts over', ->
          u = @loop()
          expect(u.tick()).to.equal 1
          expect(u.tick()).to.equal 2
          expect(u.tick()).to.equal 3
          expect(u.tick()).to.equal 1

      describe '#tock', ->
        it 'returns number of steps', ->
          u = @loop()
          expect(u.tock()).to.equal 3

    describe 'with bounce', ->
      beforeEach ->
        @loop = ->
          Khan.Utilities.loop 3, true, (step) ->
            step

      describe '#tick', ->
        it 'counts to loop and starts over', ->
          u = @loop()
          expect(u.tick()).to.equal 1
          expect(u.tick()).to.equal 2
          expect(u.tick()).to.equal 3
          expect(u.tick()).to.equal 2
          expect(u.tick()).to.equal 1
          expect(u.tick()).to.equal 2
