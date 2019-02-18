defmodule LQueueTest do
  @lqueue_size 3

  use ExUnit.Case, async: true
  import LQueue
  doctest LQueue

  setup do
    {:ok, lqueue: new(@lqueue_size)}
  end

  test "lqueue is (not) full", %{lqueue: lq} do
    assert lq |> push("a") |> push("b") |> push("c") |> full?()
    refute lq |> full?()
  end

  test "clear the queue", %{lqueue: lq} do
    assert lq |> clear() |> Enum.to_list() == []
    assert ["X", "Y", "Z"] |> from_list(3) |> clear() |> Enum.to_list() == []
  end

  test "max count of the queue", %{lqueue: lq} do
    assert lq |> max_count() == @lqueue_size
  end

  test "push items to the lqueue", %{lqueue: lq} do
    assert lq |> push(1) |> push(2) |> Enum.to_list() == [1, 2]

    assert lq
           |> push(:foo)
           |> push(:bar)
           |> push(:baz)
           |> Enum.to_list() == [:foo, :bar, :baz]

    assert [10, :a, "xy"]
           |> from_list(3)
           |> push("abc")
           |> Enum.to_list() == [:a, "xy", "abc"]
  end

  test "push items to the lqueue (front)", %{lqueue: lq} do
    assert lq |> push_front(1) |> push_front(2) |> Enum.to_list() == [2, 1]

    assert lq
           |> push_front(:foo)
           |> push(:bar)
           |> push_front(:baz)
           |> Enum.to_list() == [:baz, :foo, :bar]

    assert [10, :a, "xy"]
           |> from_list(3)
           |> push_front("abc")
           |> Enum.to_list() == ["abc", 10, :a]
  end

  test "pop items from the lqueue", %{lqueue: lq} do
    assert lq |> pop |> result_check(nil, [])
    assert from_list([1], 1) |> pop |> result_check(1, [])

    assert [:foo, :bar]
           |> from_list(5)
           |> pop()
           |> result_check(:foo, [:bar])

    assert ["Aa", "B", "cc"]
           |> from_list(2)
           |> push("x")
           |> pop()
           |> result_check("cc", ["x"])
  end

  test "pop items from the lqueue (rear)", %{lqueue: lq} do
    assert lq |> pop_rear() |> result_check(nil, [])
    assert from_list([1], 1) |> pop_rear() |> result_check(1, [])

    assert [:foo, :bar]
           |> from_list(5)
           |> pop_rear()
           |> result_check(:bar, [:foo])

    assert ["Aa", "B", "cc"]
           |> from_list(2)
           |> push("x")
           |> pop_rear()
           |> result_check("x", ["cc"])
  end

  test "get items from the top of the lqueue", %{lqueue: lq} do
    assert get(lq) == nil
    assert [-10, -5, 0] |> from_list(3) |> get() == -10
  end

  test "get items from the rear of the lqueue", %{lqueue: lq} do
    assert lq |> get_rear() == nil
    assert [-10, -5, 0] |> from_list(3) |> get_rear() == 0
  end

  test "drop items from the top of the lqueue", %{lqueue: lq} do
    assert lq |> drop() |> Enum.to_list() == []
    assert [:a, :b] |> from_list(2) |> drop() |> Enum.to_list() == [:b]
  end

  test "drop items from the rear of the lqueue", %{lqueue: lq} do
    assert lq |> drop_rear() |> Enum.to_list() == []
    assert [:a, :b] |> from_list(2) |> drop_rear() |> Enum.to_list() == [:a]
  end

  test "create lqueue from list, convert to list", %{lqueue: lq} do
    assert lq |> Enum.to_list() == []
    assert [] |> from_list(3) |> Enum.to_list() == []
    assert [1] |> from_list(3) |> Enum.to_list() == [1]
    assert [1, 2, 3] |> from_list(3) |> Enum.to_list() == [1, 2, 3]
    assert [:a, :b, :c, :d] |> from_list(2) |> Enum.to_list() == [:c, :d]
  end

  test "Enum count", %{lqueue: lq} do
    assert lq |> Enum.count() == 0
    assert [:foo, :bar] |> LQueue.from_list(3) |> Enum.count() == 2
  end

  test "Enum member", %{lqueue: lq} do
    refute lq |> Enum.member?("X")
    assert [1, 2, 3] |> from_list(3) |> Enum.member?(3)
    assert [1, 2, 3] |> from_list(3) |> push_front(10) |> Enum.member?(10)
  end

  test "Enum reduce", %{lqueue: lq} do
    assert_raise Enum.EmptyError, fn ->
      lq |> Enum.reduce(fn x, acc -> x * acc end) == 0
    end

    assert lq |> push(10) |> Enum.reduce(fn x, acc -> x * acc end) == 10

    assert [1, 2, 3]
           |> from_list(5)
           |> push(10)
           |> push_front(10)
           |> Enum.reduce(0, fn x, acc -> x + acc end) == 26
  end

  test "Stream map and filter", %{lqueue: lq} do
    assert lq |> Stream.map(fn x -> x * x end) |> Enum.to_list() == []

    assert ["A", "b", "C"]
           |> from_list(5)
           |> Stream.filter(fn x -> x == String.upcase(x) end)
           |> Enum.to_list() == ["A", "C"]
  end

  test "Collectable into" do
    assert [1, 2, 3, 4, 5] |> Enum.into(new(3)) |> Enum.to_list() == [3, 4, 5]
    assert %{a: 1, b: 2} |> Enum.into(new(10)) |> Enum.to_list() == [a: 1, b: 2]
  end

  defp result_check({res_item, res_lq}, item, list) do
    {res_item, Enum.to_list(res_lq)} == {item, list}
  end
end
