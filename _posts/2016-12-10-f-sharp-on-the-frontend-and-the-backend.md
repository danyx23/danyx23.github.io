---
layout: post
title: Using F# on both the frontend and the backend
---
When the call for the [F# Advent Calendar](https://sergeytihon.wordpress.com/tag/fsadvent/) came up I thought that this would be a great opportunity to check out a technology stack that intrigued me for quite a while now: Using F# on the backend (which by now works well on linux/osx as well as windows) and also on the frontend, via [Fable](http://fable.io/), the F# to Javascript compiler backend. I have played a bit with F# in the past but I wanted to see how well this works in practice.

### The same language on the backend and the frontend

Using the same language on the server and the client has many benefits in my opinion, chief among them the ability to reuse data definitions and business logic. Even though many modern web sites shoulder a lot of complexity on the client to guide the user and give immediate feedback, the backend usually has to replicate most of this logic to verify the client submissions and guard against malicious clients. Discount rules are a prime example of such code that is often replicated in both the frontend and the backend.

The first language that will probably come to mind for this job is Javascript. Since the advent of Node, Javascript is available on the backend as well as in the browser, and, with Electron, even for desktop apps with a native feel. Heavy performance tuning has made Javascript reasonably fast. However, I think that its dynamically typed nature makes Javascript a very problematic choice for non-trivial software projects. Static type checking can catch many bugs before they ever hit production and it can free your developers to concentrate on testing the properties of their code that are actually interesting.

A very desirable property for a type system is for it to have Algebraic Data Types. This means that, in addition to Product types (think classes or records) where ALL stated fields exist for every instance, they also support Sum types (Discriminated Unions in F#) where every value adheres to exactly one of several strictly predefined layouts. Together, Product and Sum types allow a much richer modelling where you can make illegal states irrepresentable (see this [recent article by Marc Seemann](http://blog.ploeh.dk/2016/11/28/easy-domain-modelling-with-types/) on the benefits of ADTs). Having Sum types also allows languages to get rid of nulls - a very desirable trait since a big fraction of errors in dynamically typed languages or such with weak type systems are NullReferenceExceptions or the infamous "undefined is not a function".

### Possible alternatives

Ok, now that I have outlined desirable feature, let us look for languages that meet these two core requirements (a strong, static type system with ADTs and being usable via cross-compilation to Javascript on both the browser frontend and the backend). Not a lot of options remain. The ones I know are:

* [Typescript](https://www.typescriptlang.org/)
* [Purescript](http://www.purescript.org/)
* [F#/Fable](http://fable.io/)
* [OCaml/Bucklescript](http://bloomberg.github.io/bucklescript/)
* [Haskell/ghcjs](https://github.com/ghcjs/ghcjs)

All of these are interesting languages. Here is my very personal reasoning for choosing among these languages: Typescript is a superset of Javascript with type annotations that, since version 2.0, has support for union types. It is a big improvement over raw Javascript, but I think that one still feels a lot of the odd language design decisions underneath it, so I will disregard it for now.

The javascript compiler backends for OCaml and Haskell have a relatively small set of Javascript library bindings available and are IMHO harder to interface with native Javascript libraries - for now I don't think that they are immediately usable if you want to write user interfaces with them.

This leaves me with F#/Fable and Purescript. Purescript was designed from the beginning with Javascript as the compile target in mind. Quite a few important Javascript libraries have been annotated with type definitions for Purescript and are thus readily usable, and if they are not, the Purescript FFI was built for Javascript and is very straightforward to use. Additionally, the type system of Purescript is very powerful and feels a bit like a modern refresh of Haskell's type system.

So what about F#/Fable? The basic story is similar to OCaml/Haskell in that you have to create FFI definitions and these are only available for a few libraries so far. What is really neat about Fable though is that there is a way to bootstrap Fable FFI files from Typescript definitions via [ts2fable](https://www.npmjs.com/package/ts2fable) - and those are available for a huge number of important Javascript libraries.

### F# versus Purescript

Purescript is definitely an interesting contender that I want to study more in the future, but this blog post is about F#, so, let us ask the obvious question: why use F# instead of Purescript? YMMV but I see F# to have an interesting advantage on the server side since IMO on the backend the .NET platform is a more solid runtime than Node. Since F# compiles to IL and can interface with any .NET library, it has access to a huge amount of libraries that interface with all sorts of systems, parse files etc. It also supports strong multi-threading primitives and F# even has support to cross compile to the GPU - this makes it much more interesting for numerically intense workloads than Node.

This means that if you either already have a big chunk of business logic written in a .NET language or if you need to do high performance computations on the server, F# is IMO a more attractive choice than Purescript. Additionally, because F# is more in the tradition of pragmatic functional languages like OCaml than the Haskell tradition of that Purescript adopted, it offers the escape hatches of mutability and side effects within the normal control flow (this is arguably also dangerous, but debating this is for another post).

The downside of F#/Fable is that the same language is bolted onto two different runtimes with slightly different semantics. One example of such a mismatch is that the fixed-point arithmetic datatype Decimal of the .NET platform does not exist in Javascript of course and is thus silently converted to a double. For many cases this is fine but it is definitely something to be aware of ([a longer list is here](http://fable.io/docs/compatibility.html) )

Alright, so this is why I think it makes sense to use the same language on the backend and frontend, some of my criteria for choosing a language and why F# is the candidate I want to use.

### The proof of concept code

Let's finally get to some [code](https://github.com/danyx23/FableSuaveSharedCode)!

The basic idea for my little proof of concept was:

* Write a frontend in F# that is the most primitive shopping cart you can imagine - it just has one product and the user can use buttons to increase/decrease the quantity.
* Have a type that defines a discount, consisting of a name, a function that checks whether the discount applies and one that modifies the price. Reuse these data types and functions between the frontend and the backend
* On the frontend, use [Fable-Arch](https://github.com/fable-compiler/fable-arch) to bring the clarity of the [Elm Architecture](https://guide.elm-lang.org/architecture/) to F#
* Bundle up the generated Javascript into an Electron app to see how well this works
* Since the Electron Desktop app is based on the Chromium engine, use the power of CSS and icon fonts to pep up the UI a little by just dropping in some CSS from a third party.
* Try [Suave](http://suave.io) as a http server with a functional design. Reuse the type definitions and discount calculation code. Handle Json-Serialization and CORS headers.

The entire setup is on github at [https://github.com/danyx23/FableSuaveSharedCode](https://github.com/danyx23/FableSuaveSharedCode) where you can just clone it and run both the Suave server and the electron based client.

I'd be interested in hearing about people who already use this stack or are exploring one of the other options on using the same language on the frontend and the backend.

Many thanks to the many great people in the F# universe who keep improving this ecosystem and create examples and blogposts about them - especially [Tomas Petricek](https://github.com/tpetricek), [Scott Wlaschin](https://fsharpforfunandprofit.com/), [Alfonso Garcia Caro](https://github.com/alfonsogarciacaro), [Steffen Forkmann](https://github.com/forki) and [Sergey Tihon](https://sergeytihon.wordpress.com/)!
