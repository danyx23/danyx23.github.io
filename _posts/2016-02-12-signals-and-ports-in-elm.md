---
layout: post
title: Signals in Elm
---
I have rewritten a webapp from React/Redux to [Elm](http://elm-lang.org/) over the last few weeks and am really enjoying the language so far. Elm is a compile to Javascript, purely functional language that was built specifically to create web UIs with it. It is inspired by several functional programming languages, especially Haskell and OCaml. I have participated in the Elm google group quite a bit lately and I noticed that even though the Elm docs are really good, there are some concepts that are a bit hard to understand and to differentiate from each other. I am therefore starting a mini-series of posts about different concepts in Elm. This first one is about Signals - and why you don't see them much in many smaller Elm programs even though they are always there.

These blog posts assume that you already know a little bit about Elm, e.g. you have gone through the [great primer "Road to Elm"](http://www.lambdacat.com/road-to-elm-index/) by Lambdacat and then studied the [Elm Architecture Tutorials](https://github.com/evancz/elm-architecture-tutorial) a little. OTOH, if you already use Tasks and Ports extensively you will find most of this a bit boring :). 

### What are Signals?

Elm uses a very nice unidirectional architecture for the flow of:

```
displayed website ➞ user actions ➞ new application state ➞ displayed website
```

All the code you write in a typical Elm program comes together in just two pure functions: `update` and `view`. Update takes a user action and the previous application state and creates a new application state, and view takes an application state and renders it into a virtual dom representation (that then gets efficiently displayed by batching diffs to the DOM a la React). For more background on unidirectional UIs in general see André Staltz's excellent blog post [Unidirectional User Interface Architectures](http://staltz.com/unidirectional-user-interface-architectures.html)

One of the key concepts in Elm is that of a Signal. A Signal is a value that can change over time. One of the conceptually simplest signals is the current time - every second the signal "fires" with the new time value (seconds passed since epoch or whatever). Another example could be the coordinates of the mouse cursor in the current window. When the mouse is still, no values are fired by the Signal - but whenever the user moves the mouse, new values are sent. (This is actually one of the examples at [elm-lang.org/examples](http://elm-lang.org/examples/mouse-position)). Signals are a bit similar to EventEmmitters or Observables in Javascript - the key difference is that they exist for the entire lifetime of the program and always have an initial value.

Signals don't provide any access to their history - they only provide the current value. But even a simple counter example needs to track the number of clicks that happened so far. Since elm is a pure language with no mutable state, how do you keep track of the current click-count? We'll come back to that question, but first let's look at how StartApp.Simple works that you probably know from the [Elm Architecture Tutorials](https://github.com/evancz/elm-architecture-tutorial).

StartApp hides a bit of wiring from you, but I think it helps to understand how `StartApp.start` does its magic. What the `start` function does is hook up a `mailbox` (something where messages go when you send them to the address e.g. in an onClick handler) so that they lead to a new html emmited to main. This is the heart of the unidirectional UI approach. The user clicks a button, this leads to a message being sent to the mailbox. The mailbox has a `Signal` that fires whenever a message is sent to it. This `Signal` is of your applications `Action` type, i.e. it fires `Action` values. Eventually this leads to a full cycle through your `update`/`view` functions and thus to a new version of your Virtual Dom.

Let's look at the intermediary types more closely: we start with a `Signal of Actions`. This then gets turned into a `Signal of Models` (so everytime a new `Action` is fired this action value is run through `update` together with the last model state to get the new model state). This finally gets turned into a `Signal of Html` (whenever the `Signal of Model` fires, we run it through the `view` function to arrive at a new Html to display). This is then handed to `main` so that the Elm runtime can display it for us.

Note that when I wrote about the update function, I said "together with the last model state". This brings us back to our question from above - how can you work with history or state in Elm? The answer is in the function called `Signal.foldp` ("fold from the past"). If you aren't familiar with folds yet, they are another name for reduce functions (as in map/reduce). It logically reduces all the values from the entire history with a given function and returns the value - in our case it uses the inital Model and reduces all Actions that were sent to our program to arrive at a current Model. (the implementation actually just caches the last current value and works from there of course).

At this point, if you want to really dive into it, let's look at how [StartApp.Simple](https://github.com/evancz/start-app) is actually implemented (I added comments and type annotation to every named value)

```haskell
start : Config model action -> Signal Html
start config =
  let
    -- create the main Mailbox. It is of type "Mailbox (Maybe action)" and is
    -- initialized with an "empty" value of Nothing
    actions : Mailbox (Maybe action)
    actions =
      Signal.mailbox Nothing

    -- here the address is set up. Since the Mailbox is of Maybe action, 
    -- everything that is sent to address is "wrapped" in the Just type 
    -- constructor and forwarded to the Mailbox
    address : Address action
    address =
      Signal.forwardTo actions.address Just

    -- This local version of update just wraps config.update to 
    -- take care of the Maybe part of the action that will be
    -- processed (so that the update function the user provides)
    -- can simply operate as Action -> Model -> Model)
    update : Maybe action -> model -> model
    update maybeAction model =
      case maybeAction of
        Just action ->
            config.update action model

        Nothing ->
            Debug.crash "This should never happen."

    -- set up a signal of new models that foldp-s over
    -- the actions signal. This is the central piece
    -- that makes the elm architecture work the way it does.
    -- The update function will process one Action and
    -- the old Model state to the new model State, the 
    -- Signal that triggers it all is the Mailbox' Signal
    -- we set up at the top
    model : Signal model
    model =
      Signal.foldp update config.model actions.signal
  in
    -- Finally, map over it with the view function. This 
    -- turns the Signal of Models into a Signal of Htmls
    -- that can be rendered    
    Signal.map (config.view address) model
```

`StartApp.Simple` is quite clever in how it uses a Signal under the hood but as a user who just wants to write some interactive web app you never need to deal with Signals directly and can just supply `update` and `view`. It all works fine until you need to message back and forth with native javascript. For that, you will need to use Ports, and understanding Signals first will be very helpful for that - more about all of that in the next post!