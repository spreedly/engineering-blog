---
title: "The Four Characteristics of Production SAFE Scripts"
author: Erich Smith
author_email: erich@spreedly.com
author_url: https://github.com/erichs/
date: 2017-07-31
tags: scripting
meta: Scripts shouldn't be thought of as risk-less bits of code! Use the SAFE acronym to implement robust scripts safe for production use.
---

Sometimes, despite the best of practices and intentions, you find yourself having to run some sideband, perhaps even one-off, script in production. There're lots of reasons this could happen including:

- Data normalization or cleanup
- Hairy database migration
- Edge case recovery so infrequent it isn't yet part of the app

The point is, you're running off the rails a bit. The nature of this task means you probably don't have much test coverage. How do you know the thing you're about to unleash on production is safe to run? With more formal code deliverables you have automated tests, well-vetted deployment pipelines, and other concrete protections that aren't available to your scripts. So how do you gain confidence in the execution of your scripts?

Think SAFE: Status, Automation, Failure, Environment

READMORE

## Status

One of the most overlooked, but important, aspects to a script’s operation is visibility into its execution. How do you know if your script is proceeding as expected? How do you know how far it’s completed? How will you know if your script has been successful? Always knowing the status of your script provides this level of visibility and really encompasses three things: runtime metrics, logging, and exit status.

### Metrics

If your script is long-lived and a usable metrics pipeline is handy, you consider emitting numeric metrics during execution, perhaps via StatsD or a 3rd party service like librato or datadog. This allows you to monitor the number of widgets scanned per minute, the time it took to redact 95% of all data items processed in a given period, etc.

