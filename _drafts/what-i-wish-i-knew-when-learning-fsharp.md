This post is about practical aspects of using the F# programming language. It is heavily inspired by Hillel Wayne's post ["Why Python is my Favorite Language"](https://buttondown.email/hillelwayne/archive/2269df89-b3fc-406f-ac2e-9d7464879ba3) and Stephan Diel's ["What I Wish I Knew When Learning Haskell"](https://dev.stephendiehl.com/hask/). The point of this post is to collect a lot of practical information about working in fsharp that you need to know to work effectively in the language but that are hard to find out about because they fall outside the scope of the language reference etc.. I.e. I will try to answer a lot of random questions like "Which editor plugin should I use?" or "What's the debugging and testing story?".

This will be a living document that I will try to updated regularly. It is also my personal perspective and I may get things wrong or not know about some aspects or misrepresent certain projects - please let me know if you think I should change something.

I'll sacrifice some accuracy on the history of the language, details of the runtime etc for the sake of brevity {% sidenote 'sn-history' 'If you are interested in a detailed history of F# then you will enjoy the document [the early history of the F# language](https://fsharp.org/history/hopl-final/hopl-fsharp.pdf)' %} - I want to get a newcomer started quickly, not write an accurate history of the development of the language.

Ok, with all that out of the way, let's dive in. I'll roughly follow Hillel's list of questions as I think they capture many essential points very well when you look to working with a new language as an outsider.

## Why would I want to use F#?

I like F# and could write a whole blog post just with reasons to use the language, but here are some that I think might hold the most appeal to check it out:

