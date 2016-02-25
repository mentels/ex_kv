defmodule KVServer do
  use Application
  require Logger
  
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    
    children = [
      # worker(module, args, options \\ [])
      worker(Task.Supervisor, [[name: KVServer.TaskSupervisor]]),
      worker(Task, [KVServer,
                    :accept,
                    [Application.fetch_env!(:kv_server, :port)]])
    ]
    
    opts = [strategy: :one_for_one, name: KVServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
  
  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary,
                                           packet: :line,
                                           active: false,
                                           reuseaddr: true])
    Logger.info "Accepting connections on #{port}"
    loop_acceptor(socket)
  end
  
  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(KVServer.TaskSupervisor,
      fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end
  
  defp serve(socket) do
    msg = with {:ok, data} <- read_line(socket),
               {:ok, command} <- KVServer.Command.parse(data),
               do: KVServer.Command.run(command)
    write_line(socket, msg)
    serve(socket)
  end
  
  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end
  
  defp write_line(socket, {:ok, text}) do
    :ok = :gen_tcp.send(socket, text)
  end
  
  defp write_line(socket, {:error, :unknown_command}) do
    :ok = :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    # The connection was closed, exit politely.
    exit(:shutdown)
  end

  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end
  
  defp write_line(socket, {:error, error}) do
    # Unknown error. Write to the client and exit.
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
  
end
