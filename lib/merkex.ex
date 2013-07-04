defmodule Merkex do
  defrecord Tree, gb: :gb_trees.empty(), width: 0
  defrecordp :data, id: 0, binary: ""

  defrecordp :state, [ tree: Tree.new(),
                       data: :ordsets.new() ]

  @spec new(list(term())) :: tuple( atom(), #state
                                    Tree.t(),
                                    tuple( atom(), #data
                                           list(tuple(atom(), non_neg_integer(), binary())) ) )
  def new([]),     do: state()
  def new([x|xs]), do: insert(x, new(xs))

  def insert(_, tree) do 
    data = state(tree, :data)
    size = :ordsets.size(data)
    state(tree, data: :ordsets.add_element({size, nil}, data))
  end
end
