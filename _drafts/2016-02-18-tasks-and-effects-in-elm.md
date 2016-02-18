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