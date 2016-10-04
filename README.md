# LQueue

[![Build Status](https://travis-ci.org/jur0/lqueue.svg?branch=master)](https://travis-ci.org/jur0/lqueue)

Double-ended queue with limited length.

## Installation

  1. Add `lqueue` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:lqueue, "~> 1.0.0"}]
    end
    ```

  2. Ensure `lqueue` is started before your application:

    ```elixir
    def application do
      [applications: [:lqueue]]
    end
    ```
