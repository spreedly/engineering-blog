---
title: How do I GenStage?
author: Adrian Dunston
author_email: adrian@spreedly.com
author_url: https://twitter.com/bitcapulet
date: 2016-10-19
---
I’m new to Elixir. And Erlang. And OTP’s GenServer. And GenStage. While I’ve got beginner’s-eye, I’m going to share knowledge for a general audience. So this is a doorknob-simple look at GenStage. With clear examples and *I Love Lucy* references. Enjoy!


## What is a GenStage?
<div style="display:inline; float: right; margin-left: 3em; margin-right: 1em; font-size: small; font-style: italic">
  <img alt="Lucy studies papers" src="/images/how-do-i-genstage/studious-lucy.jpg" style="height: 185px; width: auto;display:block">
  Fun and scalable? Interesting...
</div>

Erlang is a language invented to solve problems in scalable, fault-tolerant, and distributed ways. Elixir is a language built on top of Erlang that makes solving problems more fun. GenServer is an easy-to-use system for making generic server processes in Erlang (and now in Elixir). GenStage is an easy-to-use system built on top of GenServer to set up processing chains and solve the Lucy Chocolates Problem (see below).


## Why would I GenStage?

You’re Elixiring because you have problems that can be split up and run on separate processors, VMs, machines, clusters… planets? (Yes, Elon. Maybe separate planets.) 

**Q: Let’s say your problem can be split into 2 parts. Are those two parts going to run at the same speed?** <br/>
*A: No, probably not. Part 1 is going to run at part-1-speed, and part 2 is going to run at part-2-speed.*
 
### The Lucy Chocolates Problem

For instance, your problem is shipping chocolates. Part 1 is making the treats, and part 2 is wrapping them. As long as your chocolate-wrapper is faster than your chocolate-maker, you’re good. As soon as your chocolate maker is faster than your chocolate wrapper, you have an *I Love Lucy* situation on your hands.

