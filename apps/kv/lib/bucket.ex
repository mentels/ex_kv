defmodule KV.Bucket do
  
  @doc """
  Starts a new bucket.
  """
  def start_link(), do: Agent.start_link fn -> %{} end


  @doc """
  Pust the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &(Map.put(&1, key, value)))
  end
  
  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, fn %{^key => value} -> value; _ -> nil end)
  end

  @doc """
  Deletes `key` from `bucket`.

  Returns the current value of the `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &(Map.pop(&1, key)))
  end
    
end
