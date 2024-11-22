defmodule Anoma.Node.Examples.EIndexer do
  alias Anoma.Node
  alias Node.Examples.{ETransaction, ENode}
  alias Node.Transaction.Storage
  alias Node.Utility.Indexer
  alias Anoma.TransparentResource.{Resource, Transaction}

  def indexer_reads_height(node_id \\ Node.example_random_id()) do
    ETransaction.inc_counter_submit_after_read(node_id)
    Indexer.start_link(node_id: node_id)
    1 = Indexer.get(node_id, :blocks)

    node_id
  end

  def indexer_reads_nullifier(node_id \\ Node.example_random_id()) do
    ENode.start_node(node_id: node_id)
    Indexer.start_link(node_id: node_id)
    updates = Storage.updates_table(node_id)
    values = Storage.values_table(node_id)

    nlf = %Resource{} |> Resource.nullifier()
    set = MapSet.new([nlf])

    write_new(updates, values, [1], set, nil)

    ^set = Indexer.get(node_id, :nlfs)

    node_id
  end

  def indexer_reads_nullifiers(node_id \\ Node.example_random_id()) do
    ENode.start_node(node_id: node_id)
    Indexer.start_link(node_id: node_id)
    updates = Storage.updates_table(node_id)
    values = Storage.values_table(node_id)

    nlf1 = %Resource{rseed: "random1"} |> Resource.nullifier()
    nlf2 = %Resource{rseed: "random2"} |> Resource.nullifier()
    set = MapSet.new([nlf1, nlf2])

    write_new(updates, values, [1], set, nil)

    ^set = Indexer.get(node_id, :nlfs)

    node_id
  end

  def indexer_reads_commitments(node_id \\ Node.example_random_id()) do
    ENode.start_node(node_id: node_id)
    Indexer.start_link(node_id: node_id)
    updates = Storage.updates_table(node_id)
    values = Storage.values_table(node_id)

    resource1 = %Resource{rseed: "random1"} |> Resource.nullifier()
    resource2 = %Resource{rseed: "random2"} |> Resource.nullifier()
    set = MapSet.new([resource1, resource2])

    write_new(updates, values, [1], nil, set)

    ^set = Indexer.get(node_id, :cms)

    node_id
  end

  def indexer_does_not_read_revealed(node_id \\ Node.example_random_id()) do
    ENode.start_node(node_id: node_id)
    Indexer.start_link(node_id: node_id)
    updates = Storage.updates_table(node_id)
    values = Storage.values_table(node_id)

    resource = %Resource{rseed: "random1"}
    nul1 = resource |> Resource.nullifier()
    com1 = resource |> Resource.commitment()
    nulfs = MapSet.new([nul1])
    coms = MapSet.new([com1])

    write_new(updates, values, [1], nulfs, coms)

    newset = MapSet.new([])
    ^newset = Indexer.get(node_id, :unrevealed)

    node_id
  end

  def indexer_reads_unrevealed(node_id \\ Node.example_random_id()) do
    ENode.start_node(node_id: node_id)
    Indexer.start_link(node_id: node_id)
    updates = Storage.updates_table(node_id)
    values = Storage.values_table(node_id)

    resource = %Resource{rseed: "random1"}
    nul1 = resource |> Resource.nullifier()
    com1 = resource |> Resource.commitment()
    com2 = %Resource{rseed: "random2"} |> Resource.commitment()
    nulfs = MapSet.new([nul1])
    coms = MapSet.new([com1, com2])

    write_new(updates, values, [1], nulfs, coms)

    newset = MapSet.new([com2])
    ^newset = Indexer.get(node_id, :unrevealed)

    node_id
  end

  def indexer_reads_anchor(node_id \\ Node.example_random_id()) do
    ENode.start_node(node_id: node_id)
    Indexer.start_link(node_id: node_id)
    updates = Storage.updates_table(node_id)
    values = Storage.values_table(node_id)

    hash = "I am a root at height 1"

    :mnesia.transaction(fn ->
      :mnesia.write({updates, ["anoma", :anchor |> Atom.to_string()], [1]})

      :mnesia.write(
        {values, {1, ["anoma", :anchor |> Atom.to_string()]}, hash}
      )
    end)

    ^hash = Indexer.get(node_id, :root)

    node_id
  end

  def indexer_reads_recent_anchor(node_id \\ Node.example_random_id()) do
    indexer_reads_anchor(node_id)
    updates = Storage.updates_table(node_id)
    values = Storage.values_table(node_id)

    hash = "I am a root at height 2"

    :mnesia.transaction(fn ->
      :mnesia.write({updates, ["anoma", :anchor |> Atom.to_string()], [2, 1]})

      :mnesia.write(
        {values, {2, ["anoma", :anchor |> Atom.to_string()]}, hash}
      )
    end)

    ^hash = Indexer.get(node_id, :root)

    node_id
  end

  def indexer_works_with_transactions(node_id \\ Node.example_random_id()) do
    Anoma.Node.Examples.ETransaction.submit_successful_trivial_swap(node_id)

    base_swap = Examples.ETransparent.ETransaction.swap_from_actions()

    nulfs = base_swap |> Transaction.nullifiers()
    coms = base_swap |> Transaction.commitments()

    ^nulfs = Indexer.get(node_id, :nlfs)
    ^coms = Indexer.get(node_id, :cms)

    node_id
  end

  defp write_new(updates, values, heights, nlfs, coms) do
    :mnesia.transaction(fn ->
      if nlfs do
        :mnesia.write(
          {updates, ["anoma", :nullifiers |> Atom.to_string()], heights}
        )
      end

      if coms do
        :mnesia.write(
          {updates, ["anoma", :commitments |> Atom.to_string()], heights}
        )
      end

      :mnesia.write(
        {values, {hd(heights), ["anoma", :nullifiers |> Atom.to_string()]},
         nlfs}
      )

      :mnesia.write(
        {values, {hd(heights), ["anoma", :commitments |> Atom.to_string()]},
         coms}
      )
    end)
  end
end
