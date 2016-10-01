defmodule LQueue do
  @moduledoc """
  Functions that work on the double-ended queue with limited length.

  `[1, 2, 3]` queue has the front at the element `1` and the rear at `3`.
  By pushing a new element to the queue (`4`), and assuming that the max length
  of the queue is 3, we will get `[2, 3, 4]` (the `push/2` function). Also, it
  is possible to push to the front of the queue. In this case, by pushing `4`
  to the front (`push_front/2`) we will get `[4, 1, 2]`.

  Due to efficiency reasons, the limited length queue is implemented as two
  lists - the front and the rear list. The rear end is reversed and becomes
  the new front when the front is empty.
  """

  import Kernel, except: [length: 1]

  @typedoc """
  The current number of elements in the queue. The number is an integer between
  `0` and `max_length`
  """
  @type length :: non_neg_integer

  @typedoc """
  The max number of elements in the queue.
  """
  @type max_length :: pos_integer

  @typedoc """
  The queue can hold any type of elements.
  """
  @type element :: any

  @typedoc """
  The tuple representing the limited length queue. It includes the current
  number of elements, max number of elements, rear list and front list.
  Note that this structure should be considered as opaque by other modules.
  """
  @opaque lqueue :: {length, max_length, [element], [element]}

  @doc """
  Creates a new limited lenght queue.

  ## Examples

      iex> LQueue.new(1)
      {0, 1, [], []}

      iex> LQueue.new(5)
      {0, 5, [], []}
  """
  @spec new(max_length) :: lqueue
  def new(m_len) when m_len > 0, do: {0, m_len, [], []}

  @doc """
  Checks if the queue is empty.

  ## Examples

      iex> LQueue.new(5) |> LQueue.empty?()
      true

      iex> [1, 2, 3] |> LQueue.from_list(3) |> LQueue.empty?()
      false
  """
  @spec empty?(lqueue) :: boolean
  def empty?(lqueue), do: length(lqueue) == 0

  @doc """
  Checks if the queue is full.

  ## Examples

      iex> [1, 2] |> LQueue.from_list(3) |> LQueue.full?()
      false

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.full?()
      true
  """
  @spec full?(lqueue) :: boolean
  def full?({m_len, m_len, _r, _f}), do: true
  def full?(_lqueue), do: false

  @doc """
  Returns the number of elements in the queue

  ## Examples

      iex> LQueue.new(10) |> LQueue.length()
      0

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.length()
      2
  """
  @spec length(lqueue) :: length
  def length({len, _m_len, _r, _f}), do: len

  @doc """
  Returns the max length of the queue.

  ## Examples

      iex> LQueue.new(10) |> LQueue.max_length()
      10

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.max_length()
      2
  """
  @spec max_length(lqueue) :: max_length
  def max_length({_len, m_len, _r, _f}), do: m_len

  @doc """
  Checks if the given element is in the queue.

  ## Examples

      iex> [1, 2, 3] |> LQueue.from_list(3) |> LQueue.member?("abc")
      false

      iex> [1, 2, 3] |> LQueue.from_list(3) |> LQueue.member?(2)
      true
  """
  @spec member?(lqueue, element) :: boolean
  def member?({len, _m_len, r, f}, elem) when len > 0 do
    Enum.member?(r, elem) or Enum.member?(f, elem)
  end
  def member?({0, _m_len, _r, _f}, _elem), do: false

  @doc """
  Pushes a new element to the rear of the queue. When pushing to a full queue,
  the front element will be discarded.

  ## Examples

      iex> [1, 2] |> LQueue.from_list(3) |> LQueue.push(10) |>
      ...> LQueue.to_list()
      [1, 2, 10]

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.push(10) |> LQueue.to_list()
      [2, 10]
  """
  @spec push(lqueue, element) :: lqueue
  def push({len, m_len, r, f}, elem) when len < m_len do
    {len + 1, m_len, [elem|r], f}
  end
  def push({m_len, m_len, r, [_fh|ft]}, elem) do
    {m_len, m_len, [elem|r], ft}
  end
  def push({m_len, m_len, r, []}, elem) do
    [_fh|ft] = Enum.reverse(r)
    {m_len, m_len, [elem], ft}
  end

  @doc """
  Pushes a new element to the front of the queue. When pushing to a full queue,
  the rear element will be discarded.

  ## Examples

      iex> [1, 2] |> LQueue.from_list(3) |> LQueue.push_front(5) |>
      ...> LQueue.to_list()
      [5, 1, 2]

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.push_front(5) |>
      ...> LQueue.to_list()
      [5, 1]
  """
  @spec push_front(lqueue, element) :: lqueue
  def push_front({len, m_len, r, f}, elem) when len < m_len do
    {len + 1, m_len, r, [elem|f]}
  end
  def push_front({m_len, m_len, [_rh|rt], f}, elem) do
    {m_len, m_len, rt, [elem|f]}
  end
  def push_front({m_len, m_len, [], f}, elem) do
    [_rh|rt] = Enum.reverse(f)
    {m_len, m_len, rt, [elem]}
  end

  @doc """
  Pops an element from the front of the queue. If the queue is empty, `nil` is
  returned.

  ## Examples

      iex> {nil, lqueue} = [] |> LQueue.from_list(5) |> LQueue.pop()
      {nil, {0, 5, [], []}}
      iex> lqueue |> LQueue.to_list() == []
      true

      iex> {1, lqueue} = [1, 2] |> LQueue.from_list(2) |> LQueue.pop()
      {1, {1, 2, [], [2]}}
      iex> lqueue |> LQueue.to_list() == [2]
      true
  """
  @spec pop(lqueue) :: {element | nil, lqueue}
  def pop({0, _m_len, [], []} = lqueue), do: {nil, lqueue}
  def pop({len, m_len, r, [fh|ft]}), do: {fh, {len - 1, m_len, r, ft}}
  def pop({len, m_len, r, []}) do
    [fh|ft] = Enum.reverse(r)
    {fh, {len - 1, m_len, [], ft}}
  end

  @doc """
  Pops an element from the rear of the queue. If the queue is empty, `nil` is
  returned.

  ## Examples

      iex> {nil, lqueue} = [] |> LQueue.from_list(5) |> LQueue.pop_rear()
      {nil, {0, 5, [], []}}
      iex> lqueue |> LQueue.to_list() == []
      true

      iex> {2, lqueue} = [1, 2] |> LQueue.from_list(2) |> LQueue.pop_rear()
      {2, {1, 2, [1], []}}
      iex> lqueue |> LQueue.to_list() == [1]
      true
  """
  @spec pop_rear(lqueue) :: {element | nil, lqueue}
  def pop_rear({0, _m_len, [], []} = lqueue), do: {nil, lqueue}
  def pop_rear({len, m_len, [rh|rt], f}), do: {rh, {len - 1, m_len, rt, f}}
  def pop_rear({len, m_len, [], f}) do
    [rh|rt] = Enum.reverse(f)
    {rh, {len - 1, m_len, rt, []}}
  end

  @doc """
  Gets the front element of the queue. It does not change the queue. When the
  queue is empty, `nil` is returned.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.get()
      nil

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.get()
      1
  """
  @spec get(lqueue) :: element | nil
  def get({0, _m_len, [], []}), do: nil
  def get({_len, _m_len, r, f}), do: get(r, f)

  @doc """
  Gets the rear element of the queue. It does not change the queue. When the
  queue is empty, `nil` is returned.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.get_rear()
      nil

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.get_rear()
      2
  """
  @spec get_rear(lqueue) :: element | nil
  def get_rear({0, _m_len, [], []}), do: nil
  def get_rear({_len, _m_len, r, f}), do: get_rear(r, f)

  @doc """
  Drops the front element of the queue. When the queue is empty, it is not
  changed.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.drop() |> LQueue.to_list()
      []

      iex> [1, 2, 3] |> LQueue.from_list(5) |> LQueue.drop() |>
      ...> LQueue.to_list()
      [2, 3]
  """
  @spec drop(lqueue) :: lqueue
  def drop({0, _m_len, [], []} = lqueue), do: lqueue
  def drop({len, m_len, r, [_fh|ft]}), do: {len - 1, m_len, r, ft}
  def drop({len, m_len, r, []}) do
    [_fh|ft] = Enum.reverse(r)
    {len - 1, m_len, [], ft}
  end

  @doc """
  Drops the rear element of the queue. When the queue is empty, it is not
  changed.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.drop() |> LQueue.to_list()
      []

      iex> [1, 2, 3] |> LQueue.from_list(5) |> LQueue.drop_rear() |>
      ...> LQueue.to_list()
      [1, 2]
  """
  @spec drop_rear(lqueue) :: lqueue
  def drop_rear({0, _m_len, [], []} = lqueue), do: lqueue
  def drop_rear({len, m_len, [_rf|rt], f}), do: {len - 1, m_len, rt, f}
  def drop_rear({len, m_len, [], f}) do
    [_rh|rt] = Enum.reverse(f)
    {len - 1, m_len, rt, []}
  end

  @doc """
  Reverses the order of the elements in the queue.

  ## Examples

      iex> [] |> LQueue.from_list(3) |> LQueue.reverse() |> LQueue.to_list()
      []

      iex> [1, 2, 3] |> LQueue.from_list(5) |> LQueue.reverse() |>
      ...> LQueue.to_list()
      [3, 2, 1]
  """
  @spec reverse(lqueue) :: lqueue
  def reverse({len, m_len, r, f}), do: {len, m_len, f, r}

  @doc """
  Filters the queue using a filtering function. The function is supposed to
  return truthy values for the elements that should be kept in the queue.

  ## Examples

      iex> [1, 2, 3] |> LQueue.from_list(3) |> LQueue.filter(& &1 > 2) |>
      ...> LQueue.to_list
      [3]
  """
  @spec filter(lqueue, (element -> boolean)) :: lqueue
  def filter({len, m_len, r, f}, fun) do
    {len, m_len, Enum.filter(r, fun), Enum.filter(f, fun)}
  end

  @doc """
  Converts the list to a queue. The elements are pushed into the queue starting
  with the list head. If the list has more elements than the `max_length` of
  the queue, those that can't fit in the queue are discarded.

  ## Examples

      iex> [] |> LQueue.from_list(3) |> LQueue.to_list()
      []

      iex> [1, 2, 3] |> LQueue.from_list(3) |> LQueue.to_list()
      [1, 2, 3]

      iex> [1, 2, 3, 4, 5] |> LQueue.from_list(3) |> LQueue.to_list()
      [1, 2, 3]
  """
  @spec from_list([element], max_length) :: lqueue
  def from_list([], m_len) when m_len > 0, do: new(m_len)
  def from_list(list, m_len) when is_list(list) and m_len > 0 do
    len = Kernel.length(list)
    if m_len >= len do
      {len, m_len, Enum.reverse(list), []}
    else
      {m_len, m_len, list |> Enum.take(m_len) |> Enum.reverse(), []}
    end
  end

  @doc """
  Converts the queue to a list.

  ## Examples

      iex> LQueue.new(5) |> LQueue.to_list()
      []

      iex> [1, 2] |> LQueue.from_list(4) |> LQueue.to_list()
      [1, 2]
  """
  @spec to_list(lqueue) :: [element]
  def to_list({_len, _m_len, r, f}), do: f ++ Enum.reverse(r, [])

  defp get(_, [fh|_]), do: fh
  defp get([rh], []), do: rh
  defp get([_|rt], []), do: List.last(rt)

  defp get_rear([rh|_], _), do: rh
  defp get_rear([], [fh]), do: fh
  defp get_rear([], [_|ft]), do: List.last(ft)

end
