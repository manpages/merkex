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
    enter(state(tree: Tree[gb: gb, width: w+1], data: [data|state(s, :data)]))
  end

  defp new1([]),     do: state()
  defp new1([x|xs]), do: insert(x, new1(xs))

  defp enter(x), do: x

  defimpl Access, for: Tree do
    def access(Tree[gb: gb, width: w], {x,y}) do
      if y > trunc(w/(x+1)) or x > trunc(w/2)+1, do: nil, else: :gb_trees.get {x, y}, gb
    end
  end
end
