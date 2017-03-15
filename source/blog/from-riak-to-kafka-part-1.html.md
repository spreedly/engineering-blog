---
title: "From Riak to Kafka: Part I"
author: Stephen Ball
author_email: stephen@spreedly.com
author_url: https://twitter.com/stephenballnc
date: 2017-03-15
tags: riak, erlang, kafka, distributed-systems
meta: How Spreedly integrated Apache Kafka into our data infrastructure. This post focuses on how we engineered data to be automatically sent from our Riak Database to Apache Kafka.
---

In [Apache Kafka at Spreedly: Part I – Building a Common Data Substrate](/blog/apache-kafka-spreedly-part1-building-common-data-substrate.html) Ryan introduced the place Kafka will take in our infrastructure. In this series I'll describe the implementation details of how we're reliably and efficiently producing data from Riak to Kafka.

READMORE

## Spreedly's Data Architecture

At Spreedly we use Riak as our permanent data storage. Riak is a key/value store that provides high availability of both the service and the data. As a key/value store it's very fast at giving you the value if you have the key, but is not well suited to finding arbitrary values by the data they contain. To address that drawback we use Postgres as an indexing layer. Postgres is given the same set of data and indexes fields to support later queries. Each new piece of data is simultaneously written to both Riak and Postgres.

![Spreedly's permanent storage data architecture](/images/from-riak-to-kafka-part-1/architecture.png)

## Adding Kafka to our Data Flow

We need to find a good way to incrementally introduce Kafka as a data substrate. We saw two potential options:

1. Write to Kafka directly from our application layer
2. Write from Riak to Kafka

![Options for incorporating Apache Kafka into Spreedly's Data Architecture](/images/from-riak-to-kafka-part-1/writing-options.png)

The first option of adding Kafka as a new top level data layer component would put all the change work into the application layer. The second option of adding Kafka as a child data layer component of Riak would put all the change work into the data layer. Given that one of the major goals of this effort is to reduce our application complexity we opted to prefer the Riak integration if it proved viable.

Our early spikes proved that connecting Riak to Kafka was indeed technically possible. Riak allows configuring postcommit hooks that will be called with any newly written or deleted data.

Postcommit hooks are called after any successful write, don't block the response to the client, and are directly given the entire key/value object. A postcommit hook would be the perfect place to have Riak write the data into Kafka. As a primarily Ruby shop the downside was that the Riak postcommit hook had to be written in Erlang.

## Writing to Kafka directly from Riak

After some spin up time to get a footing in Erlang, it turned out that writing an Erlang function to receive the data and send it to Kafka turned out to be straightforward. Our first function was very simple: receive data, connect to Kafka, produce data, done.

![Data flow diagram for producing to Apache Kafka from Riak](/images/from-riak-to-kafka-part-1/riak-to-kafka.png)

Not too surprisingly, when we measured performance it was clear this approach wouldn't be acceptable in production. The overhead of the hook receiving the new data, then connecting to Kafka, and then producing the message was too inefficient. We'd be paying the cost to setup a TCP connection to Kafka for every individual message that we produced. We needed to find a way for the connection to Kafka to persist outside of the postcommit hook and be reused for each message.

## Reliable Message Delivery

We found we could have Riak start a Kafka client during its boot process that would maintain a persistent and fault-tolerant connection. Now every single piece of data could reuse the same connection to Kafka. Performance issue solved!

After more experimentation we realized that the simple approach of producing to Kafka directly from the postcommit hook was not going to serve us very well. There were simply too many ways for the communication between Riak and Kafka to break down and cause any individual message to fail. Our postcommit hook would need to be smarter and retry delivery if Kafka is unreachable for some period of time.

The straightforward solution would have been to have postcommit hook take on the responsibility of retrying delivery to Kafka until success or some eventual timeout (e.g. five minutes). But that has some problems. As robust as Riak is operationally, it does have its limits. One of those limits is that it only allows a finite number of writing processes (such as the postcommit hook) to be active at any one time. Normally we're nowhere near close to that limit, but if we were to start having processes potentially take minutes instead of milliseconds then we'd introduce the risk of running into that limit. Riak postcommit hooks are also simple functions without a robust support system. If they error out for any reason they have no infrastructure to try and re-run them.

We could have potentially dealt with both of those issues but the cost would've been an increase in complexity of the postcommit hook as well as our Riak configuration. We decided a better approach would be to build a new system component that would own the responsibility of producing messages to Kafka. This would allow the postcommit hook to remain focused on the simple path and require no complex alterations to Riak.

![An unknown new component in Spreedly's data flow for producing to Apache Kafka](/images/from-riak-to-kafka-part-1/new-system.png)

## A System Outside of Riak

We needed a way to produce messages to Kafka that could tolerate Kafka being unavailable. Ideally each message could have its own lifecycle and make delivery attempts before succeeding or giving up after some long term timeout. The system would also need to give a response to the postcommit hook so that the hook would know if it should throw an error or consider the message as passed off successfully.

Erlang provides a framework called OTP that's used for building systems that robustly handle synchronous and asynchronous requests. Exactly what we need for this system!

We made a few attempts to reasonably integrate an OTP system into Riak. After all, Riak runs in Erlang and it seemed reasonable to bring up another Erlang system alongside it. That approach might have been technically doable, but would've added too much complexity to our Riak setup. We needed to bring up a new system, separate from Riak.

The external system would need to do three things:

1. Be callable from the postcommit hook
2. Respond to the postcommit hook with success or failure
3. Have high availability and good fault tolerance

It was clear that OTP would be a great fit to the problem. The only issue was the complexity of building an OTP system directly inside of Riak.

Elixir to the rescue! An Erlang system can directly communicate with an Elixir system using exactly the same OTP communication functions we wished to use. An Elixir system is an Erlang system once it's running. We already had an interest in using Elixir for new services and projects so using Elixir for this system fit our goals very nicely.

A quick spike in Elixir proved that, yes, our Riak nodes would absolutely be able to communicate with an Elixir OTP application. We spun up that project as the “commitlog”.

![A data flow diagram showing the new "commitlog" component that will produce to Apache Kafka](/images/from-riak-to-kafka-part-1/commitlog.png)

## A Simplified Postcommit Hook

With the commitlog concept in place, the postcommit hook could switch back to the simple job of sending messages to an external system. The big difference is that the commitlog is now that external system and not Kafka directly. We can do our utmost to ensure that the commitlog remains highly available to the postcommit hook and the commitlog system takes on the responsibility of ensuring messages reach Kafka.

The refocused postcommit hook does three things:

1. Transforms the new data into a message formatted for the commitlog
2. Sends the message to the commitlog
3. Times and records how long it takes to communicate with the commitlog

At each step, the postcommit hook handles failure and is ready to log enough data to allow us to queue the same data again. If you'd like to check out our approach we've open sourced [our Riak postcommit hook repository](https://github.com/spreedly/riak-postcommit-hook). The [src/postcommit_hook.erl](https://github.com/spreedly/riak-postcommit-hook/blob/master/src/postcommit_hook.erl) file is the Erlang source of the hook itself.

Next time we'll dive into the commitlog and walk through our design choices to create an Elixir OTP system that allows each individual message to be responsible for producing their own data to Kafka.
