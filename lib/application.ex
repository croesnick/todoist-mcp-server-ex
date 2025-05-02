defmodule TodoistMcpServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    port = 4000

    children = [
      # Start the worker GenServer
      {TodoistMcpServer.Mcp.Server, []},

      # Start the TCP server
      {TodoistMcpServer.JsonRpcServer, [port: port]}
    ]

    Logger.info("Starting application with JSON-RPC server on port #{port}")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TodoistMcpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
