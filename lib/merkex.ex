defmodule Merkex do
  defrecord Tree, gb: :gb_trees.empty(), width: 0
  defrecordp :data, id: 0, binary: ""

  defrecordp :state, [ tree: Tree.new(),
                       data: [] ]

  @spec new(list(term())) :: {atom, Tree.t, {atom, [binary()]}}
  def new(x) when is_list(x), do: new1(:lists.reverse x)

  @spec insert(term, {atom, Tree.t, {atom, [binary()]}}) :: {atom, Tree.t, {atom, [binary()]}}
  def insert(x, s) do
    Tree[gb: gb, width: w] = state(s, :tree)
    data = term_to_binary(x)
    gb = :gb_trees.insert({0, w}, :crypto.hash(:sha, data), gb)
    state(tree: update(0, w+1, Tree[gb: gb, width: w+1]), data: [data|state(s, :data)])
  end

  defp new1([]),     do: state()
  defp new1([x|xs]), do: insert(x, new1(xs))

  defp update(_, 1, t), do: t
  defp update(h, l, Tree[gb: gb, width: w]) do
    l1 = trunc(l/2) + rem(l,2) # amount of elements at height = h+1

    if rem(l,2) == 1 do # if current amount of elements is odd
      update(h+1, l1, Tree[ gb: :gb_trees.enter( {h+1, trunc(l/2)},
                                                 :gb_trees.get({h,l-1}, gb),
                                                  gb ),
                            width: w ])
    else # if current amount of elements is even
      left  = :gb_trees.get({h,l-1}, gb) # l-1 = id of the last element of height = h
      right = :gb_trees.get({h,l-2}, gb)
      update(h+1, l1, Tree[ gb: :gb_trees.enter( {h+1, trunc(l/2)-1},
                                                 :crypto.hash(:sha, [left, right]),
                                                 gb ),
                            width: w ])
    end
  end

  defimpl Access, for: Tree do
    def access(Tree[gb: gb, width: w], {x,y}) do
      if y > trunc(w/(x+1)) or x > trunc(w/2)+1, do: nil, else: :gb_trees.get({x, y}, gb)
    end
  end
end
