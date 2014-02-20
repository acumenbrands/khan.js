require '../spec_helper'

describe "Khan", ->
  describe "#animate", ->
    it "calls tick multiple times over the duration", ->
      opacity_animation = new Khan.Controller 100,
        new Khan.Tween 'opacity', 0, 100

      start_opacity = 0
      current_opacity = 0
      opacity_animation.promise().progress (props)->
        current_opacity = props.opacity
        expect(current_opacity).toBeGreaterThanOrEqualTo(start_opacity)

      opacity_animation.animate()

      waitsFor ->
        current_opacity == 100
      , 'animation complete', 150

    it 'animates multiple properities', ->
      opacity_tween = new Khan.Tween 'opacity', 0, 100
      scale_tween   = new Khan.Tween 'scale', 50, 125
      animation = new Khan.Controller 100, opacity_tween, scale_tween

      animation.promise().progress (props)->
        expect(props.opacity).toBeDefined()
        expect(props.scale).toBeDefined()

      animation.animate()

    it 'tweens can belong to multiple animations at once', ->
      opacity_tween = new Khan.Tween 'opacity', 0, 100
      opacity_animation_no1 = new Khan.Controller 100, opacity_tween
      opacity_animation_no2 = new Khan.Controller 200, opacity_tween

      opacity_no1 = 0
      opacity_no2 = 1

      opacity_no1_complete = false
      opacity_no2_complete = false

      # the only time these two controllers should return the same
      # values should be at the very beginning and at the very end, so
      # excepting those two we can just check that they never return
      # the same thing to verify that the KhanController is recieveing
      # a unique generator, and that tweens are operating on distinct timelines
      opacity_animation_no1.promise().progress (props)->
        if 0 < props.opacity < 100
          expect(props.opacity).toNotEqual opacity_no2
          opacity_no1 = props.opacity

      opacity_animation_no2.promise().progress (props)->
        if 0 < props.opacity < 100
          expect(props.opacity).toNotEqual opacity_no1
          opacity_no2 = props.opacity


      opacity_animation_no1.animate().promise().done ->
        opacity_no1_complete = true

      opacity_animation_no2.animate().promise().done ->
        opacity_no2_complete = true


      waitsFor ->
        opacity_no1_complete && opacity_no2_complete
      , 'animation complete', 250

  describe '#update', ->

    it 'can accepts updates for in progress animations', ->
      tween = new Khan.Tween 'opacity', 0, 50
      animation = new Khan.Controller 100, tween

      animation_done = false
      animation.update({ opacity: 100 })

      animation.animate().promise().done (props)->
        animation_done = true
        expect(props.opacity).toEqual 100

      waitsFor ->
        animation_done == true
      , 'animation complete', 150
