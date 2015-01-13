describe "Khan.Tween", ->
  beforeEach ->
    @tween = Khan.Tween

  describe "#constructor", ->
    it 'sets a default ease property of linear', ->
      expect(new @tween().ease).to.equal Khan.Ease.linear

    it 'sets other ease properties', ->
      expect(new @tween('prop', 1, 5, 'quintout').ease).to.equal(
        Khan.Ease.quintout
      )

    it 'can lock tween destinations', ->
      tween = new @tween('prop', 1, 3, 'linear', updatable: false)
      tween.end = 5
      expect(tween.end).to.equal(3)

  describe "#tween", ->
    it 'returns an object to be used for animating', ->
      tick_spy = sinon.spy(Khan.Utilities, 'tick')

      t = new @tween('opacity', 0, 1).tween(3)
      sinon.assert.calledWith(tick_spy, 3, sinon.match.func)
      expect(t.tick).to.not.be.null

describe "Khan.Frames", ->
  beforeEach ->
    @frames = Khan.Frames

  describe '#constructor', ->
    it 'sets the steps to 1 if start and end are equal', ->
      r = new @frames('prop', 2, 2)
      expect(r.steps).to.equal 1

    it 'sets the steps to differes if start and end are different', ->
      r = new @frames('prop', 1, 5)
      expect(r.steps).to.equal 4

  describe '#tween', ->
    beforeEach ->
      @clock = sinon.useFakeTimers()

    it 'returns a generator that takes X frames over Y duration', ->
      r = new @frames('prop', 1, 5).tween(20)

      expect(r.tick()).to.equal 1

      @clock.tick(10)

      expect(r.tick()).to.equal 3

      @clock.tick(9)

      expect(r.tick()).to.equal 5

      @clock.tick(1)

      expect(r.tick()).to.equal null

    afterEach ->
      @clock.restore()


describe "Khan.Range", ->
  beforeEach ->
    @range = Khan.Range

  describe '#constructor', ->
    it 'sets the steps explicitly if given', ->
      r = new @range('prop', 1, 5, 2)
      expect(r.steps).to.equal 2

    it 'sets the diff if a distance exists', ->
      r = new @range('prop', 1, 5)
      expect(r.diff).to.equal 5

    it 'sets the diff to one if start and end are the same', ->
      r = new @range('prop', 1, 1)
      expect(r.diff).to.equal 1

    it 'sets the direction to negative if start > end', ->
      r = new @range('prop', 5, 1)
      expect(r.direction).to.equal -1

    it 'sets the direction to postive if start < end', ->
      r = new @range('prop', 1, 5)
      expect(r.direction).to.equal 1

    it 'sets the direction to 0 if start = end', ->
      r = new @range('prop', 1, 1)
      expect(r.direction).to.equal 0

  describe '#tween', ->
    it 'steps from X to Y in Z steps', ->
      r = new @range('prop', 1, 5, 2).tween()
      expect(r.tick()).to.equal 2
      expect(r.tick()).to.equal 3

    context 'when there is one step', ->
      it 'returns the end', ->
        r = new @range('prop', 1, 5, 1).tween()
        expect(r.tick()).to.equal 5

    context 'when the direction is backward', ->
      it 'returns the range in reverse', ->
        r = new @range('prop', 5, 1).tween()
        expect(r.tick()).to.equal 4
        expect(r.tick()).to.equal 3
        expect(r.tick()).to.equal 2
        # expect(you).to.get.the_idea

    context 'when the steps is greater than the range', ->
      it 'returns the same frame multiple times', ->
        r = new @range('prop', 1, 5, 10).tween()
        expect(r.tick()).to.equal 2
        expect(r.tick()).to.equal 2
        expect(r.tick()).to.equal 3
        expect(r.tick()).to.equal 3
        # expect(you).see.the_point
  
describe "Khan.Loop", ->

  describe "#tween", ->
    beforeEach ->
      @loop = Khan.Loop
    
    it 'loops over the given property forver', ->
      l = new @loop('prop', 3).tween()
      expect(l.tick()).to.equal 1
      expect(l.tick()).to.equal 2
      expect(l.tick()).to.equal 3
      expect(l.tick()).to.equal 1
      expect(l.tick()).to.equal 2

    context 'bounce is set', ->
      it 'loops over the given property forever in a bounce', ->
        l = new @loop('prop', 3, true).tween()
        expect(l.tick()).to.equal 1
        expect(l.tick()).to.equal 2
        expect(l.tick()).to.equal 3
        expect(l.tick()).to.equal 2
        expect(l.tick()).to.equal 1
