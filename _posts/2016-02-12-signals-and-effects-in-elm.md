---
layout: post
title: Signals and Effects in Elm
---
I have rewritten a webapp from React/Redux to [Elm](http://elm-lang.org/) over the last few weeks and am really enjoying the language so far. Elm is a compile to Javascript, purely functional language that was built specifically to create web UIs with it. It is inspired by several functional programming languages, especially Haskell and OCaml. I had several ideas for blog posts on the topic after my recent talk about Elm at [Berlin.js](http://www.berlinjs.org), but then I answered a few questions on the Elm Discuss mailinglist and thought that those questions would make for a better post than any arbitrary examples. This blog post is about Ports and Signals, the next one will be about Tasks and Effects.

These blog posts assume that you already know a little bit about Elm, e.g. you have gone through the [great primer "Road to Elm"](http://www.lambdacat.com/road-to-elm-index/) by Lambdacat and then studied the [Elm Architecture Tutorials](https://github.com/evancz/elm-architecture-tutorial) a little. OTOH, if you already use Tasks and Ports extensively you will find most of this a bit boring :). 

###How do Signals and Ports relate to each other?

Elm uses a very nice unidirectional architecture for the flow of:

```
displayed website ➞ user actions ➞ new application state ➞ displayed website
```

All the code you write in a typical Elm program comes together in just two pure functions: `update` and `view`. Update takes a user action and the previous application state and creates a new application state, and view takes an application state and renders it into a virtual dom representation (that then gets efficiently displayed by batching diffs to the DOM a la React). For more background on unidirectional UIs in general see André Staltz's excellent blog post [Unidirectional User Interface Architectures](http://staltz.com/unidirectional-user-interface-architectures.html)

One of the key concepts in Elm is that of a Signal. A Signal is a value that can change over time. One of the conceptually simplest signals is the current time - every second the signal "fires" with the new time value (seconds passed since epoch or whatever). Another example could be the coordinates of the mouse cursor in the current window. When the mouse is still, no values are fired by the Signal - but whenever the user moves the mouse, new values are sent. (This is actually one of the examples at [elm-lang.org/examples](http://elm-lang.org/examples/mouse-position)). Signals are a bit similar to EventEmmitters or Observables in Javascript - the key difference is that they exist for the entire lifetime of the program and always have an initial value.

Signals don't provide any access to their history - they only provide the current value. But even a simple counter example needs to track the number of clicks that happened so far. Since elm is a pure language with no mutable state, how do you keep track of the current click-count? We'll come back to that question, but first let's look at how StartApp.Simple works that you probably know from the [Elm Architecture Tutorials](https://github.com/evancz/elm-architecture-tutorial).

StartApp hides a bit of wiring from you, but I think it helps to understand how `StartApp.start` actually works. What the `start` function does is hook up a `mailbox` (something where messages go when you send them to the address e.g. in an onClick handler) so that they lead to a new html emmited to main. This is the heart of the unidirectional UI approach. The user clicks a button, this leads to a message being sent to the mailbox. The mailbox has a `Signal` that fires whenever a message is sent to it. This `Signal` is of your applications `Action` type, i.e. it fires `Action` values. Eventually this leads to a full cycle through your `update`/`view` functions and thus to a new version of your Virtual Dom.

Let's look at the intermediary types more closely: we start with a `Signal of Actions`. This then gets turned into a `Signal of Models` (so everytime a new `Action` is fired this action value is run through `update` together with the last model state to get the new model state). This finally gets turned into a `Signal of Html` (whenever the `Signal of Model` fires, we run it through the `view` function to arrive at a new Html to display). This is then handed to `main` so that the Elm runtime can display it for us.

Note that when I wrote about the update function, I said "together with the last model state". This brings us back to our question from above - how can you work with history or state in Elm? The answer is in the function called `Signal.foldp` ("fold from the past"). If you aren't familiar with folds yet, they are another name for reduce functions (as in map/reduce). It logically reduces all the values from the entire history with a given function and returns the value - in our case it uses the inital Model and reduces all Actions that were sent to our program to arrive at a current Model. (the implementation actually just caches the last current value and works from there of course).

At this point, if you want to really dive into it, let's look at how [StartApp.Simple](https://github.com/evancz/start-app) is actually implemented (Feel free to skip this annotated code and read on below for how Ports come into the picture)

```elm
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
    -- the actions signal. This is the central piece.
    -- The update function will process one Action and
    -- the old Model state to the new model State, the 
    -- Signal that triggers it all is the Mailboxes Signal
    -- we set up at the top
    model : Signal model
    model =
      Signal.foldp update config.model actions.signal
  in
    -- Finally, map over with the view function. This 
    -- turns the Signal of models into a Signal of Htmls
    -- that can be rendered
    Signal Html
    Signal.map (config.view address) model
```

The canonical StartApp.Simple is fine for simple cases, but with it you can't easily create long-running, effectful operations (like sending http requests), and it provides no straightforward way to communicate with "native Javascript", that is, code not written in Elm. I will write about long running operations in another blog post, but let's look at the mechanism Elm uses to communicate with native Javascript: Ports.

So what are ports, exactly? They are a way to get values from Elm to native JS (this is an outgoing Port and on the native JS side this is handled by subscribing to it with a JS callback function) or from JS to Elm (this is an incoming Port and is used from the JS side as a function to call to send a value). They are defined in Elm with their own keyword, `port`. If a Port is defined to be of a Non-Signal type (e.g. `port initialUrl : String`) then it is a "one time" send or receive value (at init time of the Elm code), i.e. such ports can be used if you want to send initialization values from JS to Elm at init time (and never afterwards). More frequently it will be a Signal of some type (e.g. a `Signal String`). 

The starting point for this post was a question about this [simple example](https://gist.github.com/danyx23/27be1e9a9b387d9a7532) that should interact with native Javascript code but didn't. 

Why does this code not work? You may notice that there is nowhere in the Elm code where the getURL signal is actually used. If it is not used in the Elm code, how can Elm react to it?

The easiest way to get Elm to handle the Signal of incoming values is to change from `StartApp.Simple` to the slightly more complex `StartApp` and use the `inputs` for it. `inputs` is a `List of Signals` that fire `Action`s that will be combined with the Signal of the mailbox. So this is exactly what we want to have for this little program so it can react to the signal that represents the port.

To make it clearer what needs to change, here is a modified, [working version of the above code](https://gist.github.com/danyx23/23ab6572e7292e66e5ae). One of the first things I did was add type annotations everywhere, because in my experience this helps you think about a piece of code when you are stuck. Let's look at the other changes in detail:

The first obvious change is the added list of inputs to `start`. This is where I feed in a list of `Signals of Actions`. Why not a `Signal of Strings` (which is what the type of the port is)? Because the `update` function that changes the model needs a value of type Action. I added the function `setUrlFromJSSignal` that just maps the port Signal from `Signal of String` to a `Signal of Actions` by applying the `SetURL` type constructor. I changed the `SetURL` action to have a String "payload", so the action `SetURL` always carries the url to set. This means that the `onClick` handler also needs to set the payload when it constructs the `SetURL` action.

The Effects type has also come in and made update a little more complex, because instead of only returning just the new model from `update` we now have to return a tuple of the new model and any Effects we want the runtime to perform (this is for stateful side effects like send http requests etc). I will write more about those in the next post.

To wrap up, I hope that this post helped you understand how Elm uses Signals even if the main two functions you work on in Elm (update and view) don't make this immediately visible as they don't have any Signals in their signature. 

Thanks for reading through this long post! I hope it was useful and I appreciate any feedback you might have.