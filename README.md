# LQueue

Double-ended queue with limited length.

## Installation

  1. Add `lqueue` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:lqueue, "~> 0.1.0"}]
    end
    ```

  2. Ensure `lqueue` is started before your application:

    ```elixir
    def application do
      [applications: [:lqueue]]
    end
    ```