Not sure what kind of metrics to emit? The [four golden signals of monitoring](https://landing.google.com/sre/book/chapters/monitoring-distributed-systems.html#xref_monitoring_golden-signals) (latency, errors, traffic, and saturation) are a great place to start, and are usually all you need.

### Logging

The simplest form of logging is just to print to `stdout`. The output of your script may always be redirected, via `./myscript > output.log`, or piped to a file with something like `./myscript | tee -a output.log`.

Printing to `stdout` is flexible and allows for easy log redirection, and composition (via pipes). It’s always a good idea to make your output easy to consume by downstream programs later. Log output should be concise, timestamped and trivially parseable. If you have an existing log processing infrastructure in place, consider structured logging, even for small utilities. Strike a balance between human and machine readability. Consider printing log entries like this:

```
#timestamp, message, duration in seconds
1495136508,"processed widget foo",2
1495136510,"processed widget bar",1
1495136511,"skipped widget qux",0
```

or this:

```
{ "ts": 1495136508, "msg": "processed widget foo", "duration": 2 }
{ "ts": 1495136510, "msg": "processed widget bar", "duration": 1 }
{ "ts": 1495136511, "msg": "skipped widget qux", "duration": 0 }
```

instead of logs like this:

```
2017-05-18T03:41:47.062+00:00: processing widget foo
2017-05-18T03:41:49.013+00:00: processed widget foo, took 2s
2017-05-18T03:41:49.013+00:00: processing widget bar
2017-05-18T03:41:50.110+00:00: processed widget bar, took 1s
2017-05-18T03:41:50.110+00:00: processing widget qux
2017-05-18T03:41:50.110+00:00: skipped widget qux
```

Parsing the single-line-oriented log entries above is simple work for UNIX tools like `cut`, `sed`, or `awk`, or a one-liner invocation of string `split` in Ruby or Python. Tools like jq make short work of JSON output. Parsing multi-line log entries, however, is more complicated and often requires keeping state or making multiple passes over the logfile.

Concise log output is meaningful. Unless debugging, less is usually more with logs. They should follow the Rule of Silence from Unix philosophy:

> Developers should design programs so that they do not print unnecessary output. This rule aims to allow other programs and developers to pick out the information they need from a program's output without having to parse verbosity.

The [Rule of Silence](https://en.wikipedia.org/wiki/Unix_philosophy) also extends to progress bars: consider other options first! Simple heartbeat (boolean) metrics or periodic log output could be used to indicate that the script is, in fact, still working. If you decide that a progress bar is truly desirable, provide a way to silence it. Possible options here include: a `--noprogress` flag argument, or redirecting the progress bar output to `stderr`, to keep it separate from the `stdout` log stream.

Silencing progress bar output would then be a matter of:

```
$ ./myscript --noprogress > output.log
```

or if progress was emitted to `stderr`:

```
$ ./myscript > output.log 2>/dev/null
```

Progress bars muddy output, avoid them if you can.

Exit Status
Be a good UNIX citizen. Exit `0` on success, exit `1` on general error, and exit `2` if the script was invoked improperly. Some exit codes have special meanings by convention, but `0` on success is a must!

This allows you, for instance, to set up trivial alerting or cleanup, based on exit status:

```
$ ./my_long_running_script > output.log || alert_slack "$(hostname): script failed! See $(pwd)/output.log"
```

If your script has multiple ways to exit, make sure that each exit path results in the appropriate status code.

## Automation

If your script needs to run more than once, ever, it is worth thinking about how it can be automated. You might consider the lifecycle of your script in three phases: startup, runtime, and termination. Each of these phases contributes to your script’s automation story.

### Startup

You should be prepared for your script to be run automatically via scheduler (say, `cron`), in the shell background (`./myscript&`), or detached in a `tmux` session. Don't assume keyboard-interactive input is available at startup. Your script or program should prefer environment variables, command-line arguments, or configuration files over interactive prompts when gathering inputs.

If your script is meant for periodic use, the startup phase is a natural time to consider the impact of multiple concurrent processes. What if a previous version of your script is still running when the next scheduler job fires? Consider guarding against this scenario using a mutex lock, as this is generally preferable to multiple processes stacking up. If the process is non-critical, you might choose to simply abort. In any case, this edge-case should be logged as it could indicate a scheduling or load problem, or both.

### Runtime

It would be a real shame if your script paused for keyboard input 3 hours into an execution cycle expected to last many hours, and no one was around. As with startup, don’t assume interactive input is available at runtime, either.

It is worth considering the runtime behavior of your script over multiple execution cycles. Will it automatically recover from a previous, failed run (re-entrancy)? Is it safe to call the script multiple times in a row (idempotency)?

Design your script to be re-entrant and idempotent. Doing so will allow automated runs of your script to pay dividends in resiliency, efficiency and reduced cognitive load.

### Termination

Consider the side-effects that normal and abnormal termination of your script has on the system. Are there intermediate files, sockets, or other resources that require cleanup? Can you leverage `logrotate` to ensure your log files don’t accidentally consume too much disk space?

What happens if I send SIGINT (`ctrl-C`) to your process in the middle of the run? What about SIGTERM (`kill`)? Consider trapping these signals and ensuring that necessary logging and cleanup occurs. If programming in a language like Ruby, consider  `rescue`, `ensure`, or `at_exit` blocks for cleanup code.


## Failure

It should be downright hard to cause the script to do undesirable things due to sloppy or missing input. When something goes wrong while your script is running, unless it is crystal clear what has occurred and how to automatically recover, often it is best to just stop and wait for human intervention. Scripts should “blow a fuse”, rather than continue with erroneous or missing input, or ignoring potentially dangerous states.

### Asking for help

It can help to adopt a defensive mindset and consider what happens when your script fails at 3AM. How does your script ask for help?

In order of increasing severity, your script should probably:

- log the failure
- send an email / post a chat message
- page a human

All errors should be logged as a matter of course. If your script has decided not to run, however, or is an error state requiring manual recovery (blown a fuse), logging is clearly insufficient. The safe operation and state of our systems shouldn’t depend on humans reading logs—logs are best used for forensics and analysis.

### Preflight checks

If your script can detect likely problems upfront, it should do so, and fail early if its dependencies aren’t met. We think of these as “preflight checks”, and they can include:

- database state
- disk space availability
- current time (if script is time sensitive)
- network connectivity
- environment, configuration, or script arguments

Checking for these likely causes of failure upfront makes failure obvious and less expensive. This is especially important for long-running scripts, or scripts with multiple phases: it would be unfortunate to do several hours of expensive processing only to discover that the configuration required to reach a service for a secondary phase of processing was missing (although if your script is re-entrant and idempotent, per above, this is less of a problem!).

### Failing with Compassion

When failures do occur, error output should always be actionable. Even if you have wonderful and comprehensive documentation that describes all the edge cases and suggested recovery steps, the kindest thing to do for your future self (not to mention your co-workers!) is to assume this is lost and forgotten. Your error output should provide an actionable link to these references, if they exist, or detailed-enough instructions that a human can hope to follow-up and reason independently about the error. We all laugh about `PC LOAD LETTER` error messages, but if we’re not careful, we can inadvertently generate these ourselves!

## Environment

Consider the impact your running script will have on its immediate compute environment, and what local resources are available:

- Running some hairy SQL? See if a dedicated read slave is available.
- Running unattended in the middle of the night on a RAM-sensitive box? If you can save 50% of memory usage by adding 5-10 minutes of time, that's a win.
- Need to make frequent use of CPU or I/O intensive data, and RAM or cache is plentiful? Caching is a win.
- Must run on the application server, and poor performance means service downtime? Consider enforcing limits on memory/swap or cpu with `cgroups`, or having the process self-terminate if it exceeds obvious bounds.

A little planning and forethought can pay big dividends when deciding where to deploy your script!

## Why bother?

Thinking through the various issues raised in this blog post might seem like a lot of work just to deploy and execute a script. However, most of these concerns are easily implemented with a little fore-thought and quickly become organizational defaults.

Don’t let the fact that scripts tend to execute in an operational grey area affect how you treat them. One-off scripts execute in the production environment on production data, generally without the benefit of a robust test suite or deployment pipeline. If anything they should be treated with more care and boundaries than application deployments! When considered in that light, don’t they seem worth the investment?

Also, consider the total cost of not working through these issues in advance. In our experience, there's really no such thing as throw-away code. Today's "good enough" is often tomorrow's "how it's always been".

If you'd like to work at an organization that treats scripts with this type of care and forethought, maybe there's something for you on our [jobs page](https://www.spreedly.com/jobs)?
