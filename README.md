# Khan.js

> In Xanadu did Kubla Khan  
> A stately pleasure-dome decree:  
> Where Alph, the sacred river, ran  
> Through caverns measureless to man  
> &nbsp;&nbsp;&nbsp;&nbsp;Down to a sunless sea.  

Khan is an Object Oriented Javascript library for creating composable, reusable
animations or transitions. It uses Promises rather than callbacks, and leaves it
up to you do the actual work of updating your object.  Khan is written in
CoffeeScript, so the examples here are given in CS, but it's distributed as compiled
JS, so it will work that way too.

Like Coelridges poem, this library is full of promise(s), but leaves a lot
up to your imagination.


## How to Use

Khan animations are collections of Tween objects, which affect a single property.

Create a Tween object using the Tween constructor:

    new Khan.Tween 'property', begin, end, 'ease'

The destination values of `Khan.Tween` objects are normally updatable while the
tween is in progress - if you want to 'lock' a tween to it's initial destination.

    new Khan.Tween 'property', begin, end, 'ease', updatable: false


A tween by itself is not much use - you can composose multiple tweens into a single
animation by subclassing the `Khan.Controller`

    class AnimationEffect extends Khan.Controller
    	constructor: (@params)->
    		super(duration, @tween1(), @tween2())

    	tween1: -> new Khan.Tween 'property1', begin, @params.dest, 'linear'
    	tween2: -> new Khan.Tween 'property2', begin, @params.dest, 'linear'

This will coalesce both of those tweens into a single `Khan.Controller` - if you
have multiple properties that would you like to change over the same amount of time
this is the way to accomplish it.

To actually DO something with an animation, you're going to need to get at the
values it's updating.  Assuming that `animation` here has `Khan.Controller` somewhere
in it's prototype chain:

    animation.promise()
     .progress (result) =>
        # do something with the result
        # result is an object with keys corresponding to all the tweens
        # and values corresponding to their current values
     .done =>
        # cleanup after the animation


    animation.animate()  #begin the animation


There is nothing preventing you from running multiple animations on the same object
at the same time (although you'll need to make separate progress functions for them)
You proooobably want to avoid tweening over the same key in two different controllers
applied to the same object at the same time, as the results will be unpredictable.

To update an animation:

    animation.update
       tween1: new_end_value
       tween2: new_end_value

The animation will continue using it's current ease and beginning value until it
reaches it's new end. Word to the wise - if you change the end value dramatically
near the end of a tween, it may cause the animation to "jump" quite a ways.

In addition to `Khan.Tween` there are two other tween classes - `Khan.Frames` 
which completes it's tween in a given amount of frames (stretched over the 
duration of the animation) and `Khan.Loop` which executes a given amount of frames
over and over.
