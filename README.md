# LQueue

[![Build Status](https://travis-ci.org/jur0/lqueue.svg?branch=master)](https://travis-ci.org/jur0/lqueue)
[![Hex.pm](https://img.shields.io/hexpm/v/lqueue.svg)](https://hex.pm/packages/lqueue)

Double-ended queue with limited length. It can hold just specified amount
of elements. If more are added, the elements from the top of the queue are
(by default) discarded and the new ones added to the rear of the queue.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be
installed by adding `lqueue` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:lqueue, "~> 1.1"}]
end
```

## Usage

The limited queue implements the
[Enumerable](http://elixir-lang.org/docs/stable/elixir/Enumerable.html),
[Collectable](http://elixir-lang.org/docs/stable/elixir/Collectable.html) and
[Inspect](http://elixir-lang.org/docs/stable/elixir/Inspect.html) protocols, so
all the functions from them are available.

Apart from protocol function, there are others, implemented by `LQueue` module:

 * `new/1`
 * `full?/1`
 * `clear/1`
 * `max_count/1`
 * `push/2`
 * `push_front/2`
 * `pop/1`
 * `pop_rear/1`
 * `get/1`
 * `get_rear/1`
 * `drop/1`
 * `drop_rear/1`
 * `from_list/2`
