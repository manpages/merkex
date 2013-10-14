defmodule Merkex do
  defrecord Tree, gb: :gb_trees.empty(), width: 0, hash_function: nil, data: []

  def new(x, f // &(:crypto.hash(:sha, &1))) when is_list(x) do
    new1(Enum.reverse(x), new_tree(f))
  end

  def insert(x, t = Tree[gb: gb, width: w, data: data, hash_function: f]) do
    IO.puts "INSERTING #{x}!"
    append = term_to_binary(x)
    t = t.update(data: [append|data], width: w+1)
    t.gb(:gb_trees.insert({0, w}, f.(data), gb)) |> update(0, w+1)
  end

  defp new1([],     Tree[] = t), do: t
  defp new1([x|xs], Tree[] = t), do: insert(x, new1(xs, t))

  # update(tree, current height, length at this height) -> tree1
  defp update(t = Tree[], _, 1), do: t
  defp update(t = Tree[gb: gb, width: w], h, l) do
    l1 = trunc(l/2) + rem(l,2) # amount of elements at height = h+1

    if rem(l,2) == 1 do # if current amount of elements is odd
      update(t.update([ gb: :gb_trees.enter( {h+1, trunc(l/2)},
                                                 :gb_trees.get({h,l-1}, gb),
                                                  gb ),
                                 width: w ]),
                      h+1, l1)
    else # if current amount of elements is even
      left  = :gb_trees.get({h,l-1}, gb) # l-1 = id of the last element of height = h
      right = :gb_trees.get({h,l-2}, gb)
      update(t.update([ gb: :gb_trees.enter( {h+1, trunc(l/2)-1},
                                                 :crypto.hash(:sha, [left, right]),
                                                 gb ),
                                 width: w ]),
                      h+1, l1)
    end
  end

  defp new_tree(f) do 
    (Tree.new).hash_function(f)
  end

  defimpl Access, for: Tree do
    def access(Tree[gb: gb], {x,y}) do
      if (:gb_trees.is_defined({x,y}, gb)) do
        :gb_trees.get({x, y}, gb)
      end
    end
  end
end
