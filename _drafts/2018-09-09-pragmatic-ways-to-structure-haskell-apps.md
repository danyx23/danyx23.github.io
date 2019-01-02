---
layout: post
title: Pragmatic ways to structure Haskell apps
---

This August I attended [Busconf](), a great un-conference about functional programming in Germany. At this un-conference, Tom held a session on pragmatic Haskell that was great and I wanted to write about the technique he showed to structure apps in Haskell.

Let me start with the motivation for using this technique: one of the nice features in Haskell is that you can discern pure and side effectful functions at the type level. If you start out writing Haskell, some functions will live in IO while others will be pure and that is a perfectly fine setup. But once the app grows, it would often be nice to have a more nuanced way of understanding the requirements/capabilities of a function when looking at its type signature. Instead of a binary distinction of pure/side-effectful it might be nice to know "will perform network communication but not file IO" or something like this. The main way of doing something like this (that I knew of) is to build Monad Transformer Stacks where you nest Monads that can contain other Monads. The downside of this is that if you do this for more than a few levels deep, it becomes cumbersome (because you need to chain lift calls depending on the depth of the monad transformer you want to use for a given function). Changing the makeup of the Monad Transformer Stack means you have to touch a lot of code, even if the changes are trivial.

This is where this alternative technique comes in - the basic idea is that you:
    1. use typeclasses to define capabilities
    2. provide an implementation of these typeclasses for your relatively small "application" monad transformer stack and
    3. write your side-effectful functions not in the full app monad, but instead in a polymorphic monad `m` that you constraint to implement precisely the typeclasses that this function needs to operate

Here is a concrete (toy) example of what this can look like:




If you are not familiar with un-conferences, the idea is that there is not a fixed schedule of talks, but that instead the attendees come together in the morning and announce what they would like to talk about or discuss. I really enjoyed Busconf this year and can recommend attending it if you are interested in functional programming.
