---
layout: post
title: Ports in Elm
---
In my [last post about Signals in Elm]({% post_url 2010-07-21-name-of-post %}) I ended with an outlook of a limitation of `StartApp.Simple`: it's not easily usable with Ports. 

So what are Ports, exactly? They are a way to get values from Elm to native JS or from JS to Elm. They are defined in Elm with their own keyword, `port`. If a Port is defined to be of a Non-Signal type (e.g. `port initialUrl : String`) then it is a "one time" send or receive value (at init time of the Elm code), i.e. such ports can be used if you want to send initialization values from JS to Elm at init time (and never afterwards). More frequently it will be a Signal of some type (e.g. a `Signal String`). 

As a simple example, let's create a pair of ports to send `String`s from Elm to Js, do something there like interact with a native library, and then send the `String`s back. One case where something like this might be useful would be to encrypt values using a native library (using one of the new Browser crypto APIs). 

### Outgoing ports

Since we want this to be possible not just once, we need to declare both ports as `Signals`. Let's start with the outgoing port and on the Elm side:

```haskell
port requestEncryption : Signal String
port requestEncryption =
  signalOfEncryptionRequests
```

So far, so straightforward. Somehow we will have to define the actual Signal of Strings called `signalOfEncryptionRequests`, but let's keep that for later. Let's handle the Javascript side of things:

```javascript
var div = document.getElementById('root');
var myapp = Elm.embed(Elm.MyApp, div);
myapp.ports.requestEncryption.subscribe(encryptString);

function encryptString(message) {
    // do something with the string, send it to be encrypted etc
}
```

Since we will probably want to encrypt the string and send it back right away, so lets continue with the Incoming Port, first the modification on the Javascript side: 

```javascript
var div = document.getElementById('root');
var myapp = Elm.embed(Elm.MyApp, div, {encryptionCompleted : ""});
myapp.ports.requestEncryption.subscribe(encryptString);

function encryptString(message) {
    encryptedMessage = "Encypted: " + message; // actually encypting the message is ommited
    myapp.ports.encryptionCompleted.send(encryptedMessage);
}
```

Note that I not only had to modify `encryptString` but also pass in an initial value at the time when we initialize Elm with the call to `Elm.embed`. The third parameter takes the initial value of every incoming Signal we define on the Elm side - it is required because Signals in Elm always need an initial value. Let's add this incoming port on the Elm side to complete the example:

```haskell
port encryptionCompleted : Signal String


```

Note that this time the port we have defined has no "implementation" in Elm. That is because, viewed from Elm, this is just an external input - a Signal we can use to trigger behaviour in our app. But how can we do that? How can we wire up this Signal into our `StartApp.start` call?

The easiest way to get Elm to handle the Signal of incoming values like our port is to change from `StartApp.Simple` to the slightly more complex `StartApp` and use the `inputs` for it. `inputs` is a `List of Signals` that fire `Action`s that will be combined with the Signal of the mailbox. So this is exactly what we want to have for this little program so it can react to the signal that represents the port.


The first obvious change is the added list of inputs to `start`. This is where I feed in a list of `Signals of Actions`. Why not a `Signal of Strings` (which is what the type of the port is)? Because the `update` function that changes the model needs a value of type Action. I added the function `setUrlFromJSSignal` that just maps the port Signal from `Signal of String` to a `Signal of Actions` by applying the `SetURL` type constructor. I changed the `SetURL` action to have a String "payload", so the action `SetURL` always carries the url to set. This means that the `onClick` handler also needs to set the payload when it constructs the `SetURL` action.

The Effects type has also come in and made update a little more complex, because instead of only returning just the new model from `update` we now have to return a tuple of the new model and any Effects we want the runtime to perform (this is for stateful side effects like send http requests etc). I will write more about those in the next post.

To wrap up, I hope that this post helped you understand how Elm uses Signals even if the main two functions you work on in Elm (update and view) don't make this immediately visible as they don't have any Signals in their signature. 

Thanks for reading through this long post! I hope it was useful and I appreciate any feedback you might have!