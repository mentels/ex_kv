defmodule KV.Registry do
  use GenServer
  
  ## API
  
  @doc """
  Starts the registry.
  """
  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: name)
  end
  
  @doc """
  Looks up the bucket pid for `name` stored in `server`.
  
  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) when is_atom(server) do
    case :ets.lookup(server, name) do
      [{^name, bucket}] -> {:ok, bucket}
      [] -> :error
    end
  end
  
  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end
  
  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end
  
  ## Server Callbacks
  
  def init(name) do
    names = :ets.new(name,[:named_table, read_concurrency: true])
    monitors = %{}
    {:ok, {names, monitors}}
  end
  
  def handle_call({:lookup, name}, _from, {names, _}=state) do
    {:reply, Map.fetch(names, name), state}
  end
  
  def handle_call({:create, name}, _from, {names, monitors}=state) do
    case lookup(names, name) do
      {:ok, bucket} ->
        {:reply, bucket, state}
      :error ->
        {:ok, bucket} = KV.Bucket.Supervisor.start_bucket()
        monitor = Process.monitor(bucket)
        :ets.insert(names, {name, bucket})
        {:reply, bucket, {names, Map.put(monitors, monitor, name)}}
    end
  end
  
  def handle_info({:DOWN, monitor, :process, _, _}, {names, monitors}) do
    {name, monitors} = Map.pop(monitors, monitor)
    :ets.delete(names, name)
    {:noreply, {names, monitors}}
  end
  
end
