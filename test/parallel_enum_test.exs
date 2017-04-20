defmodule ParallelEnumTest do
  use ExUnit.Case
  doctest ParallelEnum

  defp pfunc(value) do
    :timer.sleep(:rand.uniform(10))
    value
  end

  defp pfunc(value, index) do
    :timer.sleep(:rand.uniform(10))
    {value, index}
  end

  defp pfunc_error(_) do
    :timer.sleep(:rand.uniform(10))
    raise "crash"
  end

  test "map list/1" do
    assert ParallelEnum.map(["a", "b", "c", "d", "e", "f", "g", "h", "i"], &pfunc/1, 3) == ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
  end
  test "map list/2" do
    assert ParallelEnum.map([1, 2, 3, 4], &pfunc/2, 2) == [{1, 0}, {2, 1}, {3, 2}, {4, 3}]
  end
  test "map map/1" do
    assert ParallelEnum.map(%{1 => 1, 2 => 2, 3 => 3, 4 => 4}, &pfunc/1, 2) == [{1, 1}, {2, 2}, {3, 3}, {4, 4}]
  end
  test "map map/2" do
    assert ParallelEnum.map(%{1 => 1, 2 => 2, 3 => 3, 4 => 4}, &pfunc/2, 2) == [{{1, 1}, 0}, {{2, 2}, 1}, {{3, 3}, 2}, {{4, 4}, 3}]
  end
  test "map min/max worker" do
    assert ParallelEnum.map([1, 2, 3, 4], &pfunc/1) == [1, 2, 3, 4]
    assert ParallelEnum.map([1, 2, 3, 4], &pfunc/1, 0) == [1, 2, 3, 4]
    assert ParallelEnum.map([1, 2, 3, 4], &pfunc/1, 4) == [1, 2, 3, 4]
    assert ParallelEnum.map([1, 2, 3, 4], &pfunc/1, 10) == [1, 2, 3, 4]
  end
  test "map! list/1" do
    assert ParallelEnum.map!(["a", "b", "c", "d", "e", "f", "g", "h", "i"], &pfunc/1, 3) == ["a", "b", "c", "d", "e", "f", "g", "h", "i"]
  end
  test "error map list/1" do
    assert ParallelEnum.map(["a", "b", "c", "d"], &pfunc_error/1, 3) == [{:error, %RuntimeError{message: "crash"}, "a"}, {:error, %RuntimeError{message: "crash"}, "b"}, {:error, %RuntimeError{message: "crash"}, "c"}, {:error, %RuntimeError{message: "crash"}, "d"}]
  end
end
