---
layout: post
title: Signals and Effects in Elm
---
I have rewritten a webapp from React/Redux to Elm over the last 4 weeks and am really enjoying the language so far. Elm is a compile to Javascript, purely functional language that was built specifically to create web UIs with it. It is inspired by several functional programming languages, especially Haskell and OCaml. I had several ideas for blog posts on the topic and have just given a talk at [Berlin.js](http://www.berlinjs.org) about it, but then I answered a few questions on the Elm Discuss mailinglist and thought that those questions would make for a good post. (I adapted two long mailing list answers for the post so please excuse some changes in writing style.)

###How do Signals and Ports relate to each other?

Elm uses a very nice unidirectional architecture for the flow of displayed website ➞ user actions ➞ state changes ➞ displayed website. All the code you write in a typical Elm program comes together in just two pure functions: `update` and `view`. Update takes a user action and the previous application state and creates a new application state, and view takes an application state and renders it into a virtual dom representation (that then gets efficiently displayed by batching diffs to the DOM a la React). For more background on unidirectional UIs see André Staltz's excellent blog post [Unidirectional User Interface Architectures](http://staltz.com/unidirectional-user-interface-architectures.html)

One of the key concepts in Elm is that of a Signal. A Signal is value that can change over time. One of the conceptually simplest signals is the current time - every second the signal fires with the new time value (seconds passed since epoch or whatever). Another example could be the coordinates of the mouse cursor in the current window. When the mouse is still, no values are sent by the Signal - but whenever the user moves the mouse, new values are sent. (This is actually one of the examples at [elm-lang.org/examples](http://elm-lang.org/examples/mouse-position)). Signals are a bit similar to EventEmmitters or Observables in Javascript - the key difference is that they exist for the entire lifetime of the program and always have an initial value.

Signals don't provide any access to their history - they only provide the current value. But even a simple counter example needs to track the number of clicks that happened so far. Since elm is a pure language with no mutable state, how do you keep track of the current click-count? We'll come back to that question, but first let's look at how StartApp.Simple works that you probably know from the Elm Architecture Tutorials.

StartApp hides a bit of wiring from you, but I think it helps to understand how `StartApp.start` works. What the `start` function does is hook up a `mailbox` (something where messages go when you send them to the address e.g. in an onClick handler) so that they lead to a new html emmited to main. This is the heart of the unidirectional UI approach. The user clicks a button, this leads to a message being sent to the mailbox. The mailbox has a `Signal` that fires whenever a message is sent to it. This `Signal` is of your applications `Action` type, so the value you get from the signal is of this `Action` type. Eventually this leads to a full cycle through your update/view structure and thus to a new version of your Virtual Dom.

Let's look at the intermediary types more closely, we start with a `Signal of Actions`. This then gets turned into a `Signal of Models` (so everytime a new `Action` is fired this action value is run through `update` together with the last model state to get the new model state). This finally gets turned into a `Signal of Html` (whenever the `Signal of Model` fires, we run it through the `view` function to arrive at a new Html to display). This is then handed to `main` so that the Elm runtime can display it for us.

Note that when I wrote about the update function, I said that "together with the last model state". This brings us back to our question from above - how can you work with history or state in Elm? The answher is in the function called `Signal.foldp` ("fold from the past"). If you aren't familiar with folds yet, they are another name for reduce functions (as in map/reduce). It logically reduces all the values from the entire history with a given function and returns the value - in our case it uses the inital Model and reduces all Actions that were sent to our program to arrive at a current Model. (the implementation actually just caches the last current value and works from there of course).

The canonical [StartApp.Simple](https://github.com/evancz/start-app) that really only uses your update and view function has two big caveats though: you can't easily create long-running, effectful operations (like sending http requests), and it provides no straightforward way to have communication with "native Javascript", that is, code not written in Elm.

This "handing to the runtime" happens for both the main function, and also for all user declared ports (you could say that main is sort of an implicit port).

So what are ports, exactly? They are a way to get values from Elm to native Javascript (outgoing Port) or from Javascript to Elm (incoming Port). They are defined with their own keyword, `port`. If a Port is defined to be of a Non-Signal type (e.g. `port initialUrl : String`) then it is a "one time" send or receive value (at init time of the Elm code). More frequently it will be a Signal of some type (e.g. a `Signal String`) that works somewhat similar to an EventEmitter or Observable in other languages and trigger whenever their value changes (more about them later). So to wrap this up, if you want your native Javascript to fire "events" over to Elm to notify it of something, you need an incoming port in Javascript of the correct type (and with a decoder to verify the incoming data) and if you want the Elm code to signal to your native Javascript you need an outgoing port.

The starting point for this post was a question about this [simple example](https://gist.github.com/danyx23/27be1e9a9b387d9a7532) that should interact with native Javascript code but didn't. 

Why does this code not work? You may notice that there is nowhere in the Elm code where the getURL signal is actually used. If it is not used in the Elm code, how can Elm react to it?

Ok so how do we get the port signal to also trigger cycles through update/view? The easiest way is to change from `StartApp.Simple` to the slightly more complex `StartApp` and use the `inputs` for it. `inputs` is a list of Signals that fire Actions that will be combined with the Signal of the mailbox. So this is exactly what we want to have for this little program so it can react to the signal that represents the port.

To make it clearer what needs to change, here is a modified, [working version of the above code](https://gist.github.com/danyx23/23ab6572e7292e66e5ae). One of the first things I did was add type annotations everywhere, because in my experience this helps you think about a piece of code when you are stuck. Let's look at the other changes in detail:

The first obvious change is the added list of inputs to `start`. This is where I feed in a list of `Signals of Actions`. Why not a `Signal of Strings` (which is what the type of the port is)? Because the update method that changes the model needs a value of type Action. I added the function `setUrlFromJSSignal` that just maps the port Signal from `Signal of String` to a `Signal of Actions` by applying the `SetURL` type constructor. I changed the `SetURL` action to have a String "payload", so the action `SetURL` always carries the url to set. This means that the `onClick` handler also needs to set the payload when it constructs the `SetURL` action.

The Effects type has also come in and made update a little more complex, because instead of only returning the new model we now have to return a tuple of the new model and any Effects we want the runtime to perform (this is for stateful side effects like send http requests etc).

###What is the difference between Tasks and Effects?

Task is the more basic type (it is defined in Core). It represents a long-running operation that can fail (with an error type) or succeed (with a success type). It's type is thus:
Task errorType successType

There are only two values of task you can create yourself in your code, without using a separate library, by using one of the two creation functions:

```haskell
succeed : a -> Task x a
and
fail : x -> Task x a
```

These are ways to create task objects without actually doing any long-running operations. This can be useful if you want to combine a long running task and a simple value in some way and process them further (you would then turn the simple value into a Task with succeed).

Most of the time you actually get in contact with tasks, these will be created for you by library functions and initialize the task so that it will perform some long running operation when the runtime executes it and handle the result of the operation according to Task semantics (I.e. that some native code will make sure to call fail or succed on the native representation of the task when the operation is finished).

Note that the operation doesn't start right away! I said "when the runtime executes it". In purely functional programming languages, inside the language you can never just perform a side effect (something that changes "the world" outside the internal state of your code), and sending an http request surely is a side effect in that sense. This is one of the big mental shifts from imperative programming, where you can always do this, to working with purely functional languages where you can't.

So how does this actually work? The task you get back *represents* the long running action. When a library creates it for you, nothing "happens", it just created a value (of Type Task) that indicates what you would like to happen.

If you look at e.g. the implementation of [the native part of the send function in http](https://github.com/evancz/elm-http/blob/3.0.0/src/Native/Http.js) you will see that a Task is created in native code by handing it a callback. This callback is what will get called when the runtime actually executes the task. This is when the actual XHR request is created and performed - only when the runtime executes this callback.

So how do you get the runtime to run this task? By passing it into an outgoing port. The runtime has some special casing for Tasks that come to it via outgoing ports that make it execute the callback the Task represents.

When the long running native code is done, it will either call succeed or fail on the task which will lead to the further chaining you usually set up to get the result back into your app (by sending a message to an address). (This is a very low-level description, the code below will show what this usually looks like)

Tasks can easily be chained togehter with andThen, much like promises in JS are chained together.


On to Effects! If you look at the definition for Effects its pretty simple (BTW try looking at the code of the elm library if you have trouble understanding something - it usually is surpisingly little code and easy to understand!):

```haskell
type Effects a
    = Task (Task.Task Never a)
    | Tick (Time -> a)
    | None
    | Batch (List (Effects a))
```

None and Batch are helpers, so the basic things an Effect can represent are Tasks (with error type Never) and Ticks. The latter is used for animations if you want to do something at the next animation frame.

It's very common to turn a Task into an Effect, whereas the inverse is usually only ever done by StartApp/the runtime.

Several libraries use Tasks to allow you to work with long running operations - http is one, elm-history is another.

So how is this used? The Elm Architecture example 5 uses this very central piece of code:

```haskell
getRandomGif : String -> Effects Action
getRandomGif topic =
  Http.get decodeImageUrl (randomUrl topic)
    |> Task.toMaybe
    |> Task.map NewGif
    |> Effects.task
```

Let's look at what it does. It starts with creating a task that represents the Http get operation and then builds a chain on top of this. I will deconstruct this from using the pipe operator to normal function calls with type annotations to hopefully explain what's happening:

```haskell
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

So in the end, Effects in this case just wrap the Task for us. Because we used toMaybe and then mapped it to the NewGif type constructor function, this will result in an Action coming back to us via update when it is done that is either (NewGif Nothing) if the http request failed, or (NewGif "some-url-here") if it succeeds. If you want to understand how this wiring happens I would suggest looking at the implementation of Effects.

A final question that may still be in your head is: why have Effects at all? The reason for this is that the way StartApp is typed, going via Effects constraints all Tasks to come back with actions and have the error type Never. This is really nice because it means that you don't have to handle different task types to different ports, but you set up "pipelines" of tasks to effects like getRandomGif above and it will all work out in a typesafe manner that the result of your tasks will be sent back to your program's update function as Actions.

Ok, so finally, if Effects just wrap Tasks with error type Never and your Action type as the success type, then it should be clear that if we only create them but never hand them to the runtime via a port, nothing will ever happen. So after setting up your project with StartApp and creating effects, you have to wire up main like usual, but also create an outgoing port that is wired to app.tasks so that the runtime can actually perform those tasks (represented by the effects) for you.

The reactivity post of the guide is another take on introducing signals and tasks and hopefully between this reply and that post it will be clear how Tasks and Effects and Signals work together to form the backbone of how Elm apps work :)