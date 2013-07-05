defmodule Merkex do
  defrecord Tree, gb: :gb_trees.empty(), width: 0
  defrecordp :data, id: 0, binary: ""

  defrecordp :state, [ tree: Tree.new(),
                       data: [] ]

  @spec new(list(term())) :: tuple( atom(), #state
                                    Tree.t(),
                                    tuple( atom(), #data
                                           list(binary()) ) )
  def new(x) when is_list(x), do: new1(:lists.reverse x)
  def new1([]),     do: state()
  def new1([x|xs]), do: insert(x, new1(xs))

  def insert(x, s) do
    Tree[gb: gb, width: w] = state(s, :tree)
    gb = :gb_trees.insert({0, w}, term_to_binary(x), gb)
    state(tree: Tree[gb: gb, width: w+1], data: [x|state(s, :data)])
  end
end
