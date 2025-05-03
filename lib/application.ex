defmodule TodoistMcpServer.Application do
  @moduledoc false

  use Application
  require Logger

  @impl true
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      {TodoistMcpServer.Todoist.Api, %{api_key: System.get_env("TODOIST_API_KEY")}},
      {TodoistMcpServer.Mcp.Server, %{tools: tools()}},
      {TodoistMcpServer.Transport.StdioServer, %{observer: [TodoistMcpServer.Mcp.Server]}}
    ]

    Logger.info("Starting Todoist MCP Server")

    opts = [strategy: :one_for_one, name: TodoistMcpServer.Supervisor]
    result = Supervisor.start_link(children, opts)

    result
  end

  @spec tools() :: TodoistMcpServer.Mcp.Server.tools()
  defp tools do
    [{"list_tasks", TodoistMcpServer.Mcp.Tools.Tasks}]
  end

end
