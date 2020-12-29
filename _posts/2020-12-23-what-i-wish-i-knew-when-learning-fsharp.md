---
layout: post
title: What I wish I knew when learning F#
toc: true
---

I've used F# a lot in the last 3 years and for quite some time I wanted to collect a few good starting points to venture into F# in one place. I also wanted to collect some of those random things that I felt weren't easily available anywhere because they fall through the cracks of the official language reference and library documentation. While writing this post I had two inspirations in my mind: Hillel Wayne's post ["Why Python is my Favorite Language"](https://buttondown.email/hillelwayne/archive/2269df89-b3fc-406f-ac2e-9d7464879ba3) and Stephan Diel's ["What I Wish I Knew When Learning Haskell"](https://dev.stephendiehl.com/hask/). In the end I wound up collecting a high level view of the upsides and downsides of F#; a section about how to run/edit/debug F# code; and then a collection of small pieces of information that I think can easily confuse newcomers.

This will be a living document that I will try to updated regularly. It is also my personal perspective only - I may get things wrong or not know about some aspects or misrepresent certain projects. If you think I should change something or if you are a beginner and have run into obstacles that you think are worth adding then please let me know.

I'll sacrifice some accuracy on the history of the language, details of the runtime etc for the sake of brevity {% sidenote 'sn-history' 'If you are interested in a detailed history of F# then you will enjoy the document [the early history of the F# language](https://fsharp.org/history/hopl-final/hopl-fsharp.pdf)' %} - I want to get a newcomer started quickly, not write an accurate history of the development of the language.

Ok, with all that out of the way, let's dive in. I'll roughly follow Hillel's list of questions from ["Why Python is my Favorite Language"](https://buttondown.email/hillelwayne/archive/2269df89-b3fc-406f-ac2e-9d7464879ba3) as I think they capture many essential points very well when you look to working with a new language as an outsider.

## Why would I want to use F#?

I like F# and could write a whole blog post just with reasons to use the language. My personal elevator pitch is something like this: F# is great general purpose language for writing code that prevents several kinds of bugs thanks to it's great type system. It allows teams to stay productive as the code base grows because it emphasizes using functions and immutable data. It is a pragmatic language that steers you towards good design but provides all sorts of escape hatches if you need to optimize for performance etc. It can be used in a wide range of applications, from web frontends to backends to mobile applications to data science notebooks.

I want to go into a bit more detail than that though, so below I'll highlight a few of the main arguments in favour of F#.

F# has a **great type system** with [sum types](https://en.wikipedia.org/wiki/Tagged_union) (called Discriminated Unions in F#) and exhaustiveness checking that are notably missing from many other programming languages. This allows you to model data more accurately than with classes and simple enums alone and thus lets the compiler help you avoid a lot of common bugs. {% sidenote 'sn-sum-types' 'If you have never encountered them: think of them as enums on steroids because each case can have additional payload that can be different from case to case. When you use such a value you have to pattern match and then tell the compiler what do in each case and there you have the payload available.' %} At the same time, because of full type inference the compiler can figure out the types of most values and functions which allows users to omit them which leads to less visual clutter than in C# or Java.

The main compilation target, the .NET Core Framework, is a **rich runtime with great performance** characteristics that runs on all major platforms. It used to be the case that Windows was the main platform and Linux/OSX where only supported by third party implementations but with .NET Core that is the main incarnation now this is no longer the case and Microsoft officially supports several OSs and processor architectures.

It can leverage the **huge .NET ecosystem** with libraries for many tasks e.g. a highly tuned HTTP server implementation. Because .NET is very commonly used in large enterprises, companies that invest in client libraries for multiple programming languages tend to have an implementation for .NET/C# (e.g. Google Cloud, AWS, ...).

It is a "functional first" programming language that tries to guide you towards using **functions and immutable data structures** as your tool of choice. At the same time it is very pragmatic and allows you to write and consume object oriented code or libraries, use mutability for performance reasons etc. (F# is very close to [OCaml](https://ocaml.org/) and shares this approach with it)

The functional first approach and the support for Sum types and de-emphasis of Object Oriented code push you to architectural styles that IMHO allow for **higher code complexity at lower cost** and make it easier to deal with change requests. I say this as someone who has spent 13 years of their professional life as an OO proponent. Instead of worrying about questions of Is-A vs Has-A and the encapsulation of mutable state you work with functions and immutable data that compose and scale much better. This makes it great for writing complex software that can always be refactored and extended quickly.

It has a **scripting mode** where compilation is done on the fly. This makes it look and feel very similar to python but you still get type checking and much better performance. Tools like the [FAKE build tool](https://fake.build/) use this so the same language you use for writing your solution can also be used to automate building, publishing and deployment.

F# has a very powerful mechanism to create ergonomic workflow DSLs called [Computation Expressions](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/computation-expressions). {% sidenote 'sn-computation-expression' 'Computation Expressions are similar to Haskell''s do notation but with interesting additions. In Haskell, the do syntactic sugar applies mainly to Monads and Applicatives. In a language like F# that has loops etc. it makes sense to allow more constructs to be customized in a similar way.' %} If you have every used async/await in another programming language then you have seen a special case of a construct that can be expressed in a more general way with Computation Expressions (i.e. contrary to C#, Python etc. the async syntactic sugar in F# is not specially built for the async feature; instead, F# Computation Expressions let you write the implementation of the async syntactic sugar as normal user code). This let's you write code that concentrates on specific problems while extracting the wiring (e.g. how errors are propagated) into the implementation of the computation expression.

It has a lot of powerful unusual features that are just fun to explore and often very useful - e.g. built in [units of measure](https://docs.microsoft.com/en-us/dotnet/fsharp/language-reference/units-of-measure) that track dimensions correctly across arithmetic operations and prevent errors that arise from confusing different physical units in code; or [type providers](https://docs.microsoft.com/en-us/dotnet/fsharp/tutorials/type-providers/) that generate types from example data for you at compile time or within the IDE as you type.

It is also one of the few languages that can be used for both the (performant) implementation of **server side code and client side Javascript** with full access to the Javascript ecosystem. This allows sharing of implementation and types and makes teams much more productive in this common scenario.

Finally, it has a small but very friendly and **helpful community** that is very pragmatic. While you will find people who enjoy thinking about abstractions in software in themselves and how they relate to category theory, most people in the F# community just want to use their nice favorite language to build useful things.

## Why would I not want to use F#?

I never trust articles that never mention any down sides - so here are some that I see for F#:

Both the .NET and the Javascript compilation targets (see below for more) are garbage collected. There is some support for memory pinning etc for FFI purposes but in general if you **can't afford GC** F# is not for you.

The .NET **ecosystem is dominated by C#**, a language with exceptions, nulls and a heavy lean on classes with inheritance hierarchies as the main design tool. F# tries to favor Result values over Exceptions, makes it hard to create types that have null as a possible value and prefers functions, interfaces and simple algebraic data types over classes and inheritance. But because of C#'s dominance you do have to understand C# well enough to consume libraries and to translate some concepts.

If you mainly do **machine learning** then the library and ecosystem in Python is much more developed than that on .NET.

It has relatively **weak metaprogramming capabilities** and it doesn't have higher kinded types. This means that there is a ceiling to the abstractions and terse-ness of your code vs something like Haskell. In practical terms this means e.g. that something like Haskell's [Aeson library](https://hackage.haskell.org/package/aeson-1.5.4.1/docs/Data-Aeson.html) that generates JSON serialization from types at compile time, or Rust's [Serde library](https://serde.rs/) can't be built in F#. The dotnet framework does have runtime reflection so such features can be done by runtime type introspection but this comes at a performance penalty. F# has type providers that can help somewhat in this problem space but they are limited in what they can take as inputs (e.g. no F# types) and are somewhat fragile in how they interface with different compiler versions. If you know you'll need strong metaprogramming capabilities then other languages might be a better choice.

If you need to hire a large number of engineers who know F# in a particular **geographical location in a short period of time** then this can be difficult. Because F# is a relatively niche language, both the job market and the applicant pool are comparatively small. As with many other functional programming languages though, both the jobs and the applicants you do find are usually very interesting and if you have some time F# is relatively quick to learn if you know a bit of functional programming.

If you work a lot with **copy and paste from stackoverflow** (I don't want to diss this, there are many people who work on software for whom this is a very legitimate way). The number of examples for "how do I" for something like Python is a lot larger than that for F#; same with learning resources in general, although what exists is often very good - e.g. Scott Wlaschin's [fsharp for fun and profit](https://fsharpforfunandprofit.com/) is one of the best functional programming resources I know across all functional programming languages.

The **documentation** story in the F# and wider .NET ecosystem is not great, at least when compared with languages like Rust that provide tools for this and have a culture around high level documentation efforts. It is quite a bit better than the documentation level in languages like Haskell though.

There is also a section below on common gotchas in F# that you may want to consider as possible counter arguments for F# as well.

## Where can I run F#? What are the prerequisites?

F# has three main compilation targets: The Windows only .NET Framework that exists since 2001; the modern, cross platform .NET Core Framework (also by Microsoft, sort of replacing Mono on OSX and *nix and being the new incarnation of .NET on Windows as well); and Javascript via the [Fable Compiler](https://fable.io/) project, which can then run in the Browser, on Node, on AWS Lambda etc..

The old .NET Framework comes pre-installed with Windows and only runs there. The current version as of 2020 is 4.8 and versions used to be updated occasionally with OS updates. The .NET Framework consists of a runtime part (CLR, Common Language Runtime) that includes a VM that JIT compiles Bytecode and runs it (much like the JVM in the Java ecosystem), and an optional SDK that includes the C# and F# compiler etc for development.

The new [.NET Core Framework](https://dotnet.microsoft.com/) is similar and in many parts largely API compatible to the old .NET Framework but was built as a new open source, cross platform implementation of the non-Windows specific parts (i.e. what is missing from .NET Core is Windows GUI support and a few other parts of the standard library that don't make much sense in a cross platform context). You need to install the runtime (CLR, see above) for the system you are running which includes the VM implementation. There are packages available for most major operating systems and processor architectures. Just like above, there is then a separate SDK with the compilers etc. As of late 2020, installing the [.NET Core framework version 5](https://dotnet.microsoft.com/download) would be my recommended target framework if you don't know what to use.

If you want to target Javascript you need a fork of the main F# compiler called [Fable](https://fable.io/). This is using the same codebase as the official F# compiler that is shipped with the two SDKs above but has an alternative backend for code generation that instead of .NET Bytecode creates a Babel AST that is then serialized to Javascript using Babel (Fable 1+2) or Javascript directly (Fable 3). There is a relatively straightforward FFI to tell the F# compiler about functions and "types" of objects in Javascript so you can freely use any third party Javascript libraries. Fable comes with a definition of much of the Browser and Node APIs so you can use them directly when writing F# that targets Javascript and a significant part of the .NET Class library has been implemented with Javascript to allow idiomatic F# code to run in this alternate runtime environment (so you can e.g. use `System.Console.WriteLine("Hello")` from the .NET base class system instead of `Fable.Import.Browser.console.log("Hello")`). Fable works surprisingly well overall. There are a few gotchas because the F# compiler is built on the assumption of certain .NET base types (e.g. [different truncation behaviour](https://fable.io/docs/dotnet/numbers.html) for what F# thinks are 32 bit integers as Javascript only has one number type other than the upcoming BigInt) - but it turns out that this is a very powerful and straightforward way of creating Javascript solutions.

## How am I supposed to be writing this?

If you just want to get a quick feel for the language then the [Try F# website](https://try.fsharp.org/) is a good starting point that let's you play with the language in the browser.

To actually work with your own codebases I know of five reasonably comfortable ways to develop F#: [Visual Studio](https://visualstudio.microsoft.com/) (both for Windows and OSX), [Visual Studio Code](https://code.visualstudio.com/) with the [Ionide plugin](https://ionide.io/), [Jetbrains Rider](https://www.jetbrains.com/rider/) and finally the [vim](https://github.com/ionide/Ionide-vim) and [emacs](https://github.com/fsharp/emacs-fsharp-mode) plugins that use the LSP protocol to talk to FsAutocomplete (the same backend that powers Ionide.). Myself and most of my colleages use VS Code with Ionide on Windows or OSX which usually work very well.

Unless you are familiar with and really want to use the old Visual Studio I would recommend downloading the dotnet core 5 sdk for your platform, getting an editor (e.g. VS Code + Ionide) and then creating a new folder and running `dotnet new console -lang fsharp` to get a scaffold for a console app and start playing with it there (`dotnet run` builds and immediately runs the project).

## Debugging and the REPL

VS, VS Code and Rider all offer integrated debugging (step through, see values, break on exception etc). Call stacks in code using computation expressions can be a bit hard to parse because the wiring of the Bind implementation is interwoven with your own code but for most needs this is a pretty nice debugging experience; definitely better than with a lot of other statically typed functional programming languages.

There is a repl (`dotnet fsi` when you are on dotnet core 3+) and there is  support for loading files with their dependencies into it or to use libraries in scripts and evaluate parts of that in the interactive repl of your editor. This experience is not as great as with Lisps but works ok (with .NET Core Version 5 the story for referencing third party packages got a lot better so if you tried the repl experience before and were disappointed it is worth checking it out again).

## The standard library

The .NET Framework has a pretty extensive standard library that allows you to do a lot of everyday stuff (though not as extensive as python's). Much of it was originally designed around 2000 with primarily the object oriented C# language in mind, so a lot of the standard library that you use (everything in the System. namespace) has a very OO feel. Over time various convenience features were added (e.g. for reading the content of a text file in one call) but some things are still surprising - e.g. until the DotNet core 3 version that came out late last year you had to use a third party library for (de)serializing Json (Newtonsoft.JSON was the go-to solution) while XML has been in the standard library since the beginning.

The standard library follows the idea to create a rough taxonomy of functionality by namespace that branches into more specific areas and then uses mostly classes that either have a few static methods or (usually) are instantiated and then you operate on them using methods. E.g. File related classes are grouped in the `System.IO` namespace, collection classes are in `System.Collections` etc.. (see below on some gotchas about the collection classes in the .NET standard library and F#'s own collections).

When using Fable (the F# compiler that outputs Javascript), some things around the standard library and packaging are a bit more involved - more on that below in the Fable section.

You can find additional libraries on [nuget.org](https://www.nuget.org/), use `dotnet add package` to add them to your project and use them.

## Code formatting

Gofmt popularized the idea of using tools to format source code and many languages have since created similar tools. For F# the tool in question is [Fantomas](https://github.com/fsprojects/fantomas). It is included in FsAutocomplete, the backend for Ionide and so if you use VSCode and Ionide you don't need to install it separately. The Fanotmas authors have created an [online version](https://fsprojects.github.io/fantomas-tools/#/fantomas/preview) of their tool that you can also use to inspect the F# AST and how it is turned into source code which is useful for reporting issues with the formatting.

## Packaging

The packaging ecosystem story for both the old .NET Framework and .NET core is to use [Nuget packages](https://www.nuget.org/). These are just zipped archives that contain some metadata and dependency information and then the compiled artifacts called assemblies that contain the library code. Assemblies contain the compiled bytecode to be executed and a lot of metadata on the types so that types can be extended and consumed across language borders between different programming languages (the main ones are C# which is what most stuff is written in, F#, VB.NET, "managed C++" and then some other fringe languages like [Nemerle](http://www.nemerle.org/About)). {% sidenote 'sn-fun-fact' 'Fun fact - they have the file extension .dll and are actually win32 dlls that a windows 95 era tool would at least understand to some degree' %}

The nuget packaging story is a bit flawed in that it doesn't use lock files by default and doesn't differentiate transitive dependencies. I thus strongly recommend using the alternative [paket package manager](https://fsprojects.github.io/Paket/) for larger projects that lets you use nuget packages in a principled way (and is written in F# 😉). For smaller projects the default nuget is usually fine.

To find libraries you can search directly on nuget.org. If you google for stuff then it often helps to search in this order for "yourtopic fsharp" "yourtopic c#" or "yourtopic dotnet". Idiomatic F# libraries are often a little nicer to use from F# (e.g. because the use immutable records instead of mutable classes) but you can use any dotnet library from f#. Try to use F# libraries first and otherwise sort by popularity as an initial heuristic when choosing libraries for tasks if multiple libraries exist. If you find F# type providers {% sidenote 'sn-type-providers' '**Type providers**  are a metaprogramming facility that operates sort of like a compiler plugin that looks at sample data to generate types. E.g. there is a type provider for CSV files that takes the path to a csv file alongside your source code which it then reads (at compile time or during the editor session) and generates a row type from the example csv file without you having to spell out the F# code for the type' %} then they can be worth a try if you want to get somewhere quickly but they may be a maintenance burden in the long run for more complex projects.

Third party libraries don't have a consistent documentation story unfortunately, so you usually go to the project site and follow the project readme to whatever official documentation the library has. Source code in C# and F# can be annotated with special comments (line comments with three instead of two slashes above the entity) that then get compiled into xml files that accompany assemblies - these files are used by editors to show help text on functions and classes on hover in your editor.

Publishing a library is pretty straightforward - `dotnet pack` packs the library into a nuget archive and after creating an account and [setting up the api token](https://docs.microsoft.com/en-us/nuget/nuget-org/publish-a-package), `dotnet publish` will push it to nuget. If you are using the Paket package manager then it gives you a similar command but it will handle dependency ranges in a less manual way. [FAKE build scripts](https://fake.build/) can automate building, testing and publishing of libraries all while using the full power of F# for writing your build scripts. Github actions now comes preinstalled with .NET Core so you can do all of this using Github Actions easily.

If you need to understand a third party NuGet package (e.g. because the documentation is lacking which for some smaller libraries in F# land can definitely be the case), then you have several options. If the project is open source then the easiest is usually to browse the source code there. Some packages use SourceLink, a way to upload debug symbols for libraries so that users of the library can use them by stepping into their source when debugging - not all editors can make use of them though. If the source code is not easily available then some editors come with .NET Bytecode decompilers (e.g. Visual Studio and Jetbrains Rider) and there also exist some standalone tools for that though most are Windows only ([AvaloniaSpy](https://github.com/icsharpcode/AvaloniaILSpy) is the main cross platform one I know of). I don't know any tools that decompile to F# so if the library you are decompiling is not open source but authored in F# the resulting decompiled C# will look a bit odd - but that is a rare case since most .NET libraries are written in C# and the most common F# libraries are open source.

## Testing

In F# the preferred library for writing tests is [Expecto](https://github.com/haf/expecto). It allows you to do tons of interesting tests including performance tests between implementations with proper statistical tests. You can add [FSCheck](https://github.com/fscheck/FsCheck) for property based testing, {% sidenote 'sn-property-based-testing' '**Property Based Testing** is a technique to automate test case generation in an intelligent way. Instead of single example testing which is what you do in unit testing, in property based testing you describe statements that you expect to be true (e.g. changing the order of this mathematical operation should not change the result; or serializing and deserializing a value of this type should lead to an identical value) and let the test suite create random values to test your assertions with' %} which I recommend doing - e.g. to test if custom deserializer/serializer pairs lead to identical values.

Expecto is usually run by creating a standalone console app from a template {% sidenote 'sn-expecto' '`dotnet new -i Expecto.Template::*` and
`dotnet new expecto -n PROJECT_NAME -o FOLDER_NAME*`' %}. With `dotnet watch run` it can rerun tests on every file change.


## Fable and the SAFE stack

Fable is a standalone distribution of the F# compiler that uses the same front-end as the official F# compiler but has an alternative backend that generates Javascript. There are a few relatively exotic F# constructs that are not or only partly supported (e.g. Reflection is only partly supported). There are some differences because of runtime has different semantics and implementations (e.g. float truncation behaviour can differ, the Regex engines have slightly different capabilities, ...).

Fable 3 came out in late 2020 and came with a few big changes. Before version 3 Fable used [Babel](https://babeljs.io/) to output Javascript by interacting with Babel and building a Babel AST. This was useful in 2015 when Javascript was evolving rapidly and creating JS code compatible with different execution targets was an appealing feature that came for free with Babel. The distribution of version 1 and 2 was done as an npm project and most setups used webpack to invoke Fable as a processor for .fs files.

With Fable 3 both of this changed and Javascript is now generated directly. Fable 3 is also distributed as a dotnet tool (i.e. executed via `dotnet fable` ) and a plugin system was added that allows library authors to automate creation of boilerplate code (e.g. when creating components for UI libraries).

All of the above for both Version 1, 2 and 3 mean that you can mostly write normal F# code that is then turned into relatively normal Javascript. It works pretty well and at my company we wrote several full web frontends with this approach (using React for rendering and the [F# Elmish library](https://elmish.github.io/elmish/) for state management). You do have to have some understanding of Javascript though when you want to use third party Javascript libraries. Here you basically tell F# about types of functions and the objects and it will trust you to have translated these concepts correctly. Some of the .NET standard library has been re-implemented in Javascript so that some reasonable subset of normal library calls work but unfortunately there is no compile time signal about which parts are translated and which are missing (i.e. when you use a seldom used member function on e.g. the Regex type that has not been re-implemented for the Javascript code it will crash at runtime with no warning at compile time).

I feel Fable is a very pragmatic solution that enables the very interesting possibility of writing web UIs in F#, even if it is no silver bullet. When working in a small team it's worth a lot if all parts of the code base (backend, frontend, build scripts) are written in one language. Even if different people have different specializations, everyone can fix small issues in all parts of the code base and so using F# in the entire stack is pretty compelling IMHO.

If you are interested in Fable for writing frontend application then [the Elmish Book](https://zaid-ajaj.github.io/the-elmish-book/#/) is a great resource that explains all the moving pieces to create complex web apps using Fable.

A list of Fable libraries is maintained at the [Awesome Fable](https://github.com/kunjee17/awesome-fable) repository.

### The SAFE Stack

Worth a special mention is the [SAFE stack](https://safe-stack.github.io/). This is a preconfigured template that sets up F# on the backend (using ASP.NET core via either the straight forward [Giraffe library](https://github.com/giraffe-fsharp/Giraffe) or the more opinionated [Saturn library](https://saturnframework.org/)), and on the frontend (using Fable 2 as of late 2020). The SAFE template can either be used in a barebones configuration or in a more opinionated, fully fledged version that comes with frontend and backend testing libraries, Bulma preselected as a style framework, a choice of type safe automated communication between frontend and backend and so forth.

If you want to explore the SAFE stack then head over to the [quickstart](https://safe-stack.github.io/docs/quickstart/) to learn about the requirements and how to set up a project using the template.

## How do I do common stuff? How do I find out how to do things?

If you need to find things in the standard library then the [microsoft dotnet framework help](https://docs.microsoft.com/en-in/dotnet/api/) is pretty good. It can filter by framework version etc..

The [F-Sharp language overview](https://docs.microsoft.com/en-in/dotnet/fsharp/language-reference/) is very good to get an idea of all the features in the language. As far as I know there is no offline version of the docs although Visual Studio did have some windows compiled help files at some point so something like this might still exist. [Fsharp for fun and profit](https://fsharpforfunandprofit.com/) is a great learning resource to learn about F# concepts.

Since you probably know some other programming language already the [Rosetta Code project](http://rosettacode.org/wiki/Category:F_Sharp) can be a good starting point to quickly learn how to do common things in F#.

The [Awesome F#](https://github.com/fsprojects/awesome-fsharp) list is a great overview of good F# libraries for various tasks.

Every December there is also the tradition of the [F# Advent Calendar](https://sergeytihon.com/2020/10/22/f-advent-calendar-in-english-2020/) where various members of the community write a blog post about something F# related that interests them. It's a good way to discover interesting uses of F#.


## Community

The [F# Foundation website](https://fsharp.org/) is a good starting point to learn more about the various parts of the language etc. The F# Foundation manages various web properties and among others the fsharp github organisation.

Don Syme [@dsyme](https://twitter.com/dsyme) is the primary creator of the language and has worked on it since the precursors of F# in the late 90ies at Microsoft (F# grew out of the desire to have an ML language for the .NET Platform that was not yet released at the time - you can find out more about the history [here](https://fsharp.org/history/hopl-final/hopl-fsharp.pdf)). At Microsoft there are a few more people working on F# and Visual F# (the Visual Studio integration), the most visible of whom is probably Philip Carter [@_cartermp](https://twitter.com/_cartermp).

Over the last 8 years or so the .NET Framework became cross platform with .NET Core and F# could be used outside of Visual Studio and also targeting Javascript. In this development, Krzysztof Cieślak [@k_cieslak](https://twitter.com/k_cieslak) was very important as the author of the VS Code extension Ionide, as was Steffen Forkmann [@sforkmann](https://twitter.com/sforkmann) who created Paket, a Nuget package manager that uses lockfiles and avoids problems the official Nuget manager has.

Alfonso Garcia-Caro [@alfonsogcnunez](https://twitter.com/alfonsogcnunez) is the creator of Fable, the Javascript backend for F#. Isaac Abraham [@isaac_abraham](https://twitter.com/isaac_abraham) is the author of "[Get Programming with F#](https://www.manning.com/books/get-programming-with-f-sharp)" which I heard good things about and one of the initiators of the SAFE stack (the preconfigured template for F# on .NET Core on the server and F# using Fable on the Frontend for a full stack F# experience).

Scott Wlaschin [@ScottWlaschin](https://twitter.com/ScottWlaschin) is the author of the wonderful F# learning resource [FSharpForFunAndProfit](https://fsharpforfunandprofit.com/) and the very nice general Domain Driven Design book "[Domain Modeling Made Functional](https://pragprog.com/titles/swdddf/domain-modeling-made-functional/)".

Sergey Tihon [@sergey_tihon](https://twitter.com/sergey_tihon) runs [F# Weekly](https://sergeytihon.com/category/f-weekly/), a great resource to keep up to date with developments in the F# world.

Zaid Ajaj [@zaid_ajaj](https://twitter.com/zaid_ajaj) is the author of numerous projects in the Falbe universe and [the Elmish Book](https://zaid-ajaj.github.io/the-elmish-book/#/), a great, free resource that explains Fable, the Elmish state management library and so forth including tips on creating larger applications and workflows.

There are of course many more people who work on the F# ecosystem or talk and write about it and I could never list them all - but the above list is a small overview of some key people in the ecosystem that you might want to follow on twitter.

The F# community is overall very welcoming and friendly. As often with small niche communities that are close to another, more mainstream ecosystem, there is some occasional frustration, e.g. about F# not receiving more support from Microsoft. The reddit channel F# is apparently frequented by a few strange people, so you may prefer to stick to the [F# slack](https://fsharp.org/guides/slack/) or [Forums](https://forums.fsharp.org/).

F# is a topic at many FP friendly conferences but there are also two F# specific conferences: [Open FSharp](https://www.openfsharp.org/) and [Fable Conf](https://fable.io/fableconf/#home).


## Common gotchas

This is necessarily an incomplete list but here are a few things that can baffle beginners or where it may help to have been warned about differences in philosophy of different corners of the ecosystem. I concentrate here on things that are helpful to know when you start to read tutorials or open source F# code.

### Generic type parameters and list, option etc

Generics (aka parametric polymorphism) make it possible to write types that are parametrized by one or more other types which is e.g. useful for properly typed collection classes. In C# the syntax is always using angle brackets and uppercase type variables, e.g. List<T>. In F#, generic type variables when declaring new generic types have to use a single quote prefix like so (lower case is more common but both exist): `'a`, so a type definition with a generic type is defined as `List<'T>`. Because of F#s OCaml heritage, there is an alternative syntax for declaring concrete instances of generic types which is a postfix notation like so: `'T list`. The angle bracket syntax is by convention preferred for all but 4 generic types which are `list`, `array`, `ref` and `option`. This is a bit random trivia but it is helpful to know this when reading F# so I wanted to mention it.

```fsharp
let intOptionA : int list = [ 3; 4 ]
let intOptionB : List<int> = [ 3; 4 ] // same as above
```

### Collections
The .NET Framework version 1 didn't have generics (parametric polymorphism), so the old collection classes in System.Collections all have the items as untyped objects {% sidenote 'sn-arraylist' 'e.g. `System.Collections.ArrayList` which is a dynamically growing vector type that contains `object`s - `object` is the implicit base type of every type in .NET' %}. Version 2 added generics and so we now have new versions of the collection classes in System.Collections.Generic {% sidenote 'sn-list' 'e.g. `System.Collections.Generic.List<T>` in there which is a dynamically growing vector with items of type T that is specified at the instantiation point' %}.

To increase the confusion, F# brings it's own philosophy on collection classes coming from the OCaml tradition and this is in some parts a bit at odds with the .NET standard library naming. The F# collections live in the FSharp.Collections namespace that is open by default and contains the following 5 main collection types: `List<T>` (immutable single linked lists) created with the literal syntax `[ 1; 2; 3]`; `Array<T>` which are mutable fixed size .NET arrays that are contiguous in memory and created with the literal syntax `[| 1; 2; 3|]`; `Seq<T>` which are lazy iterators (the IEnumerable interface in C#) created with the literal syntax `seq { yield 1; yield 2; yield 3}`; `Set<T>` which is an immutable set implemented as a sorted tree that has no native literal syntax; and `Map<K, V>` which are immutable key/value maps/dictionaries implemented as ordered trees that have no native literal syntax.

```fsharp
let linkedList = [ 1; 2; 3]
let fixedArray = [| 1; 2; 3 |]
let lazySequence = seq { yield 1; yield 2; yield 3 }
let set = Set([1; 2; 3])
let map = Map([ ("first", 42); ("second", 23)])
```

Functions that operate on these collections are in modules of the same name:

```fsharp
let incrementedSequence =
    lazySequence
    |> Seq.map (fun x -> x + 1)

let incrementedArray =
    fixedArray
    |> Array.map (fun x -> x + 1)
```

Which is all fine so far, but what can be a bit confusing when getting started is that if you look for C# code of some library you will never see these collection classes and instead see the main collections from the standard library which are mutable: `System.Collections.Generic.List<T>` which is a mutable, dynamically resized vector; and `System.Collections.Generic.Dictionary<K, V>` which is a mutable Hashmap. So in F# code unless there is an open statement for System.Collections.Generic the type List will mean the F# immutable linked list, but in C# code or if the System.Collections.Generic namespace is opened, List refers to the mutable dynamically resized vector.

```fsharp
open System.Collections.Generic
let mutableVector = List<int>(seq {yield 1; yield 2; yield 3})
mutableVector.[1] <- 23
mutableVector.Add(55) // add 55 as the last (4tht) element
```

### Async

Async operations are designed to allow efficient use of non-blocking IO, by freeing the thread they are called on to sleep until the operating system is done with the IO and will then resume your thread at the point where it left off. Many methods in both the standard library and third party libraries exist in both an async version and a sync (blocking) version where the latter is a little easier to use for cases where you don't mind the blocking (but it's usually good style to use the async version). As an example, the `CsvFile` class from the commonly used FSharp.Data library has a static method `AsyncLoad(...)` that returns an `Async<CsvFile>`, i.e. the fact that this operation is async is also visible in the return type: in this case an async computation that, when all the non-blocking io is completed, will return a CsvFile instance.

Async is relatively similar to promises or futures in other languages, but where these are usually started immediately, in F# an async value is not immediately "run" on your behalf. This can seem a bit annoying because you have to manually start it at some point in your code {% sidenote 'sn-async' 'Usually at the top of your console program you somewhere have an `Async.RunSynchronously(myAsyncComputation)` call or in the case of a webserver handler function the framework you use handles this for you and you just supply a function that returns an async value' %}. But the upside is that it composes much better and you can assemble deeply nested async workflows and then decide if you want to execute and block until done, execute and be notified, execute multiple async values in parallel etc.

One important gotcha with async in F# is that you should be very careful to only call something like `Async.RunSynchronously()` at the very top of your program and instead make the functions leading up to this point all async returning so that they can fulfill their duty as planned - if you use it further down in your callstack you will block the thread at this point and thus forgo the benefit of not blocking an operating system thread just for performing IO. What you should do instead is change the return type of your function to also return an async value (potentially up the call stack to the top) so that users of your function can decide how they want to handle this. Usually you want to use the computation expression for async to make this a bit nicer as discussed in the next paragraph

### let! and other constructs with !
This can be confusing when starting to read F# code - there are several constructs that exist both in normal form (e.g. `let x = fooFn()` to create named values) and also in a form with an exclamation point aka bang at the end (e.g. `let! x = fooFn()`). The exclamation point version is one that can only exist within a computation expression and then it delegates the handling of the sequencing to the computation expression.

Computation expressions are a nice feature in F# that allows library authors to provide syntactic sugar for working with their types. It's similar to Haskell's do notation, but covers the complexities arising from combining this kind of syntactic sugar with loops etc.

Computation expressions and let! and similar constructs are often used for Async code like so:

```fsharp
let csvProcessingFunction() : Async<unit> =
    async {
        let prefix =
            "The content of testfile is: "

        let! fileContent =
            System.IO.File.ReadAllTextAsync("testfile.txt")
            |> Async.AwaitTask

        do! System.IO.File.WriteAllTextAsync("newfile.txt", prefix + fileContent)
            |> Async.AwaitTask
    }
```

This is a function that returns an Async of unit (no return value). The body is using the async computation expression. The first let binding to the variable prefix is a normal binding, i.e. the string value on the right hand side is bound to the name on the left hand side. The second let bang binding is a bit different. Here the right hand side is a the ReadAllTextAsync function that returns a `Task<string>` which is then passed to Async.AwaitTask to convert to `Async<string>` (see below for Async vs Task).

What the `let!` is doing now is that it looks up the implementation for the `async { }` computation expression and lets it "deal with" the async value. Once this is done the content of the async, in this case a string value is bound to fileContent {% sidenote 'sn-computation-expression' 'What is actually happening is that the F# compiler breaks the function into continuation chunks at these points. The Bind function which is one of the two mandatory function of a computation expression implementation then gives the implementation for how to deal with a wrapped value and a continuation function that receives an unwrapped value and returns a wrapped value again' %}. The result of `ReadAllTextAsync` is a Task so it is piped here to `Async.AwaitTask` which turns it into an Async value. If you were to use a normal let (without the !) then the fileContent would contain the `Async<string>` value and we wouldn't be able to make use of the result of this async computation yet. do! is simalar, the difference being that here no value is bound, just a statement executed for its side effect.

### Async vs Task

Async came to F# in version 2.0 around 2010 and a bit later in C# 5 (released in 2012), C# and the standard library came out with a very similar but somewhat different approach to async. Unfortunately the two approaches did not use the same types to represent this in an easily compatible way, even if they represent semantically very similar concepts. I assume that this might have to do with different desired default behaviour. As described above, Async's are not evaluated until run whereas Tasks in most uses are immediately started (just like Promises and Futures in most languages). Because C# is the dominant language in .NET, most third party libraries you use will return a `Task<T>` value when performing asynchronous computations. One actual benefit that C#'s Task implementation has is that is has a lower overhead. For IO bound operations this doesn't matter much but when a task is CPU bound and a lot of very short lived Tasks are created then they will generally outperform their Async counter part. When using C# libraries in F# you can easily convert between Task and Async (using Async.AwaitTask as shown above and Async.StartAsTask) and default to Async, but when writing an F# library that should be easily consumable from C# it's better to use the Task type.

### Semicolons vs newlines in lists and records

Something that can be confusing for newcomers is that many literals can either be created on the same line with semicolons as separators or using newlines with the correct indentation. The following examples show this:

```fsharp
let list1 = [ 1; 2; 3]
let list2 =
    [ 1
      2
      3 ]
type RecordA = { FieldA : string; FieldB : int}
type RecordB =
    { FieldA : string
      FieldB : int }
```

### Anonymous records

F# 4.6 introduced anonymous records with a slightly different syntax from normal records. They are useful for cases where a full records seems overkill but a tuple misses some information, for example for color triples or similar. Because of some constraints with regards to the .NET runtime, anonymous records can have some surprising behaviour, e.g. two values with the same shape become the same anonymous record type when declared in the same assembly, but different ones across assembly borders. This means that using anonymous records is fine for returning semi-complex data in a slightly ad-hoc way from functions but they should be promoted to proper records when used in a more public API.

```fsharp
// using a named record
type NamedFullName =
    { FirstName : string
      LastName : string }

let name1: NamedFullName =
    { FirstName = "Albert"
      LastName = "Einstein" }

// using an anonymous record that also has a BirthDate

let name2 =
    {| FirstName = "Roger"
       LastName = "Penrose"
       BirthDate = System.DateTime(1931, 8, 8) |}

```

### Modules vs member functions

A slightly confusing issue is that for several common topics like String there exist both member functions that are called on concrete instances but also an F# module for this type. The member function approach is the one that is used in C#, the module approach is additionally available in F#. This means that if you want to replace a value in a string you can either do `"Teststring".Length` or you can use `String.length "Teststring"`. The functionality is different between the two, e.g. replace only exists as a member function, map only in the module. Just another little oddity that is good to be aware of.

### Operator precedence

If you know other ML family languages then you might be tempted to define some operators for 2-ary functions, e.g. >== for monadic bind, <*> for lifting binary functions ets. This works in theory but is somewhat discouraged and the operator characters and their associated precedence is hardcoded in the language. This means that e.g. overriding addition or multiplication for custom vector types or adding bind is not a problem, but complex operator hierarchies like e.g. in Haskell's various lens libraries are not really feasible.

### Type inference order and the obsession with the |> pipe operator

The F# compiler works in a single pass which has some consequences that can trip up newcomers. The obvious one is that in an F# project, the order of files matters and inside files the order of declarations is relevant as you can only ever use types, values and functions that have been already declared "further up". The only exception to this is if you declare a rec module or use mutually recursive type definitions. This may seem really annoying at first but turns out to work very well in practice when navigating larger programs.

The other, less obvious result of the single pass is that even within expressions the F# compile can sometimes fail type inference for earlier tokens that would become clear when taking later parts into account when e.g. using member functions. Consider this example:

```fsharp
let strLength =
    List.map (fun x -> x.Length) ["hello"; "world"]
```

In this form the compiler rejects it. If you rearrange it a bit so that the type parameter for List becomes fixed by putting the string array first and piping it into the rest then it works:

```fsharp
let strLength =
    ["hello"; "world"]
    |> List.map (fun x -> x.Length)
```

Arguably this reads nicer but it sometimes feels a bit silly to have to do this. Note that this is only necessary because we wanted to access a member in the lambda function - if we had used a normal function then it would have worked:

```fsharp
let strLength =
    List.map String.length ["hello"; "world"]
```

### The Open keyword, Namespaces and Modules

The way imports work in .NET with the open keyword can be confusing, so let me summarize the ways to organize code in F# first. The .NET Framework has the concept of Namespaces to organize code. Namespaces in C# can only contain types, not values or functions. In C# the main way of organizing code is namespaces and classes (which can be static if they only include static functions).

F# uses a lot of top level values and functions and so F# introduced modules since Namespaces can't contain them directly. These do not exist as first level entities in .NET bytecode and instead are compiled into static classes. In F#, a single file can contain multiple namespaces which in turn can contain multiple Modules which then can contain values, functions and types. Namespaces can span multiple files, modules etc can't. The full name of every value, function or type in F# is prefixed by their namespace and module name.

```fsharp
namespace MyProject

module ModuleA =
    type SomeRecord =
        { SomeField : string }

module ModuleB =
    type OtherRecord =
        { RecordMember : ModuleA.SomeRecord }
```

All of this seems straightforward enough but the confusion comes when you use namespaces, modules, values and types with the open keyword. This allows you to omit the namespace/module/class part of a type/function/value, i.e. instead of `System.IO.File` you can first `open System.IO` and then just use `File` to mean the same type.

Open's override each other in turn so if another namespace/module is opened later that also defines a File then it will resolve to the one that was opened further down in the file.

```fsharp
let someFn() : List<int> =
    [1; 2; 3]

open System.Collections.Generic

let someOtherFn() : List<int> =
    List<int>([1; 2; 3]) // List now refers to the type from
                         // System.Collections.Generic which
                         // is different from the list literal
                         // so we have to construct it explicitly
```

There is no proper import aliasing as there is in Haskell or Python. You can alias values, functions, types and modules, but not namespaces. These aliases actually bind new values/functions/types/modules which is problematic if you are used to how this works in other languages because it is not limited to the file where this aliasing occurs (i.e. if you declare an alias like this `type File = System.IO.File` in the f# source file A.fs and then in file B.fs that comes later in the source ordering open the namespace or module of A then File will be in scope!)

```fsharp
// File A
module ModuleA =
    type File = System.IO.File
    // ... do something with File

// File B
module ModuleB =
    open ModuleA

    type SomeRecord =
        { SomeFile : File } // This type alias was declared in File A!
```

My recommended way of dealing with this is to use aliases but define them as private so that they are only visible within the same type/module, like so: `type private MyFile = System.IO.File`. Then use open only when you know that you will use a lot of the contents of that namespace module and are aware of the potential shadowing.

```fsharp
// File A
module ModuleA =
    type private File = System.IO.File
    // ... do something with File

// File B
module ModuleB =
    open ModuleA

    type SomeRecord =
        { SomeFile : File } // This is now a compiler error
```

### Null

The story of null in the .NET Framework is a bit weird, so let me again give some context first. In the .NET Framework there exist for performance reasons value types that are directly allocated on the stack (e.g. primitives like int, float etc and user defined structs) as well as heap allocated reference types (strings and user defined classes). Most value types can be converted into reference types in a process called boxing (and the reverse unboxing) to matching reference types. This is mostly useful to be able to treat all values as derived from System.Object and have dynamic dispatch work for value types as well.

As most languages designed in the 90ies, C# and the .NET framework both have null as a valid value for all reference types (though not for value types). Code that is written in F# tries to avoid null and so record types and discriminated unions defined in F# do not consider null a valid value. In cases where the absence of a value should be possible in F# the option type should be used which is a discriminated union that communicates this clearly and forces the consumer of such a type to always declare how to handle the absent value.

Since a lot of the .NET ecosystem is written in C# though, you have to be defensive with reference type values that come from third party libraries and guard their use with isNull checks etc.

Ironically, the designers of C# decided in C# 8 that the inability to discern between nullable and non-nullable reference types was a mistake and introduced a new annotation on types to indicate if null is a valid value for this reference type or not and added a special syntax to support this when declaring variables etc. The effort to retrofit these annotations to the standard library and third party libraries is still ongoing as of late 2020. F# does not yet support taking these annotations into account but the next version of F# will probably be able to do so, so that you get a warning when not handling nulls in reference values coming from third party libraries that are annotated as nullable but no such warnings coming up if the value is annotated as non-nullable.

### Exceptions vs Result

The .NET Framework uses Exceptions as it's primary means to communicate errors. Exceptions have quite a few advantages (e.g. call stacks which are useful in diagnostics, ability to add arbitrary structured information in subclasses, ...) but also a few downsides (they do not show up in the type of a function; documenting possibly thrown exceptions is inconsistent in the ecosystem and not mandatory; they are relatively expensive to create and handle).

```fsharp
// notice the type does not tell us about the exceptions
// potentially thrown here
let fnThatDoublesOrThrows (a : int) : int =
    if a < 5 then
        failwith "A was less than 5"
    else
        a * 2

try
    let doubled = fnThatDoublesOrThrows 1
    printfn "Doubling worked, result is %d" doubled
with
| ex -> printfn "Got exception %A" ex
```

F# offers another, complementory way of reporting errors back to the caller with the Result type. This is a simple discriminated union with two cases, the success and the error case. The nature of discriminated unions requires the user of a function returning a result to specify ways of handling both the success and the error case. The FsToolkit.ErrorHandling library is one of several that adds a few convenience solutions like computation expressions to make it nicer to write code that deals with a lot results, options, results wrapped in async computations and so on.

```fsharp
// The result value tells us the type of the success and the error
// case and all callers will have to explicity handle both
let fnThatDoublesReturningResult (a : int) : Result<int, string> =
    if a < 5 then
        Err "A was less than 5"
    else
        Ok (a * 2)

let result = fnThatDoublesReturningResult 1
match result with
| Ok okValue -> printfn "Doubling worked, result is %d" okValue
| Err errValue -> printf "Doubling failed, err is %s" errValue
```

Just like with null values you have to deal with exceptions anyhow and some people argue that therefore exceptions should be used for all error cases. Others argue that Result should be preferred, maybe even trying to wrap all third party exceptions and using Result pretty much the only way of handling error cases. It seems that most real world solutions fall somewhere in between, dealing with third party exceptions while preferring Result for their own application code.

### Scripts

F# code can either be created as F# projects organized by one or more .fsproj files that are compiled into one library/executable each or an F# script file (usually given the file extension .fsx instead of .fs) can be compiled and executed in one go in scripting mode. For scripting mode there were some large changes with .NET core 5 that came out in late 2020 that radically improved how third party libraries can be referenced and since then it is a lot nicer to use. There are still occasional issues with editor support in script files though.

F# also has a repl that in dotnet core since 3.0 is started with `dotnet fsi`. It can also be used interactively from most browsers so that you can select a bunch of source code and send it to the repl to evaluate and the repl session will retain state until reset.


## Into the future

F# has improved quite a lot these last few years. Four years ago I wrote about early attempts to use F# for both the backend and the frontend of a web application, before the SAFE stack was created. It could be done back then but the developer experience was far from great. Nowadays F# works really well for these kinds of things with all the bells and whistles you'd hope for (time travelling debugger for the state in the web application, hot module reloading, step through debugger for the server code, ...).

What is maybe somewhat lacking is a better repository for solutions to common problems. For JSON serialisation there are at least 5 solutions in F# that all have their pros and cons, but if you want to learn about their relative strengths and weaknesses you have to google it and hope that someone wrote a blog post. There is an F# wikibook that attempted something like this but is quite outdated.

Another thing I hope for is that the F# developer tooling ecosystem becomes more sustainable. Visual Studio and Rider are developed by commercial entities, but FsAutocomplete and Ionide rely on donations via open collective that don't really cover major work on it.

All in all I think F# is a very valuable tool to learn and use. It is ready to use in production for a wide range of problems, and I think it is great fun to use. If you haven't yet then do give it a try and let me know if you run into any issues that you think are worth including here1