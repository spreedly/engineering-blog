---
title: "Apache Kafka at Spreedly: Part I – Building a Common Data Substrate"
author: Ryan Daigle
author_email: ryan@spreedly.com
author_url: https://twitter.com/rwdaigle
date: 2017-02-07
tags: kafka, distributed-systems
meta: Learn how Spreedly chose Apache Kafka to build its next-generation microservices based architecture, and what lessons we learned along the way
---

At Spreedly we’re currently undergoing a rather significant change in how we design our systems and the tooling we use to facilitate that change. One of the main enablers for this effort has been [Apache Kafka](https://kafka.apache.org/), a distributed log particularly useful in building stream-based applications. For the past several months we’ve been weaving Kafka into our systems and wanted to take the opportunity to capture some of our thinking around this decision, how we decided to approach the project, and what we learned (and are still in the process of learning).

This is less an Apache Kafka tutorial – there are plenty of those out there already – and more a discussion of why Spreedly chose Kafka vs. other messaging systems like ActiveMQ or RabbitMQ. What specific use-cases did we have and why does Kafka make sense for us? Of course, a conversation like this  will necessarily include a recap of various Kafka architectural details, but the intent is not to get weighed down in low-level details. From this, we hope you can apply what we've learned to make the most pragmatic choice for your organization.

READMORE

## The past

Spreedly’s main transaction processing system has been around for several years now. “Legacy” in age only, the core system is well-maintained, has excellent test coverage, supports multiple deploys per day, and has reliably processed billions of financial transactions over the course of its life.

![Billions and billions of transactions served](http://cdn.shopify.com/s/files/1/0070/7032/files/mcdonalds.png?7345)

So why change what’s working? As any successful technical organization knows, a system may be operating just as it was designed years ago, but the world around it has changed so much so as to render the assumptions and constraints of that original system obsolete. As we looked towards supporting Spreedly’s growth for the next ten years, and the needs of our customers over that period of time, we realized the current architecture wasn’t going to last forever. We needed to invest in our systems to support a greater level of scale, both operationally and organizationally.

## Goals

One of Spreedly Engineerings’ main values is to be very pragmatic with our technology decisions. “Pragmatism” is often conflated with “stodgy”, which I find to be categorically false. Being pragmatic at Spreedly manifests as being very deliberate, well-reasoned, and thorough. Nothing about that implies using outdated tech or not enjoying the implementation itself.

So what exactly were our goals with this architectural upgrade? We had a few goals across a few different axes:

- Enable a new class of internal and external applications by liberating the data contained within our core PCI-sensitive systems to be accessible by other ancillary systems.
- Increase product delivery velocity by creating a common data substrate upon which all applications can build.
- Allow for orders of magnitude greater processing scale.
- Establish more enforceable areas of responsibility and security across an increasing number of disparate services.

To those well-versed in popular technology trends, you might recognize many of these goals as being classic microservices benefits. However, there’s an additional nuance represented here that imposes some unique requirements on the target architecture – that of a common data substrate.

Having a common substrate for all apps was important to us since, while increasing the number of applications being built affords a certain focus and velocity, it also introduces additional complexity and operational overhead. Instead of blindly creating an unbounded network of microservices, we envisioned a constellation of apps, all pulling from the same source of truth.

![Microservices graph vs. constellation graph](http://share.ryandaigle.com/microservices-vs-constellation.png)

Our goal with this type of architecture is the ability to deliver smaller and more focused services while not exponentially increasing the number of system dependencies.

## Why Kafka?

I have purposely labeled our core infrastructure need as a common data substrate. Not a pipeline. Not a queue. Not a database. This is on purpose.

In the case of a pipeline or a queue, those words imply movement, but also ephemerality. Once a message is put on the pipeline/queue, it moves to some other conceptual location where it is processed and the message’s lifecycle ends. In the case of a database, that implies permanence but also assumes a very static nature to the data. It sits there, safely, but doesn’t go anywhere. It can only be accessed by components local to the database itself. We were looking for a specific blend of qualities – data mobility, resilience, and permanence – for which Kafka is especially well-suited.

It’s often easiest to talk about Kafka with other engineers by starting with “It’s like a queue…”. That may be a good starting point, but I find that to be a disservice to what makes Kafka unique. I won’t go into a detailed description of Kafka here, but it differs from a queue in some very meaningful ways (almost all based on its chosen primitive, that of a [database log](https://en.wikipedia.org/wiki/Transaction_log)).

### Topic indexing & retention

Kafka is an ordered and indexed (by offset) log of data. Unlike a queue which doesn’t provide the ability to traverse the timeline of events, Kafka lets you traverse its message history by index. It may not be apparent at first blush, but this lets you develop a whole new class of applications.

Consider the case when you configure your Kafka topic to retain messages for some X period of time. Any new application that comes online can start processing from the oldest retained message, meaning they have a pre-determined way to read in X amount of history and bringing their state up to par with other components in the system. Also, more generally, this is a really convenient way to bootstrap new systems. With a traditional queue once a message has been delivered to its currently configured listeners, that message disappears.

![Several consumers accessing a shared Apache Kafka topic, all at different offset](http://share.ryandaigle.com/kafka-topic.png)

Additionally, Kafka itself can manage the last delivered offset per consuming system. This relieves consuming applications from the burden of having to know from which point to start consuming (new apps start at the beginning, existing apps start at their last index) and provides a very clean error recovery mechanism.

By exposing the mechanics of an ordered and indexed log, Kafka provides a level of application flexibility not possible with a simple queue.

### Compaction

Kafka not only exposes a flexible retention property, it also introduces the concept of log compaction. All messages in Kafka have a key. Compaction specifies that only the most recent value for a key is kept. So what exactly does this provide us?

![An Apache Kafka compacted topic automatically prunes duplicate entries](http://share.ryandaigle.com/kafka-topic-compacted.png)

This is where the more database-like properties of Kafka come into play. By efficiently storing a large amount of key-based data, and being able to efficiently advance through it, we now have something akin to a distributed index. Multiple consuming systems can process through a single optimized view of all their relevant data. This is an important use case for Spreedly since our primary datastore is a Riak distributed database which doesn’t provide efficient record-iteration functionality. Even if you’re not using a distributed store yourself, having the native ability to automatically compact some dataset is a useful primitive to have available.

### Operational flexibility

This is a less a direct comparison to something Kafka provides vs. traditional message queues, but is worth calling out. Kafka provides an incredible level of operational flexibility. Multiple topics can be configured on the same Kafka instance, each with their own distinct retention, compaction, security, partitioning, access, and replication settings. You can really pack a lot of very specific topic usage onto the same Kafka instance. This is a great quality, since once you have a Kafka instance provisioned, you can slice and dice to the needs of each class of application.

![Independently administer and configure different topics of the same Apache Kafka instance](http://share.ryandaigle.com/kafka-topic-isolation.png)

## The wrap-up

Kafka is a unique tool. It solves for many common system design problems, while also enabling whole new use-cases, and it does so in an exceptionally performant and resilient fashion. Although we have only just begun our use of Kafka, we’ve already learned a ton about its capabilities and how to structure Kafka producing and consuming systems. In true Spreedly fashion, however, expect to see us evolve our position as we become more experienced with operating and using Kafka to power our next generation of systems. We already have a few more posts in the queue about the details of our new architecture as well as some useful patterns we’ve discovered when creating such systems.

If you’re intrigued by Kafka, please make the time to thoroughly read and digest the canonical Kafka introduction post – [The Log: What every software engineer should know about real-time data's unifying abstraction](https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying). It further explains what makes Kafka unique, and the underlying log primitive that shapes so much about Kafka’s function.

If you want to follow along in our Kafka journey, stay tuned for the next post in the "Kafka at Spreedly" series by following our [Engineering Twitter](https://twitter.com/SpreedlyEng) account or by subscribing to our feed (up there, at the top of the page).