Because it is a well designed general purpose language with nice ergonomics but many powerful features that are missing from other mainstream languages. It has a great type system with sum types (called Discriminated Unions in F#) that are notably missing from many other statically typed programming languages that allow you to much more accurately model data than with objects and simple enums alone. {% sidenote 'sn-sum-types' 'There will be more examples of sum types later, but if you have never encountered them: think of them as enums on steroids because each case can have additional payload that can be different from case to case. When you use such a value you have to pattern match and then tell the compiler what do in each case and there you have the payload available.' %} At the same time, because of full type inference the types do not lead to visual clutter like in C# or Java.

It can leverage the huge .NET ecosystem with libraries for many tasks like e.g. a highly tuned HTTP server implementation.

It is a "functional first" programming language that tries to guide you towards using functions and immutable data structures as your tool of choice. At the same time it is very pragmatic and allows you to write and consume object oriented code or libraries, use mutability etc. (F# is very close to OCaml and shares this approach with it)

The functional first approach and the support for Sum types and de-emphasis of Object Oriented code push you to architectures that IMHO allow for higher code complexity at lower cost and make it easier to deal with change. I say this as someone who has spent 13 years of their professional life as an OO proponent. Instead of worrying about questions of Is-A vs Has-A and the encapsulation of mutable state you work with functions and immutable data that compose and scale much better. This makes it great for writing complex software that can always be refactored and extended quickly.

It has a scripting mode where compilation is done on the fly. This makes it look and feel very similar to python but you still get typechecking and much better performance. Tools like the FAKE build tool use this so the same language you use for writing your solution can also be used to automate building, publishing and deployment.

F# has a very powerful mechanism to create ergonomic workflow DSLs called [Computation Expressions](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/computation-expressions). {% sidenote 'sn-computation-expression' 'Computation Expressions are similar to Haskell's do notation but with interesting additions. In Haskell only bind and apply can be given syntatic do sugar, but in a language like FSharp that has loops etc it makes sense to allow more constructs to be customized in a similar way.' %} If you have every used async/await in another programming language then you have seen a special case of the more general idea of Computation Expressions (i.e. contrary to C#, python etc the async syntactic sugar in F# is not special built for async but F# Computation Expressions let you write the implementation of the async syntactic sugar as normal user code). This enables beautiful code that concentrates on specific problems and extract the wiring (e.g. error handling) into a separate piece of (library) code.

It has a lot of powerful unusual features that are just fun to explore and often very useful - e.g. built in units of measure that work correctly across arithmetic operations and prevent errors that arise from confusing different physical units in code; or type providers that generate types from example data for you at compile time or within the IDE as you type.

It is also one of the few languages that can be used for both the (performant) implementation of server side code and client side Javascript with full access to the Javascript ecosystem. This allows sharing of implementation and types and makes teams much more productive in this common scenario.

## Why would I not want to use F#?

I never trust articles that never mention any down sides - so here are some that I see for F#:

Both the .NET and the Javascript compilation targets (see below for more) are garbage collected. There is some support for memory pinning etc for FFI purposes but in general if you can't afford GC F# is not for you.

If you mainly do machine learning then the library and ecosystem in Python is much more developed than that on .NET.

It has relatively weak metaprogramming capabilities and it doesn't have higher kinded types. This means that there is a ceiling to the abstractions and terse-ness of your code vs something like Haskell - if you know you'll need or want that then Haskell is a better choice.

If you need to hire a large number of engineers in a geographical location in a short period of time. Because F# is a relatively niche language, both the job market and the applicant pool are comparatively small. As with many other functional programming languages though, both the jobs and the applicants you do find are usually very interesting and if you have some time F# is relatively quick to learn if you know a bit of functional programming.

If you work a lot with copy and paste from stackoverflow (I don't want to diss this, there are many people who work on software for whom this is a very legitimate way). The number of examples for "how do I" for something like Python is a lot larger than that for F#; same with learning resources in general, although what exists is often very good - e.g. Scott Wlaschin's [fsharp for fun and profit](https://fsharpforfunandprofit.com/) is one of the best functional programming resources I know across all functional programming languages.

There is also a section below on common gotchas in F# that you may want to consider as possible counter arguments for F# as well.

## Where can I run F#? What are the prerequisites?

FSharp has three main compilation targets: The Windows only .NET Framework that exists since 2001; the modern, cross platform .NET Core Framework (also by Microsoft, sort of replacing Mono on OSX and *nix and being the new incarnation of .NET on Windows as well); and Javascript via the Fable Compiler project, which can then run in the Browser, on Node, on AWS Lambda etc..

The old .NET Framework comes pre-installed with Windows and only runs there. The current version as of early 2020 is 4.8 and versions are occasionally updated with OS updates. The .NET Framework consists of a runtime part (CLR, Common Language Runtime) that includes a VM that runs or JIT compiles Bytecode (much like the JVM in the Java ecosystem), and an optional SDK that includes the C# and F# compiler etc for development.

The new .NET Core Framework is similar and in many parts largely API compatible to the old .NET Framework but was built as a new open source, cross platform implementation of the non-Windows specific parts (i.e. what is missing from .NET Core is Windows GUI support and a few other parts of the standard library that don't make much sense in a cross platform context). You need to install the runtime (CLR, see above) for the system you are running which includes the VM implementation. There are packages available for most major operating systems and processor architectures. Just like above, there is then a separate SDK with the compilers etc.

If you want to target Javascript you need a fork of the main F# compiler called [Fable](https://fable.io/). This is using the same codebase as the official F# compiler that is shipped with the two SDKs above but has an alternative backend for code generation that instead of .NET Bytecode creates a Babel AST that is then serialized to Javascript using Babel. There is a relatively straightforward FFI to tell the F# compiler about functions and "types" of objects in Javascript. Fable comes with a definition of much of the Browser and Node APIs so you can use them directly when writing F# that targets Javascript and a significant part of the .NET Class library has been implemented with Javascript to allow idiomatic F# code to run in this alternate runtime environment (so you can e.g. use `System.Console.WriteLine("Hello")` from the .NET base class system instead of `Fable.Import.Browser.console.log("Hello")`). Fable works surprisingly well overall. There are a few gotchas because the F# compiler is built on the assumption of certain .NET base types (e.g. [different truncation behaviour](https://fable.io/docs/dotnet/numbers.html) for what F# thinks are 32 bit integers as Javascript only has one number type other than the upcoming BigInt) - but it turns out that this is a very powerful and straightforward way of creating Javascript solutions.

## How am I supposed to be writing this?

If you just want to get a quick feel for the language then the [Try F# website](https://try.fsharp.org/) is a good starting point that let's you play with the language in the browser.

To actually work with your own codebases I know of four reasonably comfortable ways to develop F#: [Visual Studio](https://visualstudio.microsoft.com/) (both for Windows and OSX), [Visual Studio Code](https://code.visualstudio.com/) with the [Ionide plugin](https://ionide.io/), [Jetbrains Rider](https://www.jetbrains.com/rider/) and finally the [vim](https://github.com/ionide/Ionide-vim) and [emacs](https://github.com/fsharp/emacs-fsharp-mode) plugins that use the LSP protocol to talk to FsAutocomplete (the same backend that powers Ionide.). Myself and most of my colleages use VS Code with Ionide on Windows or OSX which usually work very well. VS, VS Code and Rider all offer integrated debugging (step through, see values, break on exception etc). There is a repl (`dotnet fsi` when you are on dotnet core 3+) and there is some support for loading files with their dependencies into it or to use libraries in scripts and evaluate parts of that in the interactive repl of your editor. This experience is not as great as with Lisps but works ok (improvements are on the horizon for .NET Core 5 which is scheduled for the fall of 2020 - if you work a lot with REPLs and scripts then it may be worth using the .NET Core 5 preview instead of the current .NET Core 3.1 stable version)

Unless you are familiar with and really want to use the old Visual Studio I would recommend downloading the dotnet core 3 sdk for your platform, getting an editor (e.g. VS Code + Ionide) and then creating a new folder and running `dotnet new console -lang fsharp` to get a scaffold for a console app and start playing with it there (`dotnet run` builds and immediately runs the project).

When using Fable (the F# compiler that outputs Javascript), some things around the standard library and packaging are a bit more involved - more on that later.

Find libraries on [nuget.org](https://www.nuget.org/), use `dotnet add` to add them to your project and use them. Later on add [FAKE](https://fake.build/) for build scripts if you like.

## Packaging

The packaging ecoystem story for both the old .NET Framework and .NET core is to use [Nuget packages](https://www.nuget.org/). These are just zipped archives that contain some metadata and dependency information and then the compiled artifacts called assemblies that contain the library code. Assemblies contain the compiled bytecode to be executed and a lot of metadata on the types so that types can be extended and consumed across language borders between different programming languages (the main ones are C# which is what most stuff is written in, F#, VB.NET, "managed C++" and then some other fringe languages like [Nemerle](http://www.nemerle.org/About)). {% sidenote 'sn-fun-fact' 'Fun fact - they have the file extension .dll and are actually win32 dlls that a windows 95 era tool would at least understand a little bit' %}

The nuget packaging story is flawed in that it doesn't use lock files (although I think this will change soon) and so doesn't fix transitive dependencies. I thus strongly recommend using the alternative [paket package manager](https://fsprojects.github.io/Paket/) for larger projects that lets you use nuget packages in a principled way (and is written in F# 😉).

To find libraries you can search directly on nuget.org. If you google for stuff then it often helps to search in this order for "yourtopic fsharp" "yourtopic c#" or "yourtopic dotnet". Idiomatic F# libraries are often a little nicer to use from F# (e.g. because the use immutable records instead of mutable classes) but you can use any dotnet library from f#. Try to use F# libraries first and otherwise sort by popularity as an inital heuristic when choosing libraries for tasks if multiple libraries exist. If you find F# type providers {% sidenote 'sn-type-providers' '**Type providers**  are a metaprogramming facility that operates sort of like a compiler plugin that looks at sample data to generate types. E.g. there is a type provider for CSV files that takes the path to a csv file alongside your source code which it then at compile time or during the editor session reads and generates a row type from the example csv file without you having to spell out the F# code for the type' %} then they can be worth a try if you want to get somewhere quickly but they may be a maintainance burden in the long run for more complex projects.

Third party libraries don't have a consistent documentation story unfortunately, so you usually go to the project site and follow the project readme to whatever offical documentation the library has. Source code in C# and F# can be annotated with special comments (line comments with three instead of two slashes) that then get compiled into xml files that accompany assemblies - these files are used by editors to show help text on functions and classes on hover in your editor.

Publishing a library is pretty straightforward - `dotnet pack` packs the library into a nuget archive and after creating an account and [setting up the api token](https://docs.microsoft.com/en-us/nuget/nuget-org/publish-a-package), `dotnet publish` will push it to nuget. If you are using the Paket package manager then it gives you a similar command but it will handle dependency ranges in a less manual way. FAKE build scripts can automate building, testing and publishing of libraries. Github actions now comes preinstalled with DotNet Core so you can do all of this using Github Actions easily.

If you need to understand a third party NuGet package (e.g. because the documentation is lacking which for some smaller libraries in F# land can definitely be the case), then you have several options. If the project is open source then the easiest is usually to browse the source code there. Some packages use SourceLink, a way to upload debug symbols for libraries so that users of the library can use them - not all editors can make use of them though. If the source code is not easily available then some editors come with .NET Bytecode decompilers (e.g. Visual Studio and Jetbrains Rider) and there also exist some standalone tools for that though most are Windows only ([AvaloniaSpy](https://github.com/icsharpcode/AvaloniaILSpy) is the main exception I know of). I don't know any tools that decompile to F# so if the library you are decompiling is not open source but authored in F# the resulting decompiled C# will look a bit odd - but that is a rare case since most .NET libraries are written in C#.

## Testing

In Fsharp the preferred library for writing tests is [Expecto](https://github.com/haf/expecto). It allows you to do tons of interesting tests including performance tests between implementations with proper statistical tests. You can add [FSCheck](https://github.com/fscheck/FsCheck) for property based testing, {% sidenote 'sn-property-based-testing' '**Property Based Testing** is a technique to automate test case generation in an intelligent way. Instead of single example testing which is what you do in unit testing, in property based testing you describe statements that you expect to be true (e.g. changing the order of this mathematical operation should not change the result; or serializing and deserializing a value of this type should lead to an identical value) and let the test suite create random values to test your assertions with' %} which I recommend doing - e.g. to test if custom deserializer/serializer pairs lead to values that are identical.

Expecto is usually run by creating a standalone console app from a template {% sidenote 'sn-expecto' '`dotnet new -i Expecto.Template::*` and
`dotnet new expecto -n PROJECT_NAME -o FOLDER_NAME*`' %}. With `dotnet watch run` it can rerun tests on every file change.

## How do I do common stuff? How do I find out how to do things?

The .NET Framework has a pretty extensive standard library that allows you to do a lot of everyday stuff. Much of it was designed around 2000 with primarily the object oriented C# language in mind, so a lot of the standard library that you use (everything in the System. namespace) has a very OO feel. The standard library Over time various convenience features were added (e.g. for reading the content of a text file in one call) but some things are still surprising - e.g. until the DotNet core 3 version that came out late last year you had to use a third party library for (de)serializing Json (Newtonsoft.JSON was the go-to solution) while XML has been in the standard library since the beginning.

The standard library follows the idea to create a rough taxonomy of functionality by namespace that branches into more specific areas and then uses mostly classes that either have a few static methods or (usually) are instantiated and then you operate on them using methods. E.g. File related classes are grouped in the `System.IO` namespace, collection classes are in `System.Collections` etc..

If you need to find things in the standard library then the [microsoft dotnet framework help](https://docs.microsoft.com/en-in/dotnet/api/) is pretty good. It can filter by framework version etc..

The [F-Sharp language overview](https://docs.microsoft.com/en-in/dotnet/fsharp/language-reference/) is very good to get an idea of all the features in the language. As far as I know there is no offline version of the docs although Visual Studio did have some windows compiled help files at some point so something like this might still exist. [Fsharp for fun and profit](https://fsharpforfunandprofit.com/) is a great learning resource to learn about F# concepts.

Since you probably know some other programming language already the [Rosetta Code project](http://rosettacode.org/wiki/Category:F_Sharp) can be a good starting point to quickly learn how to do common things in F#.


### Json

Two ways of dealing with json: types (with optional annotations) and magic or explicit conversion

## Common gotchas

This is necessarily an incomplete list but here are a few things that can baffle beginners or where it may help to have been warned about differences in philosophy of different corners of the ecosystem.

### Collections
The .NET Framework version 1 didn't have generics (parametric polymorphism), so there are collection classes where items are untyped {% sidenote 'sn-arraylist' 'e.g. `System.Collections.ArrayList` which is a dynamically growing vector type that contains `object`s - `object` is the implicit base type of every type in .NET' %}. Version 2 added generics and so we now have new versions of the collection classes in System.Collections.Generic {% sidenote 'sn-list' 'e.g. `System.Collections.Generic.List<T>` in there which is a dynamically growing vector with items of type T that is specified at the instantiation point' %}. To add additional confusion, the F# base library added a few collection classes that are in the tradition of ML languages, notably `Microsoft.FSharp.Collections.List<T>` which is an immutable linked list and `Microsoft.FSharp.Collections.Map<K, V>` which is an immutable Map (internally implemented as a tree). When writing F# it makes sense to give preference to the immutable FSharp collection classes (Microsoft.FSharp.Collections is also opened by default so you can just write List<int> and so on to refer to to the Microsoft.FSharp collection types) but if you use third party libraries written in C# they will usually use the mutable variants in System.Collections.Generic.

### Async
Async operations are designed to allow efficient use of non-blocking IO, by freeing the thread they are called on to sleep until the operating system is done with the IO and will then resume your Thread at the point where it left off. Many methods in both the standard library and third party libraries exist in both an Async version and a synch (blocking) version where the latter is a little easier to use for cases where you don't mind the blocking (but it's usually good style to use the Async version). As an example, the `CsvFile` class from the commonly used FSharp.Data library has a static method `AsyncLoad(...)` that returns an `Async<CsvFile>`, i.e. the fact that this operation is async is also visible in the return type, in this case an async computation that, when all the non-blocking io is completed, will return a CsvFile instance.

Async is relatively similar to Promises or Futures in other langauges, but where these are usually started immediately, in F# an Async value is not immediately started on your behalf. This can seem a bit annoying because you have to manually start it at some point in your code (usually at the top of your console program you somewhere have an `Async.RunSynchronously(myAsyncComputation)` call or in the case of a webserver handler function the framework you use handles this for you and you just supply a function that returns an Async value). But the upside is that it composes much better and you can assemble deeply nested async workflows and then decide if you want to execute and block until done, execute and be notified, execute multiple async values in parallel etc.

One important gotcha with Async in F# is that you should be very careful to only call something like `Async.RunSynchronously()` at the very top of your program and instead make the functions leading up to this point all Async returning so that they can be  - if you use it further down in your callstack you will block the thread at this point and thus forgo the benefit of not blocking an operating system thread just for performing IO. What you should do instead is change the return type of your function  to also return an Async value (potentially up the call stack to the top) so that users of your function can decide how they want to handle this. Usually you want to use the computation expression for Async to make this a bit nicer as discussed in the next paragraph

### let! and other constructs with !
This can be confusing when starting to read F# code - there are several constructs that exist both in normal form (e.g. `let x = fooFn()` to create named values) and also in a form with an exclamation point aka bang at the end (e.g. `let! x = fooFn()`). The exclamation point version is one that can only exist within a computation expression and then it delegates the handling of the sequencing to the computation expression. This is often used for Async code like so:
```fsharp
let csvProcessingFunction() : Async<> =
    async {
        let
    }
```

### Records vs Classes



Open statements vs aliases
Async vs Task
Structs vs classes
nulls
Exceptions vs Result
Lists are linked lists
Scripts
System.Collections vs System.Collections.Generic vs FSharp.Collections
String functions live both in String and as members but autocomplete etc are sometimes misleading

## Community

The F# Foundation website is a good starting point to learn more about the various parts of the language etc. The F# Foundation manages various web properties and among others the fsharp github organisation.

Don Syme [@dsyme](https://twitter.com/dsyme) is the primary creator of the language and has worked on it since the precursors of F# in the late 90ies at Microsoft (F# grew out of the desire to have an ML language for the .NET Platform that was not yet released at the time - you can find out more about the history here []). At Microsoft there are a few more people working on F# and Visual F# (the Visual Studio integration), the most visible of whom is probably Philip Carter [@_cartermp](https://twitter.com/_cartermp).

Over the last 8 years or so the .NET Framework became cross platform with .NET Core and F# could be used outside of Visual Studio and also targeting Javascript. In this development, Krzysztof Cieślak [@k_cieslak](https://twitter.com/k_cieslak) was very important as the author of the VS Code extension Ionide, as was Steffen Forkmann [@sforkmann](https://twitter.com/sforkmann) who created Paket, a Nuget package manager that uses lockfiles and avoids problems the official Nuget manager has.

Alfonso Garcia-Caro [@alfonsogcnunez](https://twitter.com/alfonsogcnunez) is the creator of Fable, the Javascript backend for F#. Isaac Abraham [@isaac_abraham](https://twitter.com/isaac_abraham) is the author of Get Programming with F# which I heard good things about and one of the initiators of the SAFE stack (the preconfigured template for F# on .NET Core on the server and F# using Fable on the Frontend for a full stack F# experience).

Scott Wlaschin [@ScottWlaschin](https://twitter.com/ScottWlaschin) is the author of the wonderful F# learning resource [FSharpForFunAndProfit](https://fsharpforfunandprofit.com/) and the very nice general Domain Driven Design book "Domain Modeling Made Functional.

Sergey Tihon [@sergey_tihon](https://twitter.com/sergey_tihon) runs F# Weekly, a great resource to keep up to date with developments in the F# world.

There are of course many more people who work on the F# ecosystem or talk and write about it and I could never list them all - but the above list is a small overview of some key people in the ecosystem that you might want to follow on twitter.

The F# community is overall very welcoming and friendly. As often with small niche communities that are close to another, more mainstream ecosystem, there is some occasional frustration about F# not receiving more support from Microsoft. The reddit channel F# is apparently frequented by a few strange people, so you may prefer to stick to the F# slack or Forums.

F# is a topic is talked about in many FP friendly conferences but there are also two F# specific conferences: [Open FSharp](https://www.openfsharp.org/) and [Fable Conf](https://fable.io/fableconf/#home).

FSharp foundation
Fsharp weekly
Slack
Fable gitter
Dotnet conf, Fable conf ?
