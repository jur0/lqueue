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

  defstruct len: 0, m_len: 1, r: [], f: []

  @typedoc """
  The current number of elements in the queue. The number is an integer between
  `0` and `max_count`
  """
  @type length :: non_neg_integer

  @typedoc """
  The max number of elements in the queue.
  """
  @type max_count :: pos_integer

  @typedoc """
  The queue can hold any type of elements.
  """
  @type element :: term

  @typedoc """
  The structure representing the limited length queue. It includes the current
  number of elements, max number of elements, rear list and front list.
  Note that this structure should be considered as opaque by other modules.
  """
  @type t :: %LQueue{
    len: length,
    m_len: max_count,
    r: [element],
    f: [element]
  }

  @doc """
  Creates a new limited lenght queue.

  ## Examples

      iex> LQueue.new(1)
      %LQueue{len: 0, m_len: 1, r: [], f: []}

      iex> LQueue.new(5)
      %LQueue{len: 0, m_len: 5, r: [], f: []}
  """
  @spec new(max_count) :: t
  def new(m_len) when m_len > 0, do: %LQueue{m_len: m_len}

  @doc """
  Checks if the queue is full.

  ## Examples

      iex> [1, 2] |> LQueue.from_list(3) |> LQueue.full?()
      false

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.full?()
      true
  """
  @spec full?(t) :: boolean
  def full?(%LQueue{len: m_len, m_len: m_len}), do: true
  def full?(_lq), do: false

  @doc """
  Removes all the elements from the queue.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.clear() |> Enum.to_list == []
      true

      iex> [1, 2, 3] |> LQueue.from_list(5) |> LQueue.clear() |>
      ...> Enum.to_list == []
      true
  """
  @spec clear(t) :: t
  def clear(%LQueue{m_len: m_len}), do: %LQueue{m_len: m_len}

  @doc """
  Returns the max number of elements the queue can hold.

  ## Examples

      iex> LQueue.new(10) |> LQueue.max_count()
      10

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.max_count()
      2
  """
  @spec max_count(t) :: max_count
  def max_count(%LQueue{m_len: m_len}), do: m_len

  @doc """
  Pushes a new element to the rear of the queue. When pushing to a full queue,
  the front element will be discarded.

  ## Examples

      iex> [1, 2] |> LQueue.from_list(3) |> LQueue.push(10) |>
      ...> Enum.to_list()
      [1, 2, 10]

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.push(10) |> Enum.to_list()
      [2, 10]
  """
  @spec push(t, element) :: t
  def push(%LQueue{len: len, m_len: m_len, r: r} = lq, elem)
      when len < m_len do
    %{lq | len: len + 1, r: [elem|r]}
  end
  def push(%LQueue{len: m_len, m_len: m_len, r: r, f: [_fh|ft]} = lq, elem) do
    %{lq | r: [elem|r], f: ft}
  end
  def push(%LQueue{len: m_len, m_len: m_len, r: r, f: []} = lq, elem) do
    [_fh|ft] = Enum.reverse(r)
    %{lq | r: [elem], f: ft}
  end

  @doc """
  Pushes a new element to the front of the queue. When pushing to a full queue,
  the rear element will be discarded.

  ## Examples

      iex> [1, 2] |> LQueue.from_list(3) |> LQueue.push_front(5) |>
      ...> Enum.to_list()
      [5, 1, 2]

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.push_front(5) |>
      ...> Enum.to_list()
      [5, 1]
  """
  @spec push_front(t, element) :: t
  def push_front(%LQueue{len: len, m_len: m_len, f: f} = lq, elem)
      when len < m_len do
    %{lq | len: len + 1, f: [elem|f]}
  end
  def push_front(%LQueue{len: m_len, m_len: m_len, r: [_rh|rt], f: f} = lq, elem) do
    %{lq | r: rt, f: [elem|f]}
  end
  def push_front(%LQueue{len: m_len, m_len: m_len, r: [], f: f} = lq, elem) do
    [_rh|rt] = Enum.reverse(f)
    %{lq | r: rt, f: [elem]}
  end

  @doc """
  Pops an element from the front of the queue. If the queue is empty, `nil` is
  returned.

  ## Examples

      iex> {nil, lqueue} = [] |> LQueue.from_list(5) |> LQueue.pop()
      {nil, %LQueue{len: 0, m_len: 5, r: [], f: []}}
      iex> lqueue |> Enum.to_list() == []
      true

      iex> {1, lqueue} = [1, 2] |> LQueue.from_list(2) |> LQueue.pop()
      {1, %LQueue{len: 1, m_len: 2, r: [], f: [2]}}
      iex> lqueue |> Enum.to_list() == [2]
      true
  """
  @spec pop(t) :: {element | nil, t}
  def pop(%LQueue{len: 0, r: [], f: []} = lq) do
    {nil, lq}
  end
  def pop(%LQueue{len: len, f: [fh|ft]} = lq) do
    {fh, %{lq | len: len - 1, f: ft}}
  end
  def pop(%LQueue{len: len, r: r, f: []} = lq) do
    [fh|ft] = Enum.reverse(r)
    {fh, %{lq | len: len - 1, r: [], f: ft}}
  end

  @doc """
  Pops an element from the rear of the queue. If the queue is empty, `nil` is
  returned.

  ## Examples

      iex> {nil, lqueue} = [] |> LQueue.from_list(5) |> LQueue.pop_rear()
      {nil, %LQueue{len: 0, m_len: 5, r: [], f: []}}
      iex> lqueue |> Enum.to_list() == []
      true

      iex> {2, lqueue} = [1, 2] |> LQueue.from_list(2) |> LQueue.pop_rear()
      {2, %LQueue{len: 1, m_len: 2, r: [1], f: []}}
      iex> lqueue |> Enum.to_list() == [1]
      true
  """
  @spec pop_rear(t) :: {element | nil, t}
  def pop_rear(%LQueue{len: 0, r: [], f: []} = lq) do
    {nil, lq}
  end
  def pop_rear(%LQueue{len: len, r: [rh|rt]} = lq) do
    {rh, %{lq | len: len - 1, r: rt}}
  end
  def pop_rear(%LQueue{len: len, r: [], f: f} = lq) do
    [rh|rt] = Enum.reverse(f)
    {rh, %{lq | len: len - 1, r: rt, f: []}}
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
  @spec get(t) :: element | nil
  def get(%LQueue{len: 0, r: [], f: []}), do: nil
  def get(%LQueue{r: r, f: f}), do: get(r, f)

  @doc """
  Gets the rear element of the queue. It does not change the queue. When the
  queue is empty, `nil` is returned.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.get_rear()
      nil

      iex> [1, 2] |> LQueue.from_list(2) |> LQueue.get_rear()
      2
  """
  @spec get_rear(t) :: element | nil
  def get_rear(%LQueue{len: 0, r: [], f: []}), do: nil
  def get_rear(%LQueue{r: r, f: f}), do: get_rear(r, f)

  @doc """
  Drops the front element of the queue. When the queue is empty, it is not
  changed.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.drop() |> Enum.to_list()
      []

      iex> [1, 2, 3] |> LQueue.from_list(5) |> LQueue.drop() |>
      ...> Enum.to_list()
      [2, 3]
  """
  @spec drop(t) :: t
  def drop(%LQueue{len: 0, r: [], f: []} = lq) do
    lq
  end
  def drop(%LQueue{len: len, f: [_fh|ft]} = lq) do
    %{lq | len: len - 1, f: ft}
  end
  def drop(%LQueue{len: len, r: r, f: []} = lq) do
    [_fh|ft] = Enum.reverse(r)
    %{lq | len: len - 1, r: [], f: ft}
  end

  @doc """
  Drops the rear element of the queue. When the queue is empty, it is not
  changed.

  ## Examples

      iex> [] |> LQueue.from_list(5) |> LQueue.drop() |> Enum.to_list()
      []

      iex> [1, 2, 3] |> LQueue.from_list(5) |> LQueue.drop_rear() |>
      ...> Enum.to_list()
      [1, 2]
  """
  @spec drop_rear(t) :: t
  def drop_rear(%LQueue{len: 0, r: [], f: []} = lq) do
    lq
  end
  def drop_rear(%LQueue{len: len, r: [_rf|rt]} = lq) do
    %{lq | len: len - 1, r: rt}
  end
  def drop_rear(%LQueue{len: len, r: [], f: f} = lq) do
    [_rh|rt] = Enum.reverse(f)
    %{lq | len: len - 1, r: rt, f: []}
  end

  @doc """
  Converts the list to a queue. The elements are pushed into the queue starting
  with the list head. If the list has more elements than the `max_count` of
  the queue, those that can't fit in the queue (at the front) are discarded.

  ## Examples

      iex> [] |> LQueue.from_list(3) |> Enum.to_list()
      []

      iex> [1, 2, 3] |> LQueue.from_list(3) |> Enum.to_list()
      [1, 2, 3]

      iex> [1, 2, 3, 4, 5] |> LQueue.from_list(3) |> Enum.to_list()
      [3, 4, 5]
  """
  @spec from_list([element], max_count) :: t
  def from_list([], m_len) when m_len > 0, do: new(m_len)
  def from_list(list, m_len) when is_list(list) and m_len > 0 do
    len = list |> length |> min(m_len)
    r = list |> Enum.reverse() |> Enum.take(m_len)
    %LQueue{len: len, m_len: m_len, r: r, f: []}
  end

  ## Internal functions
  defp get(_, [fh|_]), do: fh
  defp get([rh], []), do: rh
  defp get([_|rt], []), do: List.last(rt)

  defp get_rear([rh|_], _), do: rh
  defp get_rear([], [fh]), do: fh
  defp get_rear([], [_|ft]), do: List.last(ft)
