defmodule Merkex do
  defrecord Tree, gb:            :gb_trees.empty, 
                  edge:          :gb_trees.empty, 
                  width:         0, 
                  hash_function: nil, 
                  data:          []

  def new(x, f // &(:crypto.hash(:sha, &1))) when is_list(x) do
    new1(Enum.reverse(x), new_tree(f))
  end

  def insert(x, t = Tree[gb: gb, width: w, data: data, hash_function: f]) do
    IO.puts "INSERTING #{x}!"
    append = term_to_binary(x)
    t.update(data: [append|data], 
             width: w+1,
             gb: :gb_trees.insert({0, w}, f.(data), gb),
             edge: :gb_trees.empty)
    |> update(0, w+1)
  end

  defp new1([],     Tree[] = t), do: t
  defp new1([x|xs], Tree[] = t), do: insert(x, new1(xs, t))

  # update(tree, current height, length at this height) -> tree1
  defp update(t = Tree[], _, 1), do: t
  defp update(t = Tree[gb: gb, edge: edge, width: width, hash_function: f], h, l) do
    l1 = trunc(l/2) + rem(l,2) # amount of elements at height = h+1
    right0 = :gb_trees.get({h,l-1}, gb) # rightmost element
    right1 = :gb_trees.get({h,l-2}, gb) # the one before the rightmost
    edge = :gb_trees.enter({h,l-1}, right0, edge)
    edge = :gb_trees.enter({h,l-2}, right1, edge)

    if rem(l,2) == 1 do # if current amount of elements is odd
      [gb, edge] = lc gb_i inlist [gb, edge], do: update_gb(gb_i, h+1, trunc(l/2), right0)
      t.update(gb: gb, edge: edge, width: width) |> update(h+1, l1)
    else # if current amount of elements is even
      [gb, edge] = lc gb_i inlist [gb, edge], do: update_gb(gb_i, h+1, trunc(l/2)-1, f.(right1 <> right0))
      t.update(gb: gb, edge: edge, width: width) |> update(h+1, l1)
    end
  end

  defp update_gb(gb, height, offset, data) do
    IO.puts "Updating <#{inspect height},#{inspect offset}> := #{inspect data}"
    :gb_trees.enter({height,offset}, data, gb)
  end

  defp new_tree(f) do 
    (Tree.new).hash_function(f)
  end

  defimpl Access, for: Tree do
    def access(Tree[gb: gb], {h,l}) do
      if (:gb_trees.is_defined({h,l}, gb)) do
        :gb_trees.get({h,l}, gb)
      end
    end
  end
end
