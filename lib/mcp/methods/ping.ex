defmodule TodoistMcpServer.Mcp.Methods.Ping do
  @moduledoc """
  Module for handling the `ping` method in the Todoist MCP server.
  """

  @type request :: %{
          required(:id) => String.t() | integer(),
          optional(:params) => map()
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          # Must be an empty map [according to the specification](https://modelcontextprotocol.io/specification/2025-03-26/basic/utilities/ping).
          required(:result) => %{}
        }

  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    %{
      id: id,
      jsonrpc: "2.0",
      result: %{}
    }
  end
end