end

defimpl Enumerable, for: LQueue do

  @spec count(LQueue.t) :: {:ok, non_neg_integer}
  def count(%LQueue{len: len}), do: {:ok, len}

  @spec member?(LQueue.t, term) :: {:ok, boolean}
  def member?(%LQueue{len: len, r: r, f: f}, value) when len > 0 do
    {:ok, Enum.member?(f, value) or Enum.member?(r, value)}
  end
  def member?(%LQueue{len: 0, r: [], f: []}, _value) do
    {:ok, false}
  end

  @spec reduce(LQueue.t, Enumerable.acc, Enumerable.reducer) ::
    Enumerable.result
  def reduce(%LQueue{}, {:halt, acc}, _fun) do
    {:halted, acc}
  end
  def reduce(%LQueue{} = lq, {:suspend, acc}, fun) do
    {:suspended, acc, &reduce(lq, &1, fun)}
  end
  def reduce(%LQueue{len: len, f: [fh|ft]} = lq, {:cont, acc}, fun) do
    reduce(%{lq | len: len - 1, f: ft}, fun.(fh, acc), fun)
  end
  def reduce(%LQueue{len: len, r: r, f: []} = lq, {:cont, acc}, fun)
      when r != [] do
    [fh|ft] = Enum.reverse(r)
    reduce(%{lq | len: len - 1, r: [], f: ft}, fun.(fh, acc), fun)
  end
  def reduce(%LQueue{r: [], f: []}, {:cont, acc}, _fun) do
    {:done, acc}
  end
end

defimpl Collectable, for: LQueue do

  @spec into(LQueue.t) ::
    {term, (term, Collectable.command -> LQueue.t | term)}
  def into(%LQueue{} = lq), do: {lq, &into(&1, &2)}

  defp into(%LQueue{} = lq, {:cont, elem}), do: LQueue.push(lq, elem)
  defp into(%LQueue{} = lq, :done), do: lq
  defp into(_lq, :halt), do: :ok
end

defimpl Inspect, for: LQueue do

  @spec inspect(LQueue.t, Keyword.t) :: String.t
  def inspect(%LQueue{} = lq, _opts) do
    "#LQueue<#{lq |> Enum.to_list() |> inspect}>"
  end
end
