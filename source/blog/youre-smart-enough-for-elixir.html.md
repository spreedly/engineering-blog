---
title: You're Smart Enough for Elixir
author: Stephen Ball
author_email: stephen@spreedly.com
author_url: https://twitter.com/stephenballnc
date: 2016-07-11
---

*A brief glimpse into Elixir from an object oriented perspective.*

> Concurrency is complicated so Elixir must be complicated.

<!-- -->
> Learning functional programming means giving up all my knowledge about object oriented programming.

<!-- -->
> Why Elixir? I haven't needed it so far. It's probably only for really complicated computer science-like stuff that I'm not doing.

If you're looking at Elixir from the perspective of an object oriented scripting language like Ruby, Python, PHP, or even Perl then you've probably read, heard, or made statements like those above. Even if just to yourself.

I'm here to tell you that I've been there. I've professionally programmed in each of those languages over my career. Now I'm coming to Elixir from a recent background in Ruby. Let me assure you — you got this!

READMORE

Elixir seemed like a scary, fascinating, almost unbelievable world. Serving web requests by creating a new server for each individual request? Madness! No data mutation? Isn’t that what data, you know, does? Processes that supervise other processes? How does that even work?

After a few weeks of using Elixir (and some Erlang) nearly full-time at work, I’ve come to realize my conception of Elixir was much more complicated than Elixir itself. In this post I’ll share what I’ve learned about three areas: the complexity of concurrency, what functional programming in Elixir is like, and why Elixir is interesting.

## Concurrency

Concurrency is one of those development approaches that you usually only reach for when you really need to work some magic. The need to scale out is demanding enough that you’re willing to pay the complexity price and take on the risk of getting something wrong. In object oriented programming the danger of ending up with bad (i.e. unexpected) data is very real once you start running things concurrently.

