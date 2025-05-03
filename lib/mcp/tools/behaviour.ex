defmodule TodoistMcpServer.Mcp.Tools.Behaviour do
  @moduledoc """
  Behaviour for handling tools in the Todoist MCP server.
  """

  alias TodoistMcpServer.Mcp.Methods.ToolsCall

  @callback handle_call(tool :: String.t(), args :: map()) ::
              {:ok, list(ToolsCall.content())} | {:error, String.t()}
end
