defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request
  to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    first = :binary.first(bucket)

    entry = Enum.find(table, fn {enum, _node} ->
      first in enum
    end) || no_entry_error(bucket)
    
    case entry do
      {_, this_node} when this_node == node() ->
        apply(mod, fun, args)
      {_, other_node} ->
        {KV.RouterTasks, other_node}
        |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
        |> Task.await()
    end
  end
  
  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect bucket} in table #{inspect table}"
  end
  
  @doc """
  The routing table.
  """
  def table do
    # [{?a..?m, :"foo@szm-mac"},
    #  {?n..?z, :"bar@szm-mac"}]
    Application.fetch_env!(:kv, :routing_table)
  end
  
end