defmodule TodoistMcpServer.Mcp.Tools.Tasks do
  @moduledoc """
  Module for handling the `tools/tasks` method in the Todoist MCP server.
  It provides task-related tools, formatting them to be suitable for the MCP protocol.
  """

  @behaviour TodoistMcpServer.Mcp.Tools.Behaviour

  alias TodoistMcpServer.Todoist.Api, as: TodoistApi
  alias TodoistMcpServer.Mcp.Methods.ToolsCall

  @spec handle_call(String.t(), TodoistApi.get_tasks_request_params()) ::
          {:ok, list(ToolsCall.content())} | {:error, String.t()}
  def handle_call("list_tasks", args) do
    result =
      args
      |> TodoistApi.get_tasks()
      |> then(fn {:ok, tasks} -> Enum.map(tasks, &content/1) end)

    {:ok, result}
  end

  @spec content(TodoistApi.task()) :: ToolsCall.embedded_resource()
  defp content(task) do
    uri = TodoistApi.task_url(task["id"])

    annotations = %{
      audience: [:user],
      priority: 1.0
    }

    ToolsCall.json_resource(uri, task, annotations)
  end
end
