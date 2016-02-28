---
layout: post
title: Ports in Elm
---
This is the third post in a series of posts about [Elm](http://elm-lang.org/). In my [first post about Signals in Elm]({% post_url 2016-02-12-signals-in-elm %}) I briefly mentioned ports. Since they are the only way to communicate with "native" Javascript, they certainly warrant a closer look.

So what are Ports, exactly? They are basically a way to send messages from Elm to native JS or from JS to Elm. They are defined in Elm with their own keyword, `port`. If a Port is defined to be of a Non-Signal type (e.g. `port initialUrl : String`) then it is a "one time" message (at init time of the Elm code), i.e. such ports can be used if you want to send initialization values from JS to Elm at init time (and never afterwards). More frequently it will be a `Signal` of some type (e.g. a `Signal String`). Ports can not send and receive values of any type but only a subset - the big two groups of values that can't be used are functions and union types (Maybe is the only exception to this rule). All the details can be found on the [elm guide page on interop](http://elm-lang.org/guide/interop).

As a simple example, let's create a pair of ports to send `String`s from Elm to Js, do something with it in native JS, and then send the `String`s back. One case where something like this might be useful would be to encrypt values using a native library (using one of the new Browser crypto APIs). 

### Outgoing ports

Since we want to send stuff several times, not just once, we need to declare both ports as `Signals`. Let's start with the outgoing port and on the Elm side:

```haskell
port requestEncryption : Signal String
port requestEncryption =
  -- how do we get a Signal here for the implementation?
```

This is a simple outgoing port definition, but somehow we have to implement this port - we need a way to get a Signal that we can "trigger" in our elm app and that will be received on the JS side. Let's see how the JS side will look like before coming back to Elm:

```javascript
var div = document.getElementById('root');
var myapp = Elm.embed(Elm.MyApp, div);
myapp.ports.requestEncryption.subscribe(encryptString);

function encryptString(message) {
    // do something with the string, send it to be encrypted etc
}
```

Pretty straigthforward. We use the `subscribe` method to register a callback that will be called with the `message` string value every time the Signal fires at the Elm side. Ok, but how do we finish implementing this on the Elm side?

There are two ways to do this - one is to create a new `Mailbox` and use `Effects` to send our messages, the other is to create a custom version of `StartApp` that returns an additional value for things to send to the port in `update`. I have implemented both attempts as gists, here is the [one with the Mailbox](https://gist.github.com/danyx23/e42ceedaccf0c4a556b8) and once with a [modified StartApp](https://gist.github.com/danyx23/6004778b9322dc716373). For the rest of the blogpost I will refer to the first version since it works with the vanilla StartApp. Ok, let's hook up the Mailbox:

```haskell
portRequestEncryptionMailbox : Mailbox String
portRequestEncryptionMailbox =
  mailbox ""

port requestEncryption : Signal String
port requestEncryption =
  portRequestEncryptionMailbox.signal
```

This initalizes the `Mailbox` and fills in the hole we had before - the Signal we use as a port will just be the `Signal` of our new `Mailbox`. But how do we actually send anything to this Mailbox? By creating an Effect, like so:

```haskell
sendStringToBeEncrypted : String -> Effects Action
sendStringToBeEncrypted clearText =
  Signal.send portRequestEncryptionMailbox.address clearText
  |> Effects.task
  |> Effects.map (\_ -> Noop)

-- and this is our update function that now returns a tuple of (Model, Effect):
update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of 
    TextChanged text -> 
      ( { model | clearText = text }
      , sendStringToBeEncrypted text -- create the Effect here
      )
    -- other cases ...
```

The last line in `sendStringToBeEncrypted` may be a bit confusing - what are we mapping there? Let's take a look at the type of `Mailbox.send`:

```haskell
send : Address a -> a -> Task x ()
```

This means that the `success` type of the task we get back from send is `()` (aka Unit) which acts a bit similar to `void` in C like languages, i.e. it represents "no actual value". Let me desugar `sendStringToBeEncrypted` so it is clearer what types we are working with:

```haskell
sendStringToBeEncrypted : String -> Effects Action
sendStringToBeEncrypted clearText =
  sendTask : Task x ()
  sendTask = Signal.send portRequestEncryptionMailbox.address clearText

  effectOfUnit : Effects ()
  effectOfUnit = Effects.task sendTask

  effectOfAction : Effects Action
  effectOfAction = Effects.map (\_ -> Noop)
```

(Note that instead of first converting to `Effects ()` and then mapping that I could also have mapped the `Task x ()` to `Task x Action` and then converted the Task to Effects). This may still seem a bit weird but it may help to realize that in this particular case of sending a message to a mailbox we are explicitly not interested in an actual `Action` value. We are only interested in performing the side effect of sending the message and it will not have a reasonable "payload" that should be routed through update. But because of how `Effects` are typed in `StartApp`, we do need to have an `Effects Action` in the end and so we introduce a `Noop` value that explicitly does nothing when it is processed in `update`.

Ok great, this is the outgoing part of the ports - how about handling stuff that comes into our Elm program?

### Incoming Ports

Let's start on the Javascript side. We will define an incoming port called `encryptionCompleted` on the Elm side, and here we see how to send messages to it from JS. (Note that this example simplifies the logic a little and immediately after receiving a message from the outgoing port it sends an encrypted value back to Elm via the incoming port - in practice encryptString would probably call an API that returns a promise and only when this is fullfilled call `send` to send a value back to Elm) 

```javascript
var div = document.getElementById('root');
var myapp = Elm.embed(Elm.MyApp, div, {encryptionCompleted : ""});
myapp.ports.requestEncryption.subscribe(encryptString);

function encryptString(message) {
    encryptedMessage = "Encypted: " + message; // actually encypting the message is ommited
    myapp.ports.encryptionCompleted.send(encryptedMessage);
}
```

Note that I not only had to modify `encryptString` but also pass in an initial value at the time when we initialize Elm with the call to `Elm.embed`. The third parameter takes the initial value of every incoming Signal we define on the Elm side - it is required because `Signals` in Elm always need an initial value. Let's add this incoming port on the Elm side to complete the example:

```haskell
port encryptionCompleted : Signal String

```

Note that this time the port we have defined has no "implementation" in Elm. That is because, viewed from Elm, this is just an external input - a Signal we can use to trigger behaviour in our app. But how can we do that? How can we wire up this Signal into our `StartApp.start` call?

In the last post, when we switched from StartApp.Simple to StartApp, I mentioned `inputs`. `inputs` is a `List of (Signal of Action)`, i.e. Signals that fire `Actions` that will be combined with the Signal of the main mailbox that is administered by StartApp. So this is exactly what we want to have for this little program so it can react to the Signal that represents the port - the only thing that is missing is that we have defined `encryptionCompleted` as a `Signal of String` and we need a `Signal of Action` for inputs. Sounds like we need a map again:

```haskell
encryptedString : Signal Action
encryptedString =
  Signal.map EncryptedValueReceived encryptionCompleted

app =
  StartApp.start 
    { init = (init, Effects.none)
    , view = view
    , update = update
    , inputs = [ encryptedString ]  
    }
```

And voilà! We have a `Signal of Actions` that we can put into the inputs part of start.

So just to recap, let's go through the example again: Whenever the user enters text we process the `TextChanged` value in our `update` function and not only update the model but also create a new `Effects`. This is then returned by `update` and, because we wired the `tasks` part returned by `start` to an outgoing `port`, it is handed to the runtime. This leads, on the native JS side, to a call of `encryptString` (because this is the function we registered with `subscribe`). In it we pretended to do some encryption and then sent the value back with `encryptionCompleted.send` (again, you can send values at any time, it only happens in our example that we send one value back for every value we receive on the JS side). This `send` call leads the `encryptionCompleted` Signal to fire, with the string value we sent from the JS side. This is than `map`ped into an `Action` value, namely `EncryptedValueReceived`, and because this is hooked up to the inputs part of StartApp it triggers the same chain through `update` as any other events. In `update` we then handle processing of this `EncryptedValueReceived` value and the whole exercise is complete.

Thanks for reading through this long post! I hope it was useful and I appreciate any feedback you might have!