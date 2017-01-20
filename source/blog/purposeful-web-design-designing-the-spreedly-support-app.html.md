---
title: Purposeful Web Design—Designing the Spreedly Support App
author: Dane Wesolko
author_email: dane@spreedly.com
author_url: https://twitter.com/DanesBrains
date: 2016-10-06
---

![Spreedly support app open in a browswer window](images/support-app/support_app.jpg)

As the Lead Designer at [Spreedly](https://www.spreedly.com/) I am fortunate (and excited) to work on many different types of projects. I was recently involved in designing our new [Support App](https://support.spreedly.com/). It’s a place where users can find answers to common support issues and do some basic debugging on their financial transactions. In this article I share insights into my process and some of the steps that were involved along the way.

READMORE

I am a big fan of the design methodology behind Jeff Gothelf’s [Lean UX](http://amzn.to/2afYWF2). If you haven’t read it - check it out. Short read, easy to understand, and has a lot to do with my thinking behind the process that went into designing [Spreedly](https://support.spreedly.com/)’s support app.

Lean UX focuses on the idea of creating whats called an MVP (minimum viable product). It’s a way to quickly design, build, ship, learn, and iterate on your initial assumption. Precisely what I set out to do when working with the engineering and support teams on this project.

Before I could begin designing anything, I had to get to the core and understand what we were building, why we wanted to build it, and the problems that it would solve.

## Understanding The Problem

I’m inquisitive by nature (it’s a requirement of the craft), so I was thrilled to dig deep into why we were building this support app. I needed to understand what problems we would be solving and what goals we hoped to achieve from this project. Both the business and the users’ perspectives.

![Open sketchbook showing sketches from the design process involved in creating the support app.](images/support-app/planning.jpg)

My design research began with querying teammates and stakeholders about their intentions. I found that customers were having to wait too long, and support reps were having to spend time on, basic debugging that was out of our control anyway.

Ultimately, we were solving the problem of accessibility for our customers, so they could easily access support related knowledge where they would find answers to their questions. But, we were also solving the problem of resource allocation, so the support team would be able to do their jobs better by focusing more on heavily weighted requests.

In doing so, we were aiming to see a reduction on support related costs, and increased customer satisfaction for support related incidents.

## Planning The Approach

With my newly gained insight, the intentions behind the development of this project, a clear understanding of the problems we would solve, the benefits we would provide, and the goals we aimed to achieve, I was armed to begin materializing ideas.

![Open sketchbook showing sketches from the design process involved in creating the support app.](images/support-app/support.jpg)

The main content that we were focusing on in our first release was:


- Popular Support Questions
- System Status
- Contact Support via -
  - Live chat
  - Email
- Documentation
- API Reference

The need to separate the primary content, Popular Support Questions, from from the secondary content drove my focal point of the design and layout of the app. However, I needed to consider future MVP’s as well, and make sure that my ideas would align with later releases and the addition of new features and content. I achieved this by visualizing every aspect in its own individual box, and contemplating how each box might move around in a flexible layout.

![Open sketchbook showing sketches from the design process involved in creating the support app.](images/support-app/mvp2.jpg)

Our second MVP focused on allowing the user to debug their own transactions by entering a transaction token and querying the results. Since the initial design considered future enhancements it was really easy to add this feature into the project. Also since this add-on was a major user feature it was super simple to slide the search right on top as the main content block.

I like to begin the materialization of my ideas with sketches. For me, a pen and piece of paper are the best tools for the job. They allow me to get my ideas out quickly without having to worry about virtually anything. If I mess up, I just scribble it out or throw the paper away. When I am sketching, I can try out all different types of possible scenarios, think through processes like interactions, user flows, and other things I may have overlooked in my initial brainstorming sessions.

![Photograph of laptop shwoing wireframes.](images/support-app/ux_team_of_one_wireframing.jpg)

From there, I am usually able to find a pretty solid direction before I move into wire-framing. I like to wire-frame for most things - not everything - but in this case, I thought it would be important. For starters, I needed to share my vision to the team and make sure it aligned with theirs. I also needed a way to get feedback early on, and a way to ensure I considered all aspects of the project before diving into any prototyping.

## Building The Prototype

The fun doesn’t end once all the sketching and wire-framing is done. The real fun begins once prototyping starts. That’s when it’s time to find out if all the ideating actually holds water. You also discover the few things that were missed along the way. Using the wire-frames as a road map, it was time to get cranking.

![Open sketchbook showing sketches from the design process involved in creating the support app.](images/support-app/designing_in_the_browser.jpg)

Developing the prototype was as simple as creating  `HTML`  templates and `SCSS` documents - with a bit of `Javascript` mixed in. The creation of templates allows for sections to be broken down into modular blocks of content. For example, the site’s header and footer are global elements that get repeated. So by creating a simple template for each I could build them once and inject them into the final document with one line of code. This also helped for different page states and views. Since some of the layouts would change and different elements needed to be swapped out.

![Screenshot of the support app being debugged for responsiveness.](images/support-app/debugging_interactivity.jpg)

I did run into some tiny issues when creating the breakpoints and trying to get the information to render properly, but also flow correctly, when viewed on mobile. For some strange reason, the accordion tabs didn’t want to play nicely, so it took a little coercing. But, in the end, we were victorious.

## Shipping A Usable Product

Certainly, one of the most gratifying feelings is when a project is completed and the product is shipped for deployment. Not only do you get to enjoy the fruits of your labor, but you’ve also released something into the wild. Something that people are going to use to solve their problems.

![Screenshot of the support app open.](images/support-app/how_can_we_help.jpg)

Our initial approach was to chunk out the ideas and features into small manageable tasks which we broke down into our MVP’s. It was important that we remained focused on the initial problems we were solving, providing our customers with a support knowledge base, and reducing the support teams workload.

The first release simply focused on information as its main feature. It was a simple approach that would alleviate some of the customers pain points and arm them with the necessary information to getting their questions answered. Our second release focused on empowering the users to debug their own transactions and find out next steps they can take towards a resolution.

Designing and developing Support App is a large undertaking but we hope that as we progress with each step and release new MVP’s out into the wild they continue to improve our customers experience.
