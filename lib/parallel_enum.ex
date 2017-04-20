defmodule ParallelEnum do
  @moduledoc """
    Some parallel processing function
    inspired by https://gist.github.com/padde/b350dbc81f458898f08417d804e793aa
  """

  @doc """
    Map all element of a list and execute the given function on it in parallel.
    If the function raise an error during one process still get going & return the error in the relevant result index as:
    > {:error, err, element}
  """
  @spec map(list|map, function, integer) :: list
  def map(enum, fun, max \\ 1)
  def map(list, fun, max)
  when is_list(list) and is_function(fun) and is_integer(max) do
    results = List.duplicate(nil, length(list))
    case :erlang.fun_info(fun)[:arity] do
      1 -> do_pmap1(list, fun, max(1, min(max, length(list))), 0, results)
      2 -> do_pmap2(list, fun, max(1, min(max, length(list))), 0, results)
      _ -> results
    end
  end
  def map(map, fun, max) when is_map(map),
    do: map(for {k, v} <- map do {k, v} end, fun, max)

  @doc """
    Map all element of a list and execute the given function on it in parallel.
    Error are propagated to the main thread
  """
  @spec map!(list|map, function, integer) :: list
  def map!(enum, fun, max \\ 1)
  def map!(list, fun, max)
  when is_list(list) and is_function(fun) and is_integer(max) do
    results = List.duplicate(nil, length(list))
    case :erlang.fun_info(fun)[:arity] do
      1 -> do_pmap1!(list, fun, max(1, min(max, length(list))), 0, results)
      2 -> do_pmap2!(list, fun, max(1, min(max, length(list))), 0, results)
      _ -> results
    end
  end
  def map!(map, fun, max) when is_map(map),
    do: map!(for {k, v} <- map do {k, v} end, fun, max)

  defp do_pmap1([], _fun, _max, 0, results), do: results
  defp do_pmap1([element | todo], fun, max, workers, results) when workers < max do
    caller = self
    index = length(results) - length(todo) - 1
    spawn fn ->
      result = try do
        fun.(element)
      rescue
        error -> {:error, error, element}
      end
      send caller, {index, result}
    end
    do_pmap1(todo, fun, max, workers + 1, results)
  end

  defp do_pmap1(todo, fun, max, workers, results) do
    results = receive do
      {index, result} -> List.replace_at(results, index, result)
    end
    do_pmap1(todo, fun, max, workers - 1, results)
  end

  defp do_pmap2([], _fun, _max, 0, results), do: results
  defp do_pmap2([element | todo], fun, max, workers, results) when workers < max do
    caller = self
    index = length(results) - length(todo) - 1
    spawn fn ->
      result = try do
        fun.(element, index)
      rescue
        error -> {:error, error, element}
      end
      send caller, {index, result}
    end
    do_pmap2(todo, fun, max, workers + 1, results)
  end

  defp do_pmap2(todo, fun, max, workers, results) do
    results = receive do
      {index, result} -> List.replace_at(results, index, result)
    end
    do_pmap2(todo, fun, max, workers - 1, results)
  end

  defp do_pmap1!([], _fun, _max, 0, results), do: results
  defp do_pmap1!([element | todo], fun, max, workers, results) when workers < max do
    caller = self
    index = length(results) - length(todo) - 1
    spawn_link fn ->
      send caller, {index, fun.(element)}
    end
    do_pmap1!(todo, fun, max, workers + 1, results)
  end

  defp do_pmap1!(todo, fun, max, workers, results) do
    results = receive do
      {index, result} -> List.replace_at(results, index, result)
    end
    do_pmap1!(todo, fun, max, workers - 1, results)
  end

  defp do_pmap2!([], _fun, _max, 0, results), do: results
  defp do_pmap2!([element | todo], fun, max, workers, results) when workers < max do
    caller = self
    index = length(results) - length(todo) - 1
    spawn_link fn ->
      send caller, {index, fun.(element, index)}
    end
    do_pmap2!(todo, fun, max, workers + 1, results)
  end

  defp do_pmap2!(todo, fun, max, workers, results) do
    results = receive do
      {index, result} -> List.replace_at(results, index, result)
    end
    do_pmap2!(todo, fun, max, workers - 1, results)
  end
end
