---
title: Fare Thee Well Conditional Logic - Hello Pattern Matching!
author: Duff O'Melia
author_email: duff@spreedly.com
author_url: https://twitter.com/duffomelia
date: 2017-04-19
tags: pattern-matching, elixir
meta: See how pattern matching in Elixir allows us to elegantly express conditional logic.
---

I've heard this conversation many times over the last few years.


> Question: What are you liking about Elixir?

> Answer: Oh, I like ..., and ..., and I LOVE pattern matching!

Pattern matching is almost always one of the features I hear in the response, and the reasoning is typically around how much conditional logic pattern matching "eliminates". It wasn't until I actually started using Elixir that I started to understand what that actually meant. I'd say pattern matching allows us to express the conditional aspects of our system in a simpler, more explicit way. READMORE Rather than using a number of `if` and `else if` statements, we can express the conditions in other ways, like our function heads.



Let's consider a simple example where we'd like to discern the type of a triangle based on the length of its sides. In essence, we'd want something like the following to pass:


```elixir
test "different kinds of triangles" do
  assert Triangle.kind(2, 2, 2) == :equilateral
  assert Triangle.kind(3, 4, 4) == :isosceles
  assert Triangle.kind(4, 3, 4) == :isosceles
  assert Triangle.kind(4, 4, 3) == :isosceles
  assert Triangle.kind(3, 4, 5) == :scalene
end
```

In a typical language that doesn't have patten matching, we'd likely have code that started out looking something like this:


```ruby
class Triangle
  def self.kind(a, b, c)
    if (a == b) && (a == c)
      :equilateral
    elsif (a == b) || (a == c) || (b == c)
      :isosceles
    else
      :scalene
    end
  end
end
```

In Elixir, we can solve the same problem like this:


```elixir
defmodule Triangle do
  def kind(a, a, a), do: :equilateral
  def kind(a, a, _), do: :isosceles
  def kind(a, _, a), do: :isosceles
  def kind(_, b, b), do: :isosceles
  def kind(_, _, _), do: :scalene
end
```

It means we often have more functions, but each of them is typically smaller and easier to parse since we didn't need to use the standard conditional constructs.

Let's consider another example where we want to process an incoming hash based on some of its keys and values. A starting point for such code in a language without pattern matching looks like this:


```ruby
def process(hash) do
  if hash[:bucket] == "transactions"
    #...
  elsif hash[:bucket] == "gateways"
    #...
    if hash[:gateway_type] == "test"
      #...
    else
      #...
    end
  elsif hash[:bucket] == "id/organizations"
    #...
  else
    #...
  end
end
```

In Elixir though, we can approach the problem differently:


```elixir
def process(%{bucket: "transactions"}) do
  ...
end

def process(%{bucket: "gateways", gateway_type: "test"}) do
  ...
end

def process(%{bucket: "gateways"}) do
  ...
end

def process(%{bucket: "id/organizations"}) do
  ...
end

def process(_) do
  ...
end
```

Each conditional essentially becomes its own extracted function, and the first one that matches gets called. So simple!

When a language like Elixir offers intuitive ways to structure the code such that the functions can remain small and simple, that's exciting to me. When adding additional functionality often involves simply adding another function head with some new behavior, the system starts to feel quite manageable and extendible. Each conditional is a first-class concern within its module, making it easier to read and scan.

Pattern matching has been such a pleasure to use. It's difficult for me to imagine building a large system without it.

If you’re considering using Elixir in your next project, [Stephen Ball’s blog post](https://engineering.spreedly.com/blog/youre-smart-enough-for-elixir.html) is a reminder that things may be simpler than you might imagine.