In Ruby you have to start pulling in more complicated objects like [Queue](http://ruby-doc.org/core-2.3.1/Queue.html) and start thinking very hard about all the places in your code that might be trying to update the same data at the same time. If more than one piece of code changes the same data at the same time then you end up with terrible things like race conditions or deadlocks which are no fun at all to debug.

There are some very ambitious projects in Ruby trying to improve the situation but they are hampered by the language itself.


> Without a memory model it's very hard to write concurrent abstractions for Ruby. To write a proper concurrent abstraction it often means to reimplement it more than once for different Ruby runtimes, which is very time-consuming and error-prone.
>
> — [Concurrent Ruby's published memory model](https://docs.google.com/document/d/1pVzU8w_QF44YzUCCab990Q_WZOdhpKolCIHaiXG-sPw/edit?usp=sharing)

What I've learned from Elixir is that concurrency wasn’t the hard problem — Ruby's concurrency was the hard problem. Ruby's shared memory means you have to start sneaking around the language and being very careful in order to avoid problems.

Elixir works differently! It works so differently that it doesn’t even solve the concurrency problems found in Ruby — it avoids them completely. Instead of sharing memory, blocks of Elixir code run in isolated “processes” that only have their own data. Processes can pass data around, but the data is *copied* from one process to another and not shared directly. Beam (the underlying virtual machine running the code) makes copying data between processes very lightweight and memory efficient.

Not sharing data means that processes can be working on the same data at the same time without the possibility of unusual problems. At a fundamental level, Elixir is designed to allow parallel work without demanding that programmers figure out how to ensure the data stays correct.

I’ve found that good design using processes has a lot in common with good design using objects. In object oriented languages, objects should communicate by sending messages to other objects and not editing other objects directly. In Elixir the *only* way processes can communicate is by sending messages.

## Functional Programming

This is the aspect of Elixir I thought was going to be the hardest thing to get. Immutable data? Crazy! But in practice it doesn't really come up. After a couple weeks with Elixir I was surprised to think back and realize I'd never once thought, "This would be easier in Ruby!"

You can think of immutable data as always moving forward. You can't change the data itself, but you can transform it into a new version of the data. That sounds like it would be an expensive and slow process but, yet again, the virtual machine running Elixir steps in and makes all of the low level mechanics work easily and quickly.

As an example, let's have a server process that counts the number of times other processes have sent it the "hello" message. It will internally have a count of hello messages like you would expect. When a new "hello" arrives the data value of count is not changed, the count variable itself is reassigned to a new data value that’s `count + 1` .

Let’s see a bit more of how this works with a simple comparison between Ruby and Elixir.

**Ruby - the array variable is internally mutated**

```ruby
array = [1,2,3]
# => [1, 2, 3]
array.delete_at(0)
# => 1
array
# => [2,3]
```

**Elixir - the array variable is passed through a function that returns new data**

```elixir
array = [1,2,3]
# [1, 2, 3]
List.delete_at(array, 0)
# [2,3]
array
# [1, 2, 3]
array = List.delete_at(array, 0)
# [2,3]
```

In Ruby we see that the `array` variable is mutated when we call `delete_at`. See how the `delete_at` method is actually part of the data itself. That’s a very common idea in object oriented languages and one of the key differences between object oriented and functional programming.

In Elixir note that the “delete_at” functionality is not a method on the data itself. The data is instead passed through a higher level function that returns the new version of the data. We could decide to assign the new version of the array to the `array` variable, but even then the *data* `[1,2,3]` is not mutated. Think of `array` as a label that we’ve told Elixir to remove from the data `[1,2,3]` and apply to the data `[2,3]`.

*As a side note: Elixir doesn’t actually have arrays like you’d expect from Ruby. It has “lists” of data that are actually quite different. But let’s stay on target.*


## Why Elixir?

You don't *need* Elixir. Any modern language can fit any number of problems. It’s not that some things aren't possible without Elixir, but that Elixir makes some traditionally hard things easy.

Consider an example: Elixir provides the concept of *Supervisors*. These are processes monitoring other processes, restarting them with their initial state if they crash. Supervisors are configured with rules for how many crashes are allowed per time period. If the watched processes pass that threshold, the supervisor itself crashes and the failure handling moves up a level.

Just think of all the concepts that the configuration of a supervisor entails. You give a supervisor rules like "this watched process is allowed 2 restarts in 30 seconds". You don't need to write any time checking code or counting logic! The virtual machine running Elixir handles all the details of actual time tracking. Time aside, even the concept of watching another process and getting notification if it crashes would be difficult in many languages. In Elixir it's as simple as calling `Process.monitor`.

Layered supervision is one of the key components that allows Elixir applications to reach extremely high availability targets. A well designed system can tolerate failures of its components without itself crashing.

Because process supervision handles the error states it means you can (and should!) write functions that are *only* concerned with the happy path. You write code that is focused on what should happen and for anything else you let it crash.

Well-behaved Elixir applications don’t assume failure will never happen. Rather, making decisions about failure is built into the language. This goes far beyond exception handling which only allows catching one failure across one block of code. Elixir supervision means a system can fallback to a wide range of working states to keep core functionality available even as networking errors, buggy code, and other real-world problems creep in.

All Elixir processes run on a virtual machine called BEAM (popularly called the Erlang VM). That layer allows the language processes to be optimized in some helpful ways. Because processes involve no shared memory, the Erlang VM can run them on many CPUs or cores in parallel. The Erlang VM also transparently handles networking, so Elixir processes pass messages between each other using the same syntax whether they’re running on the same machine or on multiple machines. Those two features means Elixir can handle both vertical and horizontal scaling. Even better, the Erlang VM can handle much of the scaling process without demanding applications be rewritten specifically to support scaling.


## Elixir: a lot of fun!

By far the aspect of Elixir I love the most is that it's so much fun to write. José Valim, Elixir’s creator, has done a fantastic job of combining a lot of great ideas from a lot of languages. Beautiful declaration syntax from Ruby, list comprehensions and doctests from Python, and of course all the good ideas from Erlang, like pattern matching.

Process supervision means processes can focus on the happy path and let failures be handled at a higher level. Writing less error handling and checking logic is something I’m sure we can all enjoy. It's also rewarding to see all the CPUs in a system working together to efficiently perform a dozen calculations on the same set of data.

Would you like to write clear and readable code that doesn't need to jump through convoluted hoops to run in parallel? If so give Elixir a try! I hope you enjoy it.


## Resources for learning Elixir

- The [Elixir Slack](https://elixir-slackin.herokuapp.com/) is full of helpful people and beginners are very welcome
- [Elixir in Action](https://manning.com/books/elixir-in-action) is a very good introduction to Elixir
- The [DailyDrip Elixir topic](https://www.dailydrip.com/topics/elixir) is a great introduction to many different aspects of Elixir
