defmodule LQueueTest do
  @lqueue_size 3

  use ExUnit.Case, async: true
  import LQueue
  doctest LQueue

  setup do
    {:ok, lqueue: new(@lqueue_size)}
  end

  test "lqueue is (not) empty", %{lqueue: lqueue} do
    assert lqueue |> empty?()
    refute lqueue |> push("abc") |> empty?()
  end

  test "lqueue is (not) full", %{lqueue: lqueue} do
    assert lqueue |> push("a") |> push("b") |> push("c") |> full?()
    refute lqueue |> full?()
  end

  test "clear the queue", %{lqueue: lqueue} do
    assert lqueue |> clear() |> to_list == []
    assert ["X", "Y", "Z"] |> from_list(3) |> clear() |> to_list == []
  end

  test "number of items in lqueue", %{lqueue: lqueue} do
    assert lqueue |> LQueue.length() == 0
    assert lqueue |> push(100) |> LQueue.length() == 1
  end

  test "max size of queue is @lqueue_size", %{lqueue: lqueue} do
    assert lqueue |> max_length() == @lqueue_size
  end

  test "check an element is a member of the lqueue", %{lqueue: lqueue} do
    refute lqueue |> member?(?X)
    refute ["test"] |> from_list(1) |> member?("xyz")
    assert [10, 20] |> from_list(5) |> member?(20)
    assert [10, -20] |> from_list(2) |> member?(10)
  end

  test "push items to the lqueue", %{lqueue: lqueue} do
    assert lqueue |> push(1) |> push(2) |> to_list() == [1, 2]
    assert lqueue
    |> push(:foo)
    |> push(:bar)
    |> push(:baz)
    |> to_list() == [:foo, :bar, :baz]
    assert [10, :a, "xy"]
    |> from_list(3)
    |> push("abc")
    |> to_list() == [:a, "xy", "abc"]
  end

  test "push items to the lqueue (front)", %{lqueue: lqueue} do
    assert lqueue |> push_front(1) |> push_front(2) |> to_list() == [2, 1]
    assert lqueue
    |> push_front(:foo)
    |> push(:bar)
    |> push_front(:baz)
    |> to_list() == [:baz, :foo, :bar]
    assert [10, :a, "xy"]
    |> from_list(3)
    |> push_front("abc")
    |> to_list() == ["abc", 10, :a]
  end

  test "pop items from the lqueue", %{lqueue: lqueue} do
    assert lqueue |> pop |> result_check(nil, [])
    assert from_list([1], 1) |> pop |> result_check(1, [])
    assert [:foo, :bar]
    |> from_list(5)
    |> pop()
    |> result_check(:foo, [:bar])
    assert ["Aa", "B", "cc"]
    |> from_list(2)
    |> push("x")
    |> pop()
    |> result_check("B", ["x"])
  end

  test "pop items from the lqueue (rear)", %{lqueue: lqueue} do
    assert lqueue |> pop_rear() |> result_check(nil, [])
    assert from_list([1], 1) |> pop_rear() |> result_check(1, [])
    assert [:foo, :bar]
    |> from_list(5)
    |> pop_rear()
    |> result_check(:bar, [:foo])
    assert ["Aa", "B", "cc"]
    |> from_list(2)
    |> push("x")
    |> pop_rear()
    |> result_check("x", ["B"])
  end

  test "get items from the top of the lqueue", %{lqueue: lqueue} do
    assert get(lqueue) == nil
    assert [-10, -5, 0] |> from_list(3) |> get() == -10
  end

  test "get items from the rear of the lqueue", %{lqueue: lqueue} do
    assert lqueue |> get_rear() == nil
    assert [-10, -5, 0] |> from_list(3) |> get_rear() == 0
  end

  test "drop items from the top of the lqueue", %{lqueue: lqueue} do
    assert lqueue |> drop() |> to_list() == []
    assert [:a, :b] |> from_list(2) |> drop() |> to_list() == [:b]
  end

  test "drop items from the rear of the lqueue", %{lqueue: lqueue} do
    assert lqueue |> drop_rear() |> to_list() == []
    assert [:a, :b] |> from_list(2) |> drop_rear() |> to_list() == [:a]
  end

  test "reverse items in the lqueue", %{lqueue: lqueue} do
    assert lqueue |> reverse() |> to_list() == []
    assert [-1, 0, 1] |> from_list(5) |> reverse() |> to_list() == [1, 0, -1]
  end

  test "filter items in the lqueue", %{lqueue: lqueue} do
    assert lqueue |> filter(fn(x) -> x == true end) |> to_list() == []
    assert [1, 2, 3, 4, 5]
    |> from_list(10)
    |> filter(fn(x) -> rem(x, 2) == 0 end)
    |> to_list() == [2, 4]
  end

  test "create lqueue from list, convert to list", %{lqueue: lqueue} do
    assert lqueue |> to_list() == []
    assert [] |> from_list(3) |> to_list() == []
    assert [1] |> from_list(3) |> to_list() == [1]
    assert [1, 2, 3] |> from_list(3) |> to_list() == [1, 2, 3]
    assert [:a, :b, :c, :d] |> from_list(2) |> to_list() == [:a, :b]
  end

  defp result_check({res_item, res_lqueue}, item, list) do
    {res_item, to_list(res_lqueue)} == {item, list}
  end

end