<img alt="Lucy begins wrapping chocolates" src="/images/how-do-i-genstage/lucy1.gif" style="display: inline; height: 185px; width: auto">
<img alt="Lucy is overwhelmed by the speed of chocolates production" src="/images/how-do-i-genstage/lucy2.gif" style="display: inline; height: 185px; width: auto">
<img alt="Lucy desperately stuffs chocolates in her mouth and hat" src="/images/how-do-i-genstage/lucy3.gif" style="display: inline; height: 185px; width: auto">
(Shown here is [Lucille Ball](https://en.wikipedia.org/wiki/Lucille_Ball), legendary entertainer, entrepreneur, and [person-who-saved-Star-Trek](http://www.ew.com/article/2016/07/08/lucille-ball-star-trek).)

### Lucy's Chocolate Twitter-Feed

Let’s look at a real-life Lucy chocolates problem. Maybe you want to: 

1. **pull words from a Twitter feed,**
2. **Google image search them, and**
3. **auto-create a collage of images based on those tweets.**


![From Twitter to Google to image generator](images/how-do-i-genstage/three-steps.png)

Pulling words from a Twitter feed is blazing fast. Google image searching is relatively slow. Photo-editing is glacial. 

If you’re running these things in different processes chained together, it won’t be hard for the Twitter-reader process to overwhelm the image-searcher process which in-turn would lock up the collage-maker. Even if you have a bunch of collage-makers, you’d have to round-robin or find some other algorithm to keep them balanced. If you don’t do it right, you might miss some of the sweet sweet Tweets you desperately need to autogenerate your art. This is the same problem Lucy had with the chocolates.
 
Wouldn’t it be nice to have a way for your collage-maker processes to pull whatever they could handle from your image-searcher processes which could pull what they were able to handle from your tweet-reader?

There is such a way! That’s why GenStage. Because the Lucy Chocolates Problem.


## How do I GenStage?

For right now, I’m going to go over the same stuff that was in the GenStage announcement. If you have that stuff down cold, you can skip to the [Twitter feed example](#twitter-feed-example), scan through, and nod your head sagely.

There are 3 types of GenStage servers: `producer` , `producer_consumer` , and `consumer` . To implement them, you define a module that uses GenStage and create a few callback functions in that module.

Below is the dead-simplest way to set up a three-link chain. It doesn’t even do anything. Producer passes stuff straight through ProducerConsumer to Consumer, which does nothing. It compiles and runs. That’s its claim to fame.

## First Glance

```elixir
    alias Experimental.GenStage
    
    defmodule Producer do
      use GenStage
      def init(arg) do
        {:producer, :some_kind_of_state}
      end
    
      def handle_demand(demand, state) do
        {:noreply, things = [:whatever, :you, :want], state}
      end
    end
    
    defmodule ProducerConsumer do
      use GenStage
      def init(arg) do
        {:producer_consumer, :some_kind_of_state}
      end
    
      def handle_events(things, from, state) do
        {:noreply, things, state}
      end
    end
    
    defmodule Consumer do
      use GenStage  
      def init(arg) do
        {:consumer, :some_kind_of_state}
      end
    
      def handle_events(things, from, state) do
        {:noreply, [], state}
      end
    end 
    
    defmodule Go do
      def go do
        {:ok, producer} = GenStage.start_link(Producer, arg = :nonsense)
        {:ok, prod_con} = GenStage.start_link(ProducerConsumer, arg = :nonsense)
        {:ok, consumer} = GenStage.start_link(Consumer, arg = :nonsense)
    
        GenStage.sync_subscribe(prod_con, to: producer)
        GenStage.sync_subscribe(consumer, to: prod_con)
      end
    end
```

### In Detail

Great. Let’s see the same thing, but with gobs of annotations!

```elixir
## Producer
    alias Experimental.GenStage
```
Development on GenStage is still going gangbusters. It will stay in the Experimental namespace for a while.

```elixir
    defmodule Producer do
```
I could have called this thing whatever I wanted. Maybe I should have called it `JerryBruckheimer` .

```elixir
      use GenStage
```
With this one line, we pull in all of GenServer and GenStage and make this module into an unstoppable data processing machine.

```elixir
      def init(arg) do  
```
Init is a callback that's triggered when you start your process. It takes an arg so you can set up your producer with whatever starting info you want. I don't use the arg here, so I'm going to get a compiler warning.
 
```elixir
        {:producer, :some_kind_of_state}
      end
```
Init needs to return a tuple with an atom and a something-else. The atom has to be `:producer` , `:producer_consumer` , or `:consumer` . That will set some assumptions for GenStage about how this module will behave. The something-else is the state for this server. Like all GenServers, a GenStage module can hold arbitrary data in memory. 

```elixir
      def handle_demand(demand, state) do
```
This callback is what makes a producer a producer. (Well that and the `:producer` atom returned by `init` ). `handle_demand` is called with the number of "things" a consumer is asking for and the state of the producer at the time the consumer asked for them. 

```elixir
        {:noreply, things = [:whatever, :you, :want], state}
      end
    end
```
The return value is intended to look like the return value from an asynchronous GenServer `cast` (or the return value from a `call` you're not ready to reply to yet). `:noreply` indicates that `handle_demand` is not going to send any information back to whatever called it. This is confusing to me because `handle_demand` IS sending back information; the very next item in the tuple. But perhaps since it's not sending information back in the way GenServer usually means, so we’ll let that go. `things` is the list of what-have-you that you’ve produced. 


*Things vs. Events* - Most examples will use the word `events` for this. I don’t here because to me an “event” is a particular kind of thing. You could argue that a “thing” passed to a Consumer is an “event” as far as that Consumer is concerned. And I would see your point. …but I’d have to squint. Anyway, call it events everywhere else, but just for now, I’ll call it things.

Note that the `things` returned here is a list. It has to be a list. It can’t be a not-list. If you try to return something that is not a list, you will get `** (stop) bad return value: {:noreply, :decidedly_not_a_list, :ok}` I want to pause here and note that `bad return value` is not the most helpful error message. Though I will also say that it’s more helpful than `bad cast` .

![Search for bad cast leads to Breaking Bad](images/how-do-i-genstage/bad-cast.gif)

```elixir
## ProducerConsumer
    
    defmodule ProducerConsumer do
      use GenStage
      def init(arg) do
        {:producer_consumer, :some_kind_of_state}
      end
```
We’re starting off pretty much the same way here. I could call the module whatever I want. Note it returns `:producer_consumer` and starting state. Again, `:producer_consumer` sets GenStage’s assumptions about how this thing will work. And state could be the complete works of Shakespeare; though I wouldn’t recommend it.

```elixir  
      def handle_events(things, from, state) do
```
This is the consumer’s main callback function. It takes a list of things (the same list sent by producer’s `handle_demand` above). It also takes `from` which is how we identify where these events came from, in case we need to. We usually don’t. You won’t often be using `from` ; you’ll more often call it `_from` (because underscores denote discarded values which helps avoid compiler warnings). Finally it takes whatever is the current `state` of the ProducerConsumer.


*More about `from`* - In case you’re interested, `from` (right now) is a tuple with the process identifier of the process the call came from and a reference to the request itself. I say “right now” because the GenServer documentation says that the format of `from` arguments may change in the future. So it’s best not to `{pid, ref} = from` if you can avoid it. The request reference seem to be generated by Elixir’s `Kernel.make_ref` . These references are theoretically unique (like GUUIDs, but not really). In GenServer, you can use `from` to reply directly to a request. `GenServer.reply(from, :my_message)` . GenServer makes use of simpler Erlang message passing calls behind the scenes, and tracks all this request reference stuff for you. It’s really cool. Thanks, Erlang.

```elixir
        {:noreply, things, state}
      end
    end
```
ProducerConsumer is supposed to be changing that list of things in some way before passing it along to Consumer. But this one isn’t. Because it’s lazy. Here we return a tuple with `:noreply` ; again I assume because we’re not replying in the traditional GenServer sense. The tuple also has a list (and it must be a list) of things to go to the consumer. Finally, we have the ever-present `state` .

```elixir
## Consumer
    defmodule Consumer do
      use GenStage  
      def init(arg) do
        {:consumer, :some_kind_of_state}
      end
```
By now, we’re pretty familiar with what’s going on here. Or we’ve fallen asleep and scrolled this far with our faces on the trackpad; I won’t judge.


```elixir    
      def handle_events(things, from, state) do
```
Consumer is handling events (with `handle_events` ) just the same way ProducerConsumer does, except…

```elixir
        {:noreply, [], state}
      end
    end 
```
Consumer MUST return an empty list in its tuple. If you return anything else, you’ll get ` [error] GenStage consumer #PID<0.514.0> cannot dispatch events (an empty list must be returned)` This is quite a rebuke! It’s also much more helpful than “bad cast” and “bad return value” both.

```elixir  
    defmodule Go do
      def go do
```
Now what’s this `Go.go()` business? I like using a `go` function in my examples so they don’t automatically run when I use `iex -S mix` .

```elixir
        {:ok, producer} = GenStage.start_link(Producer, arg = :nonsense)
```
Start up a Producer process. Pattern matching with `:ok` ensures everything went well or makes everything crash. Making something crash when things get a little sketchy is good Elixir practice. Elixir is basically a Windows user in the 1990s, hitting restart every time something goes sideways. 

I was skeptical about this practice when I first heard about it. But you know what? I rebooted my way through Microsoft Windows 3.1, 95, 98, ME, and XP. And in-BETWEEN those reboots, I got a lot done. What I’m learning now is that all distributed systems are by-nature as buggy as Windows 3.1 and aspiring to be only as buggy as Windows 95.

```elixir
        {:ok, prod_con} = GenStage.start_link(ProducerConsumer, arg = :nonsense)
        {:ok, consumer} = GenStage.start_link(Consumer, arg = :nonsense)
```
Anyway, we grab `:ok` and the process identifiers for our three GenStage processes. Note I’m passing arguments, because `start_link` expects me to. Those arguments are passed to the `init` functions described way above. But we ignore them. Also note that every time I do something like `arg = :nonsense` , I get a warning about how `arg` isn’t used. I love ignoring variable names with underscore `_` , but when I’m writing examples I want them both descriptive and pretty. 

```elixir
        GenStage.sync_subscribe(prod_con, to: producer)
```
Aha! Now our ProducerConsumer is ready to grab whatever it can from Producer. It doesn’t grab anything because it’s not the final Consumer and so isn’t running the show.

```elixir
        GenStage.sync_subscribe(consumer, to: prod_con)
      end
    end
```
There we go! That’s the final Consumer getting involved. As soon as this happens, Producer gets a call to `handle_demand` . Based on experience, the `demand` argument will probably be 500 that first time it gets called, but don’t count on that. Then ProducerConsumer gets a call to `handle_events` with `[:whatever, :you, :want]` as its `things` argument. Then Consumer gets an identical call to `handle_events` with `[:whatever, :you, :want]` as its `things` argument. Then it does nothing! Because again, lazy.

<a name="twitter-feed-example"></a>
## Twitter Feed Example

Fine! Let’s go back to our earlier example. I want to pull tweets from some feed, Google image search the words, and then use an image manipulator to make collages out of those images. I've put further description in comments below.

![From Twitter to Google to image generator](images/how-do-i-genstage/three-steps.png)

```elixir
    # Let's pretend this library is real
    alias AdriansHandWavingLibrary.{Tweet,ImageSearch,Collage}
    alias Experimental.GenStage
    
    defmodule ReadFromTwitter do
      use GenStage
      def init(twitter_feed) do
        tweets = Tweet.all_to_date(twitter_feed)
        # Note we're setting tweets as the state.
        {:producer, tweets}
      end
    
      def handle_demand(demand, state) do
        # Pull some tweets out of state. We send those as the events
        # or "things", and we reset state to the remaining tweets.
        # @jacobterpri pointed out the existence of Enum.split/2. Thanks!
        {pulled, remaining} = Enum.split(state, demand) 
        {:noreply, pulled, remaining}
      end
    end
    
    defmodule ConvertToImages do
      use GenStage
      # This step still needs no state.
      def init(_) do
        {:producer_consumer, :ok}
      end
    
      # Turn a list of tweets into a list of lists of images.
      def handle_events(tweets, _from, _state) do
        image_lists = Enum.map(tweets, &to_list_of_images(&1))
        {:noreply, image_lists, :ok}
      end
    
      # Do that by splitting the tweets into individual words and running
      # image_for on each word
      defp to_list_of_images(tweet),
        do: tweet
          |> String.split(" ")
          |> Enum.map(fn word -> ImageSearch.image_for(word) end)
    end
    
    defmodule CollageBackToTwitter do
      use GenStage  
      # Set state to the one thing this needs to keep track of: where to post
      # collages.
      def init(output_twitter_feed) do
        {:consumer, output_twitter_feed}
      end
    
      # Get the lists of images, collage them together, and send them back out
      # to Twitter. This is definitely the longest step. There's image manipulation.
      # There's uploading. Then there's tweeting. All of that happens in my pretend
      # modules, but go ahead and pretend. That's a lot of time, isn't it?
      # So if we weren't using GenStage, the CollageBackToTwitter module would
      # require a ton of buffering code. The equivalent of Lucy stuffing chocolates
      # in her hat!
      # Thanks, GenStage.
      def handle_events(image_lists, _from, output_twitter_feed) do
        image_lists
        |> Enum.map(&Collage.images_together(&1))
        |> Enum.each(&Tweet.send_image(&1, output_twitter_feed))
        {:noreply, [], output_twitter_feed}
      end
    end 
    
    defmodule Go do
      def go do
        # Note we're sending the Twitter names to pull from and push to.
        {:ok, producer} = GenStage.start_link(ReadFromTwitter, "@madcapulet")
        {:ok, prod_con} = GenStage.start_link(ConvertToImages, arg = :nonsense)
        {:ok, consumer} = GenStage.start_link(CollageBackToTwitter, "@bitcapulet")
    
        # I'm pretending here that I've tuned this stuff and found the following
        # levels of demand to be optimal. Because, hey look! There are a bunch of 
        # settings on the sync_subscribe function. Rad.
        GenStage.sync_subscribe(prod_con, to: producer, max_demand: 50)
        GenStage.sync_subscribe(consumer, to: prod_con, max_demand: 10)
      end
    end
```

## Obligatory Wrap-up Paragraph

If you have a multi-step, multi-process problem, and later steps may be slower than earlier steps, then consider GenStage. It’s simple, fun, and solves this problem thoroughly.

If you want to learn more about this you can read:

- Fabulous new blog post [Reactive Tweets with Elixir GenStage](https://almightycouch.org/blog/reactive-tweets-elixir-genstage/) by Mario Flach
- Even crunchier example [Using GenStage to Notify a Phoenix Channel of Updates in Elixir](http://learningelixir.joekain.com/using-gen-stage-to-notify-a-channel/) by Joseph Kain
- or the original[ GenStage Announcement](http://elixir-lang.org/blog/2016/07/14/announcing-genstage/)

Thanks so much to José Valim and his cadre of brilliant and charming collaborators for Elixir and GenStage. Thanks also to the folks who’ve posted previous examples, to Lucille Ball (that human was genius), and to Spreedly for being such a great place to work.

