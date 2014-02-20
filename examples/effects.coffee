Khan.Effects =
  FadeIn:
    class FadeIn extends Khan.Controller
      constructor: ->
        super(800, @opacity)

      opacity: new Khan.Tween 'opacity', 0, 1

  FadeOut:
    class FadeOut extends Khan.Controller
      constructor: ->
        super(800, @opacity)

      opacity: new Khan.Tween 'opacity', 1, 0


  ZoomIn:
    class ZoomIn extends Khan.Controller
      constructor: (@dimensions, @model) ->
        super(500, @height(), @width(), @topOffset(), @leftOffset())

      height:     ->  new Khan.Tween 'height',     @dimensions.height,  @dimensions.zoomHeight, 'quintout'
      width:      ->  new Khan.Tween 'width',      @dimensions.width,   @dimensions.zoomWidth,  'quintout'
      leftOffset: ->  new Khan.Tween 'leftOffset', @model.leftOffset,   @dimensions.centerX
      topOffset:  ->  new Khan.Tween 'topOffset',  @model.topOffset,    @dimensions.centerY

  ZoomOut:
    class ZoomOut extends Khan.Controller
      constructor: (@dimensions, @model) ->
        super(250, @height(), @width(), @topOffset(), @leftOffset())

      height:     ->  new Khan.Tween 'height',     @model.height,      @dimensions.height,  'quintout', updatable: false
      width:      ->  new Khan.Tween 'width',      @model.width,       @dimensions.width,   'quintout', updatable: false
      leftOffset: ->  new Khan.Tween 'leftOffset', @model.leftOffset,  0, 'linear', updatable: false
      topOffset:  ->  new Khan.Tween 'topOffset',  @model.topOffset,   0, 'linear', updatable: false

  Rotation:
    class Rotation extends Khan.Controller
      constructor: ->
        super(-1, @rotation())

      rotation: -> new Khan.Loop 'rotation', 360
