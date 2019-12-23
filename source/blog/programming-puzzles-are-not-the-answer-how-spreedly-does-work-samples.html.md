---
title: Programming Puzzles Are Not the Answer
author: Ryan Daigle
author_email: ryan@spreedly.com
author_url: https://twitter.com/rwdaigle
date: 2016-06-10
tags: hiring
next_label: Want to understand more about the philosophy that got us thinking about work samples in the first place?
next_path: /blog/stop-hazing-your-potential-hires.html
---

*A guide to creating fair and effective hiring work samples.*

It’s a common topic of discussion amongst technical organizations that the traditional, in-person, conversation-based, interview process for developers is [flawed](https://www.wired.com/2015/04/hire-like-google/). The conventional process does not measure a candidate’s ability to perform the job in question, does not result in more successful hires, and allows for implicit bias. As a result, many companies use an interview process based on programming puzzles: one-time exercises that test a candidate’s ability to solve a specific, well-known problem.

While this may be a step in the right direction, it’s still a hugely biased and ineffective approach to hiring. In this post I explain how we do hiring at Spreedly and, specifically, how we measure a candidate’s competence using job and company specific work samples.

READMORE

## What’s wrong with programming puzzles?

If you’ve ever been asked as part of the interview process to code a B-Tree data structure, or to binary sort an array, or develop a game of tic-tac-toe, then you’ve been given a programming puzzle. Programming puzzles are generic development tests that are often timed, or even worse, administered on-site during the interview process. There are several flaws with this approach, including:

- The puzzles themselves are heavily biased towards people with formal computer science education. Right away this cuts out many talented individuals coming from non-traditional backgrounds and kills any semblance of inclusiveness.
- Being timed or tested applies a certain amount of pressure to the candidate, which can drastically reduce their ability to think and put their best foot forward.
- The puzzles are not a reflection of the work the company actually does, and do not indicate a person's ability to contribute to the team.

The coding part of an interview process should be indicative of the candidate’s potential role and should be conducted in a working environment that most closely resembles the company’s environment. Timed programming puzzles miss on both counts.


## An alternative: Work samples

At Spreedly, work samples are our preferred method of measuring a candidate’s technical abilities. We think they address many of the shortcomings of generic programming puzzles, with minimal trade-offs.

What does a work sample at Spreedly even mean? Simply put, a work sample is an objectively and blindly graded domain-specific development task that the candidate completes on their own time. If you’re applying to a payment service company like Spreedly, you might expect to have a work sample dealing with some part of the payment processing flow. If you were applying to a platform provider, you might be asked to design a prototype version of a request router within well defined constraints.

> Work samples should be a reflection of what the company does and how they do it. They are as much about the candidate measuring the company as the company measuring the candidate.

Work samples will, necessarily, vary greatly between companies - and that’s the point! They should be a reflection of what the company does and how they do it. They are as much about the company measuring the candidate as the candidate measuring the company. We’ve spent a lot of time at Spreedly both identifying and refining work samples for all levels of our engineering positions (and even across the org) and think we’ve identified the key characteristics of a good work sample.


## Choose a relevant exercise

One of the most important qualities of a work sample is that the task the candidate is being asked to complete is one that is indicative of the actual work they’ll be doing if they were hired. The scope of the task will, of course, be much less than what they might encounter once hired, but it should be taken from actual work done within the group the candidate is applying for.

For instance, Spreedly provides API integrations to over a hundred payment gateways, contributing to and maintaining the ActiveMerchant library in the process. Our [main work sample](https://gist.github.com/rwdaigle/e680696cf8078cbde5cc) is to actually create an ActiveMerchant adapter to a mock payment gateway. This is a real thing our development group does on a regular basis, and not only does it let us evaluate a candidate against a very well known deliverable, it also gives the candidate a sense of what happens inside the company.

[![Spreedly Active Merchant work sample instructions](/images/tperf-20160707152827.png)](https://gist.github.com/rwdaigle/e680696cf8078cbde5cc)

Some companies have work samples that are prototypes of a project that might actually ship someday. While this certainly satisfies the relevance criteria, we think it sends the wrong signal of asking a candidate to work for free. Our work sample is clearly something that will never make it to production (it’s a fake gateway, after all) and it shows that we’ve invested quite a bit of effort ourselves setting up this hypothetical integration.

A relevant but hypothetical work sample, not programming puzzles, ensures a real test of the candidate's ability to do the job and keeps a shared, symmetrical, sense of investment between the company and the candidate.


## Objectively measure the submission

Before your first candidate completes their work sample, you should already have the grading criteria determined. There’s a lot that goes into grading a work sample, but the main factors to keep in mind are that you want the grading process to be blind, and the criteria to be both granular and objective.

The criteria by which you grade each work sample should be determined alongside the creation of the work sample itself. Write down at least three axes by which you want to measure candidates and craft the work sample to specifically address each axis. Common axes for developer positions might include technical ability, attention to detail, ability to follow existing patterns, and written communication. What does your company value? The answer to that should be clearly reflected in the work sample.

Within each axis you want to aim for at least three specific grading criteria. Any less than ten total criteria (across all axes) and there’s not enough separation between candidates to properly rank multiples candidates within the same hiring round. These criteria should be structured as close to a yes/no determination as possible - this ensures consistency across graders. Here’s an example of some grading criteria from one of our work sample submissions:

![Work sample grading criteria](/images/dpr8d-20160610104535.png)

Determining what a passing grade is from your initial set of 10+ criteria is something that should be refined over time. However, a great way to establish a baseline is to give the work sample to a few of your existing employees! Take the average of their grades, reduce it by *at least* 25%, and make that the starting threshold for new employees (there’s a lot of subjectivity here, so be flexible in the beginning and take a critical look at how realistic your criteria are for somebody with no domain knowledge).


## Use a blind grading process

If objective grading ensures that our evaluation is consistent, blind grading ensures that our own biases don’t become a factor in hiring.


> If you are not explicitly removing bias from your hiring process, you are complicit in its propagation

Whether acknowledged or not, we all bring our own biases to the interview process. If you are not explicitly removing bias from your hiring process, you are complicit in its propagation.

At Spreedly, the person that is managing the hiring process (and is communicating directly with the candidate) adds the anonymized work sample to a hiring GitHub repo and creates an issue with the grading criteria checklist. Only once the grading has been completed, and its results confirmed from other team members, is the candidate’s application evaluated.

![Blind grading process issue tracking](/images/4yug9-20160707153215.png)

We recently had a hiccup where I incorrectly created grading issues for three different candidates *using the same work sample*. After realizing the mistake I looked to see how the three graders processed their work samples and they had all come to the same numerical grade (out of 33 criteria)! This was great validation that blind grading with well defined criteria can result in unbiased and consistent evaluations.

## Ensure candidate-friendly environment & expectations

So much of how productive we are is determined by our work environment. Unless your company has a very rigid environment (I’m thinking extremes here, like a financial trading desk), let your candidates complete the work sample in their own time and without any time boundaries (a take-home sample). This lets them work on the sample when and where they’re most comfortable. Don’t make assumptions about people’s lives and what other constraints they may have that prevent them from getting big chunks of focused time.

One thing to be explicit about is time expectations. You don’t want your candidates to be spending 20 hours on a work sample you think should only take two. However, you also do not want to pressure candidates into thinking it’s a timed sample. This is a balance that’s hard to make and, frankly, an area we’re still refining. Our approach has been to say something to the effect of “This work sample was designed to take no more than 4 hours of your time. However, how much time you take is up to you and is not part of the grading criteria at all.”

As you receive work sample submissions, be sure to check with candidates on how much time they actually spent, still being sure to reinforce that their answer is not part of the grading. If your candidates are regularly spending more time than you expect, it’s time to reduce the scope of your work sample (this is something we’re in the process of doing for junior-level candidates).


## Some final tips

There are a lot of details when it comes to work samples that can make life easier for you and your candidates. For the sake of brevity, here are some tips:


- Make candidates submit their work as a GitHub repo, Gist, or some other URL-linkable form. While not a concern initially, automation will make life much easier as your candidate pipeline grows. Having submissions accessible via URL (instead of buried in email somewhere) will make them retrievable by simple grading scripts or apps. All our high volume work samples at Spreedly can be downloaded, committed to the hiring repo, and assigned a grading issue with the grading criteria already filled in as an issue checklist via a simple script that looks something like this: `$ am-submission 0045 ~/Downloads/0001-Added-awesomesauce.patch`
- There should be no ambiguity when it comes to work sample instructions. Be very clear with your submission instructions, what format you’re expecting the submission to be in, any explicit constraints you want the candidate to consider, etc.
- Always have a version identifier for each work sample and associated grading criteria. Your work samples should undergo several rounds of revision, but you want to make sure that there’s consistency within each round of hiring. Having a version identifier on each sample lets you know when you’re crossing grading boundaries.
- Along with the work sample version, the grading criteria/checklist should have a table showing pass/fail/review levels. As a grader you don’t want to have to refer back and forth to several places when grading. Put everything the grader needs right in the grading issue itself. Here’s what the bottom of our grading checklist looks like:

![Grading scale on every work sample](/images/t11fm-20160610110815.png)


## Wrap-up

Humans are hard. Hiring humans is even harder. Welcome to reality.

The good news is that there are ways companies can more effectively measure a candidate’s ability to perform their job function. Though we’re always re-evaluating our efforts and acknowledge there is rarely a perfect solution, we’ve been very happy with how the Spreedly work samples have allowed us to objectively evaluate candidates, within a fair and consistent framework.

Oh, and if you want to try your hand at one of our work samples, we encourage you to check out our [jobs page](https://spreedly.com/jobs). We use work samples for all positions across all departments.
