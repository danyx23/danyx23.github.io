---
layout: post
title: Tasks and Effects in Elm
excerpt_separator: <!--more-->
---
(Disclaimer: This post was written about Elm 0.16. Signals have since been deprecated. The concepts in this post may still help understand how the Elm Architecture works internally, but the actual code has changed significantly)

This is the second post in a series on some of the concepts in [Elm](http://elm-lang.org/) that might be a bit puzzling when you start out with Elm. In the [last post about Signals in Elm]({% post_url 2016-02-12-signals-in-elm %}) I wrote about Signals and how they are behind the scenes of `StartApp.Simple`. In this post I get into long running operations like XHRs (aka AJAX). There are two closely related types that are involved in this, `Tasks` and `Effects`, and the exact differences between can be confusing in the beginning. So let's dive right in:

<!--more-->

### Tasks

`Task` is the more basic type (it is defined in Core) and so let's start with this one. A Task represents a long-running operation that can fail (with an error type) or succeed (with a success type). It's type is thus:

```elm
Task errorType successType

-- (or, as it is actually written in the library:)

Task x a
```

There are only two values of `Task` you can create yourself in your code, without using a separate library. These two ways are two functions:

```elm
succeed : a -> Task x a

-- and

fail : x -> Task x a
```

These are ways to create task values without actually doing any long-running operations. This can be useful if you want to combine a long running task and a simple value in some way and process them further (you would then turn the simple value into a `Task` with `succeed`).

Most of the time you actually get in contact with tasks, these will be created for you by library functions that initialize the task so that it will perform some long running operation when the runtime executes it and handle the result of the operation according to Task semantics (I.e. that some native code will make sure to call fail or succed on the native representation of the task when the operation is finished).

Note that the operation doesn't start right away! I said "when the runtime executes it". In purely functional programming languages, inside the language you can never just perform a side effect (something that changes "the world" outside the internal state of your code), and sending an http request surely is a side effect in that sense. This is one of the big mental shifts from imperative programming, where you can always do this, to working with purely functional languages where you can't.

So how does this actually work? The task you get back *represents* the long running action. When a library creates it for you, nothing "happens", it just created a value (of type `Task`) that indicates what you would like to happen.

If you look at e.g. the implementation of [the native part of the send function in http](https://github.com/evancz/elm-http/blob/3.0.0/src/Native/Http.js) you will see that a `Task` is created in native JS code by handing it a callback. This callback is what will get called when the runtime actually executes the task. This is when the actual XHR request is created and performed - only when the runtime executes this callback.

So how do you get the runtime to run this task? By passing it into an outgoing `port`. I will go into detail on ports in a later blogpost, but suffice to say that they are a way to send messages between "native" JS and Elm (called an incoming `port`) and from Elm to native JS (an outgoing `port`). The runtime has some special casing for Tasks that come to it via outgoing ports that make it execute the callback the Task represents.

When the long running native code is done, it will either call `succeed` or `fail` on the task. In most real life code that uses the Elm Architecture you will set up a "chain" of task processing that will lead to the the end result of the task execution being that a value of your `Action` type is routed back through your `update` function. This value of your `Action` type is the usually tagged with the result of the task (e.g. the decoded Json response of an XHR).

As a last piece of info before we have a look at Effects and how all of this actually looks in an example, let me just mention that Tasks can easily be chained togehter with `andThen`, much like promises in JS are chained together.

### Effects

On to `Effects`! If you look at the definition for `Effects` it's pretty simple:

```elm
type Effects a
    = Task (Task.Task Never a)
    | Tick (Time -> a)
    | None
    | Batch (List (Effects a))
```

`None` and `Batch` are helpers, so the basic things an Effect can represent are `Tasks` (with error type `Never`) and `Ticks`. The latter is used for animations if you want to do something at the next animation frame.

It's very common to turn a `Task` into an `Effect`, whereas the inverse is usually only ever done by `StartApp`/the runtime.

Several libraries use `Task` to allow you to work with long running operations - `Http` is one, `elm-history` is another.

So how is this used? The [Elm Architecture example 5](https://github.com/evancz/elm-architecture-tutorial#example-5-random-gif-viewer) uses this very central piece of code:

```elm
getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeImageUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task
```

Let's look at what it does. It starts with creating a task that represents the Http `get` operation and then builds a chain on top of this. I will deconstruct this from using the pipe operator to normal function calls with type annotations to hopefully explain what's happening:

```elm
getRandomGif topic =
  getTaskWithError : Task Http.Error String
  getTaskWithError = Http.get decodeImageUrl (randomUrl topic)

  getTaskWithNoErrorAndMaybe : Task Never (Maybe String)
  getTaskWithNoErrorAndMaybe = Task.toMaybe getTaskWithError

  getTaskWithNoErrorAndAction : Task Never (Action)
  getTaskWithNoErrorAndAction = Task.map NewGif getTaskWithNoErrorAndMaybe

  taskAsEffect : Effects Action
  Effects.task getTaskWithNoErrorAndAction
```

So in the end, Effects in this case just wraps the Task for us. Because we used `toMaybe` and then mapped it to the `NewGif` type constructor function, this will result in an `Action` coming back to us via `update` when it is done that is either (`NewGif Nothing`) if the http request failed, or (`NewGif "some-url-here"`) if it succeeds. If you want to understand how this wiring happens I would suggest looking at the [implementation](https://github.com/evancz/elm-effects/blob/master/src/Effects.elm) of Effects.

One thing that is worth looking at is the return type of the function: Effects Action. Effects has a type variable, just like for example List. So this is an Effects that deals with the Action type you define in your application - and this is the really neat part of how to make sure that you can deal with the result of the Task/Effect - the result will just be a value of your Action type!

At this point you may wonder: why have Effects at all? Aren't they just weird wrappers for Tasks? Let's quickly take a look again at how the Task case of the Effects type is defined:

```elm
type Effects a
    = Task (Task.Task Never a)
```

The way `StartApp` is typed, going via `Effects Action` constraints all `Tasks` to come back with `Actions` and have the error type `Never`. This is really nice because it means that you don't have to handle different task types to different ports, but you set up "pipelines" of tasks to effects like with `getRandomGif` above and it will all work out in a typesafe manner that the result of your tasks will be sent back to your program's `update` function as `Actions`.

Ok, so finally, remember I wrote something about having to send Tasks off to an outgoing port. I you don't do this, the Tasks will never be executed! If you want to use Effects, the easiest way is to switch from StartApp.Simple to StartApp. This brings three minor changes with it:

1. `start` no longer directly returns a Signal of Html but a record of 3 Signals: one for the html, one for the model, and, crucially for us, one of tasks.
2. The `update` function now returns not just the `Model`, but a tuple of` (Model, Effects Action)`. I.e. that every case in your update function will have to return both the changed model and an Effect (which will often be `Effects.none`)
3. `start` gets a fourth parameter, `inputs`, for incoming `Signals`.
4. The tasks part of the record that is returned by `start` has to be handed to a port so that the `Tasks/Effects` are actually performed by the runtime like so:

```elm
app =
  StartApp.start
    { init = init "funny cats"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
```

Phew, this got a little long again, but I hope it helps a little to understand how Tasks/Effects work!
