---
title: "From Riak to Kafka: Part II"
author: Stephen Ball
author_email: sdball@gmail.com
author_url: https://twitter.com/stephenballnc
date: 2018-02-26
tags: riak, kafka, elixir, distributed-systems
meta: How Spreedly integrated Apache Kafka into our data infrastructure. This is the second post focusing on how we engineered data to be automatically sent from our Riak Database to Apache Kafka.
---

In [From Riak to Kafka: Part 1](/blog/from-riak-to-kafka-part-1.html) I explained how we started to integrate Apache Kafka into our data storage pipeline at Spreedly. Where Part 1 leaves off we’d decided on a relatively simple Riak postcommit hook that would call an Elixir service called the “commitlog” with every new piece of data stored in Riak. The commitlog Elixir application would be responsible for ensuring data given to it either reached Kafka or was appropriately logged to be recovered and replayed later. Let's dive into the architecture of the commitlog and some of the design choices we made along the way.

READMORE

## Recap

Here’s the data flow diagram that we stopped with at the end of Part 1.

![](/images/Photo-2018-02-23-14-08-ZkJ4U2D9jhX.jpg "Data flow from Riak to Kafka")

We had a postcommit hook ready to go that would send data using the Erlang GenServer API to an Elixir process called the “commitlog”. The commitlog would be responsible for accepting the data and reliably delivering it to Kafka or logging its failure to do so (yes, you can send binary-compatible data from an erlang process to an Elixir process!).

Now we’ll dive into the commitlog itself and see how it guarantees that messages will either reach Kafka or be logged as an error for later replay. At the time of this writing the commitlog has processed just over 4 million messages in the last 24 hours!

## The power of OTP processes

The key to the commitlog’s reliability is the Erlang/Elixir OTP framework. OTP is built into the Erlang/Elixir languages and provides a means for declaring internal processes that can send and receive messages with a common API as well as a means for supervising those processes to ensure they are available.

There are several conceptual layers of supervision in the commitlog - it’s probably best to visualize them. Here’s how the pieces fit together:

![](/images/awb9e-20180226105116.png "Commitlog supervisor hierarchy")

Let’s take a look at each of these major pieces of the commitlog.

* The Commitlog application kicks everything off and also has some high level functions for logging various events (e.g. message timed out, message successfully delivered, etc)
* brod is the Kafka client. It is responsible for the actual communication with Kafka: accepting messages and producing them to a topic/partition.
* The Commitlog Supervisor is that special kind of process that starts and monitors its child processes: the Commitlog Receiver and the Message Supervisor.
* The Commitlog Receiver is the process that accepts data from the Riak postcommit hook. If the system is not at maximum capacity then it sends the data along to the Message Supervisor. If the system is at its configured limit for active Message Workers then it instead immediately logs the data as a failed delivery that will need to be requeued later.
* The Message Supervisor starts a Message Worker per individual piece of data and provides a function that allows the Receiver to query for the number of Message Workers that are already active.

Via OTP every individual aspect of the system is monitored. If any one component crashes it will be restarted with its original state per declared timing rules. For example the OTP default allows a process to crash and restart three times in five seconds. If that limit is exceeded the supervisor process itself crashes and depends on its supervisor to either restart it or crash as well.

This “supervision tree” of monitoring is the key to the reliability of an OTP system. For example, an individual message worker is given the data that it is responsible for delivering to Kafka. If something unexpected happens with the Kafka API (brod) it’s entirely possible that the message worker will not know how to handle the failure and crash. The Message Supervisor will detect the crash and, if the worker is still within the declared limits, restart the worker with the same data it initially started with.

If the unexpected issue with the Kafka API is temporary, say an unexpected network response, then this try/fail/restart cycle will allow the worker to eventually accomplish its goal and stop normally.

## Lightweight processes
The approach of spinning up a process for each piece of data going to Kafka means we get to take advantage of OTP’s sophisticated timeout and process monitoring. Rather than being a simple call to an API, the Message Workers track their own metrics and have internal logic to handle delivery retries for a variety of common conditions.

Coming from object oriented programming spawning a process per message seems very foreign. Aren’t processes expensive?! Well…no! The key is that the Erlang VM makes spawning processes, even complex processes, very cheap. A good equivalent is to think of an OTP process as roughly same amount of computational work as instantiating an object in an object oriented language.

What are the drawbacks to delivering data via workers? The biggest drawback is that the data has absolutely no guarantee of any ordering. The individual data objects stream into the Commitlog from Riak then fan out from the Commitlog Receiver into Message Workers that are each individually attempting their own deliveries with zero coordination between each other. In Spreedly’s case, that’s just fine because the nature of our entire data infrastructure is built to tolerate the idea of eventually consistent data.

## Essential Metrics
Along with actually delivering data to Kafka, the Commitlog is also responsible for reporting metrics data. For a key component like this it is absolutely critical to monitor and graph the four golden signals of API health: latency, traffic, errors, and saturation.

Latency we track by having postcommit hook report the time it took to send data to the Commitlog and receive a confirmation.

![](/images/Photo-2018-02-23-14-27-Hqg4DuW3QXt.jpg "Time to produce to the commitlog from the Riak post-commit hook")

Separately we have the Commitlog report the time it took to actually deliver the data to Kafka.

![](/images/Photo-2018-02-23-14-29-6L4qhTLTcGN.jpg "Time to send data to Kafka")

Traffic is a simple count of messages sent to the Receiver and errors are tracked by both the postcommit hook and the Commitlog. They each increment their error count if they are unable to pass the data along.

![](/images/Photo-2018-02-23-14-36-s8PLUu7RRtb.jpg "Whew. Zero errors.")

Saturation is where the count of active messages comes in. If there’s a network problem and Kafka is temporarily unavailable then we see a surge in the number of active messages as they buffer up while attempting to deliver to Kafka.

![](/images/Photo-2018-02-23-14-38-cfM8FObYsCZ.jpg "Saturation as measured by number of messages currently buffered in commitlog")

## The Future
With the postcommit hook and Commitlog in place we have our primary data store, Riak, sending all new data into a Kafka topic.

In future engineering blog posts we’ll describe how we’re using the stream of essentially realtime data to build services that would otherwise not be practically possible such as [Spreedly Open Data](https://data.spreedly.com) and our suite of customer dashboards. This is an exciting time for data at Spreedly and we have some very exciting projects in the works!
