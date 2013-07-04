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
    IO.puts "!"
    state(tree, 
          data: :ordsets.add_element({:ordsets.size(state(tree, :data)), nil}, state(tree, :data)))
  end
end
