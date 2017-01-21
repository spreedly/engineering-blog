---
title: "Mocks and Explicit Contracts: In Practice w/ Elixir"
author: David Santoso
author_email: david@spreedly.com
author_url: https://twitter.com/ddsaso
date: 2016-11-4
tags: elixir, testing
image_src: /images/mocks/leader.jpg
---
Writing tests for your code is easy. Writing good tests is much harder. Now throw in requests to external APIs that can return (or not return at all!) a myriad of different responses and we’ve just added a whole new layer of possible cases to our tests. When it comes to the web, it’s easy to overlook the complexity when working with an external API. It’s become so second nature that writing a line of code to initiate an HTTP request can become as casual as any other line of code within your application. However that’s not always the case.

We recently released the first version of our self-service debugging tool. You can see it live at [https://debug.spreedly.com](https://debug.spreedly.com). The goal we had in mind for the support application was to more clearly display customer transaction data for debugging failed transactions. We decided to build a separate web application to layer on top of the Spreedly API which could deal with the authentication mechanics as well as transaction querying to keep separate concerns between our core transactional API and querying and displaying data. I should also mention that the support application is our first public facing Elixir application in production!

READMORE

Since this was a separate service, it meant that we needed to make HTTP requests from the support application to our API in order to pull and display data. Although we had solid unit tests with example responses we’d expect from our API, we wanted to also incorporate remote tests which actually hit the production API so we could occasionally do a real world full stack test. Remote tests aren’t meant to be executed every test run, only when we want that extra ounce of confidence.

As we started looking into testing Elixir applications against external dependencies, we came across José Valim’s excellent blog post, [Mocks and Explicit Contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/). If you haven’t read it already, you should check it out. It has a lot of great thoughts and will give this post a little more context. It seemed like a solid approach for building less brittle tests so we thought we implement it ourselves and see how well it would work in reality and if it could provide what we needed to include remote tests along side our unit tests. Here’s how our experience with this approach went…

### Pluggable clients

The first thing we needed to do was update the Spreedly API client in the support application to be dynamically selected instead of hardcoded. In production we want to build real HTTP requests, but for unit tests we want to replace that module with a mock module which just returns simulated responses.

```elixir
# Module wrapping our API requests for transactions
defmodule SupportApp.Transaction do
  @core Application.get_env(:support_app, :core)

  def fetch(token, user, secret) do
    @core.transaction(user, token, access_secret)
  end
end
```

In line 3 above, you can see that the `@core` constant is being dynamically set by doing a Application configuration lookup for the value. In our particular case, the lookup will return the module to use for getting Spreedly transaction data.

Once we’ve got that set, now we can configure the module to use in our application config. Notice that the module returned on lookup changes depending on the environment we’re currently running. We really like the explicitness here!

```elixir
# In config/test.exs
config :support_app, :core, SupportApp.Core.Mock

# In config/config.exs
config :support_app, :core, SupportApp.Core.Api
```

### Enforceable interfaces

So, what do those two modules look like anyway? Well, from our `Transaction` module above we know that both the HTTP client and the mock will need to have a  `transaction/3`  function which will take care of getting us a transaction whether it be from the Spreedly API or a simulated one we build ourselves.

So in production, we’re using wrapping `HTTPotion` to make requests.

```elixir
defmodule SupportApp.Core.Api do
  @behaviour SupportApp.Core
  ...
  def transaction(key, token, secret) do
    path = "..."
    options = ...

    %HTTPotion.Response{body: body} = HTTPotion.get(path, options)
    case Poison.Parser.parse!(body) do
      ...
    end
  end
  ...
end
```

However, in unit tests we’re going to use a mock module instead which just returns a straight Map of what we’d expect from a production request.

```elixir
defmodule SupportApp.Core.Mock do
  @behaviour SupportApp.Core

  def transaction(_key, "nonexistent", _), do: nil
  def transaction(_key, token, _) do
    %{
      "transaction": %{
        "succeeded": true,
        "state": "succeeded",
        "token": "7icIbTtxupZpY8SKxwlUAKq8Qiw",
        "message_key": "messages.transaction_succeeded",
        "message": "Succeeded!",
        ...
      }
  end
end
```

Two things to notice about the modules above:

1. For the mock module, we pattern matched on the function parameters to alter the response we want. This is incredibly useful when you want to test against different response scenarios since you can define another transaction/3 function with a specific parameter value and then have it return the response with appropriate test data. In our case, we wanted to also test when someone doesn’t enter a transaction token to search (see line 4 in the mock module above).

2. In both the production and test modules, there’s a line beneath the module definition- @behaviour SupportApp.Core . By having a top level behaviour for these modules, we can be sure that our production API client module and our mock module adhere to the same interface. If we want to add another endpoint, start by adding it to the top level behaviour SupportApp.Core which will then trickle down to all modules and keep us explicitly defining our API contract so our production API client and mock client remain in step.

Here’s a snippet of our behaviour module that ensures all compliant behaviours have a `transaction` function with the current arity and argument types:

```elixir
defmodule SupportApp.Core do
  use Behaviour

  @callback transaction(key :: String.t, token :: String.t, secret :: String.t) :: %{}
  ...
end
```

And that’s it for setup!

### Test segmentation

Up to this point we’ve followed the approach as outlined by José’s blog post and created an explicit contract between our modules, allowing us to change underlying implementations depending on the environment we’re running in. That is, a mock module to be used during test and an Spreedly API client in production. However, our original plan was to include remote tests that actually hit our production API so how can we enable that in our tests?

Simple! In the same way we dynamically looked up the module we wanted to use, we can use the test setup block to pass the module we want to use in place of our external dependency client. So for the unit tests we have:

```elixir
defmodule SupportApp.Core.MockTest do
  use ExUnit.Case, async: true

  setup do
      {:ok, core: Application.get_env(:support_app, :core)} # <-- See config/test.exs
  end

  test "transaction", %{core: core} do
    %{"transaction" => transaction} = core.transaction(...)
    assert txn["token"]
  end
end
```

But for our remote tests, we change our setup block to drop in a the real HTTP client wrapper. I should also note that we needed to handle creating production API credentials and making them available to our remote tests, but handling that is a bit out of scope for this post.

```elixir
defmodule SupportApp.Core.ApiTest do
  use ExUnit.Case, async: true
  @moduletag :remote

  setup do
    {:ok, core: SupportApp.Core.Api} # <-- Force the module to be used
  end

  test "transaction", %{core: core} do
   %{"transaction" => txn} = core.transaction(...)
    assert txn["token"]
  end
end
```

Almost there! Since we don’t want to run our remote tests each time (they’re only around for that extra bit of confidence!) we can just use a `@moduletag` to exclude them by default and only run them if we explicitly say to do so. We added a line to our `test_helper.exs` :

```elixir
ExUnit.configure exclude: [:remote]
```

Now to run the remote tests, just add an `include` flag:

```elixir
$ mix test --include remote
```

We’re really happy with the setup so far and think it provides us both the confidence of real world full stack tests, with the flexibility of simulating responses within a mock.
