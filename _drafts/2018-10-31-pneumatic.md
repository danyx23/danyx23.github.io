Pneumatic - The Elm Architecture with an observable-based middleware for side-effects

Last weekend I went to Fable conf, a wonderful little conference for Fable, the F# to Javascript compiler. At this conference, Dag Brattli showed his Reaction library that extends the Elmish library (Elm architecture for Fable+React) by injecting an observable (similar to the Reactive Rx library observables) into the message stream that is fed into the update function. 

This alone allows the observable of messages to be modified with the usual observable operators (e.g. use debounce to get some messages at most once a second). In the approach Dag showed, the second part of the update functions return values, the commands, are no longer used and side effects done by wiring up observables that do them (e.g. map a particular message to a side-effectful operation that performs an http request). This works, but I think it can be improved.

Three modifications steps are needed from the current Elmish setup: First of all, we stop constructing side-effects in our update function like we currently do in the Fable-Elmish setup where basically JS promises are created in the update function. Instead we switch to pure data messages for commands that describe what we want to do (just like Elm does). Unlike Elm, these are not system-defined but we entirely control them. I suggest that we use a sum type for these Commands and they enumerate all the possible side effects just like the message type enumerates all possible pure state updates.

Second, we create an observable of commands (not messages), and require the user to give us a createCommandGraph function that maps this observable of commands to an observable of messages. As part of this function we can manipulate the observable with the usual observable operators to debounc etc. Ususally we will want to handle every command value differently, so our createCommandGraph function will filter by type:

// question -> how to handle the transition from commands to messages and make sure that debounce etc

let createCommandGraph commands =
	let fetchConfig =
		commands
		|> filterMap (fun cmd -> 
			match cmd with 
			| FetchConfig fetchData -> Some fetchData
			| _ -> None)
	    |> map (fun fetchData) -> 
	    	ofPromise (fetch fetchData.Url fetchData.SuccessMessageFunction fetchData.FailureMessageFunction)
	    	|> flatMapLatest
	let altert = 
		commands
		|> filterMap (fun cmd ->
			match cmd with
			| Alert msg -> 
			| _ -> None)
		|> debounce 1000
		|> filterMap (fun msg -> 
			Browser.alert msg
			None
			)
	let combinedMessageStream =
		merge [fetchConfig; alert]

	combinedMessageStream

Third, we want to deal with a common problem of observables, namely that the observable graphs we are building here are static - that is, you can not turn on or off observables easily. This often shows in the example for drag and drop if you are mostly interested in the stream of DragMove messages but when constructing this with observables you have to then combine observables for DragStart and DragEnd to turn the DragMove on or off. This adds a significant amount of complexity for a rather simple objective. What we will do instead is that we emit a third piece of data from update, an Option<CommandGraphConfig>. This is fed into the createCommandGraph function and can be whatever the user needs to configure the command graph. Often it may be unit if there are no dynamic changes to the observable graph, but for the drag drop example from above it could be a simple sum type with only two values ObserveDragMove or DontObserveDragMove. The createCommandGraph is then invoked only if a Some values is returned (i.e. most calls to update would yield None for the CommandGraphConfig and only if you do want to change the setup you emit a Some value).

let createCommandGraph config commands =
	match config with
	| ObserveDragMove ->
		ofMouseMove()
		|> ...
	| DontObserveDragMove ->
		observable.Empty()













keypresses w debounce:
let keyboardSpacePressed = 
	Pneumatic.keypresses
	|> debounce 500