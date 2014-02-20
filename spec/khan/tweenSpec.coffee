require '../spec_helper'

describe "Khan.Tween", ->
  beforeEach ->
    @tween = Khan.Tween

  describe "#constructor", ->
    it 'sets a default ease property of linear', ->
      expect(new @tween().ease).toBe Khan.Ease.linear

    it 'sets other ease properties', ->
      expect(new @tween('prop', 1, 5, 'quintout').ease).toBe(
        Khan.Ease.quintout
      )

    it 'can lock tween destinations', ->
      tween = new @tween('prop', 1, 3, 'linear', updatable: false)
      tween.end = 5
      expect(tween.end).toBe(3)

  describe "#tween", ->
    it 'returns an object to be used for animating', ->
      spyOn(Khan.Utilities, 'tick').andCallThrough()

      t = new @tween('opacity', 0, 1).tween(3)
      expect(Khan.Utilities.tick).toHaveBeenCalledWith(3, jasmine.any(Function))
      expect(t.tick).not.toBeNull()
