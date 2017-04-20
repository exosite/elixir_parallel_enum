# ParallelEnum

Provide parallel collection processing with a Max number of concurrent threads

## Installation

  Add `parallel_enum` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:parallel_enum, "~> 0.1.0"}]
  end
  ```

## Usage

  ```elixir

  ParallelEnum.map([1, 2, 3, 4], fn(x) -> x + 1 end, 2) # => [1, 2, 3, 4]

  ParallelEnum.map([1, 2, 3, 4], fn(x, i) -> x + 1 end, 2) # => [{1, 0}, {2, 1}, {3, 2}, {4, 3}]

  ParallelEnum.map(%{1 => 1, 2 => 2, 3 => 3, 4 => 4}, fn({k, v}) -> x + 1 end, 2) # => [{1, 0}, {2, 1}, {3, 2}, {4, 3}]

  ParallelEnum.map(%{1 => 1, 2 => 2, 3 => 3, 4 => 4}, fn({k, v}, i) -> x + 1 end, 2) # => [{{1, 1}, 0}, {{2, 2}, 1}, {{3, 3}, 2}, {{4, 4}, 3}]

  ```
