require '../spec_helper'

describe "Khan.Ease", ->
  describe '.linear', ->
    it 'produces linear math', ->
      linear = Khan.Ease.linear
      expect(linear(0, 50, 1, 150)).toBe 50

  describe '.circinout', ->
    beforeEach ->
      @cir = Khan.Ease.circinout

    it 'does really complicated stuff', ->
      expect(@cir(2, 50, 100, 6)).toBe 62.7322003750035

    it 'does other complicated stuff with a lower duration', ->
      expect(@cir(2, 50, 100, 4)).toBe 100

  describe 'quintout', ->
    it 'quints the out', ->
      quint = Khan.Ease.quintout

      expect(quint(2, 50, 100, 4)).toBe 146.875
