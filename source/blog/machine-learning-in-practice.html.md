---
title: "Machine Learning in Practice: Different than a Kaggle Competition"
author: Michael Bostwick
author_email: michael.bostwick@spreedly.com
author_url: https://www.linkedin.com/in/michaelbostwick1/
date: 2017-08-07
tags: data science, machine learning
---

_Michael Bostwick spent the summer as a Data Science Intern at Spreedly and returns to the 2nd year of a Master’s program in Statistics and Operations Research at the University of North Carolina at Chapel Hill in the Fall._

As I wrap-up my summer internship at Spreedly, I wanted to capture a handful of lessons learned while performing data science at a FinTech startup. Many collegiate-level data science curricula spend a lot of time focusing on the more academic aspects of machine learning – specific algorithms, the math behind them, etc… What follows is a prescriptive approach to bridging the divide between learning about machine learning and actually applying it to solve business problems.

To set the stage for the project I worked on this summer: Spreedly is a financial technology startup that provides a PCI Compliant credit card vault that allows companies to simultaneously work with one or many payment gateways. Like any other company operating in the B2B space, Spreedly would like to prioritize potential new customer follow-up in order to increase the trial to subscriber conversion rate. My goal was to use machine learning to build a lead scoring model that could surface the most likely subscribers out of the many companies that create a trial account.

As is often said of data science, considerable time was spent gathering and preparing data in order to do modeling. Once the data was prepared the building of a working machine learning model was relatively quick. By working I mean producing predictions better than random. But what is often overlooked, however, is where to go from there. I’d like to offer four lessons I’ve learned, from a combination of trial and error, online resources (like [here from Andrew Ng](http://cs229.stanford.edu/materials/ML-advice.pdf)) and the wise counsel of Spreedly’s full-time Data Scientist Shoresh Shafei, for taking a base machine learning model and refining it to achieve a specific business outcome.

READMORE

## Business-relevant error analysis

One suggested next step after building a baseline machine learning model is to perform error analysis. That is, look at examples that have been misclassified and try to determine common features to add (or remove) that would help the model correctly classify them.

In the context of images or text this can be particularly useful as these are easy tasks for humans, but difficult for computers. On the other hand, classification in a business context is not necessarily easy for humans or computers. Particularly, as a data scientist new to the business, all you may know about the examples are captured in the features already included in the model.

![](https://d2mxuefqeaa7sj.cloudfront.net/s_FEF5CD68E59027483F6E6E419C74006857D7AFF3AEA9864AAF29391033702F0B_1501093375209_image.png)

Often then, this requires a business perspective. For example, a customer success manager may have a mental picture that comes to mind just from a company name, developed from many customer interactions. Showing them a handful of misclassifications may yield new feature directions to explore.

Work closely with relevant stakeholders to provide the business insight that will help with your error analysis. Data models aren’t built in a vacuum and there will always be aspects of the model only those with deeper business insight can help identify.

## Single-metric test framework

As you try out different features or tweaks to your algorithm hyper-parameters you will want to be able to quickly and clearly see if you are improving the performance. I’ve found two helpful keys to being able to carry this out:

1. Write your code so that you have a modular testing framework. Write functions with passable parameters so that you have concise and repeatable code. Data science scripts are typically run in a linear fashion, but if you decide to make a feature change you don’t want to have to manually change it throughout your code. Performing your analysis in an environment like Jupyter Notebook allows you to run a series of tests and keep the output to check your progress against.
2. Choose a single and robust performance metric that matches your business case. Accuracy is often the default metric in classification problems, but was not a good fit for my problem. As the majority of trials did not end in subscription, the classes were imbalanced and the baseline accuracy was a tough number to beat. More importantly, accuracy equally weighs false positives and false negatives, but we were only concerned with false positives. A better metric in this case is [Precision](http://scikit-learn.org/stable/auto_examples/model_selection/plot_precision_recall.html), the True Positives / (True Positives + False Positives). Taking it a step further, we would only be using the most likely predicted subscribers, so focused in on Top 10 Precision. In retrospect, though, measuring performance on just 10 observations was susceptible to random fluctuations in each fold of cross-validation.

## Pragmatic algorithm choice

There are countless machine learning algorithms to use, each with advantages and disadvantages. Libraries like [Scikit Learn](http://scikit-learn.org/stable/) in Python provide many possibilities that can easily be tested through a common API. Starting a machine learning project, you may have some intuition about the complexity of your problem, but usually it’s unclear which algorithms will work until they are tested. Given that, it is helpful to try a diverse representation of algorithms, but not so many that you can’t investigate each one. While there are always other algorithms out there that might give you better performance, it’s often a better use of your time to understand why a few algorithms are or are not working than randomly searching the vast algorithm space.

It may seem from the start that certain algorithms are bad fits for your problem, but beware throwing them away as a change to the feature representation may alter the appropriateness of each algorithm. There are some general characteristics that can steer your algorithm choice. If the two classes are linearly separable Logistic Regression or Support Vector Machines may be more than adequate. If there are interactions between features a Decision Tree or Random Forest model may be a better fit. For capturing even more complicated relationships a Neural Network  (whether shallow or Deep Learning) might be needed, but also requires larger amounts of data to reliably estimate the many parameters.

## Data aggregation

Part of the data that I used to build the lead scoring model was event based. For each trial account we had a list of the events they performed and what day and time they occurred at. Such rich data has great potential in machine learning, but only if it can be properly represented in features for an algorithm. Most algorithms expect training examples to be like rows in a table, so varying length streams of events need to be aggregated in some form. There are countless options for doing this; we could simply count the number of times each event type occurs, we could measure the time until each event first occurs, we could count specific patterns like “Add Test Payment Method Succeeded” followed by “Retain Payment Method Succeeded”, or we could do many other things.

![](https://d2mxuefqeaa7sj.cloudfront.net/s_FEF5CD68E59027483F6E6E419C74006857D7AFF3AEA9864AAF29391033702F0B_1501091315366_image.png)

Like in the error analysis step, talking to the business can help shortcut this process. After getting some valuable input from the CEO of Spreedly we decided the number of unique days each event type occurred on would be a good measure. A trial user viewing the pricing page on 5 separate days should be different than viewing the pricing page 5 times in the same day. Of course, part of the benefit of machine learning is discovering patterns previously unconsidered so techniques like unsupervised learning or Recurrent Neural Networks (like [suggested in this paper](http://mlrec.org/2017/papers/paper2.pdf)) are worth pursuing if you have sufficient data.

## Conclusion

This summer’s internship experience has reinforced for me that machine learning applied to business problems can be challenging and often requires as much art as science. Compared to a [Kaggle](https://www.kaggle.com/) competition with a predefined dataset and performance metric, there are many more decisions to be made and implications to be weighed. Careful consideration and repeated iterations is needed to arrive at more accurate and useful predictions. This can be difficult at times, but also what makes me excited about practicing data science going forward.
