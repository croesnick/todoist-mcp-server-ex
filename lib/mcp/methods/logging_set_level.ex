defmodule TodoistMcpServer.Mcp.Methods.LoggingSetLevel do
  @moduledoc """
  Module for handling the `logging/setLevel` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L1095
  """

  @type request :: %{
          required(:id) => String.t() | integer(),
          required(:params) => %{
            # The level of logging that the client wants to receive from the server.
            # The server should send all logs at this level and higher (i.e., more severe)
            # to the client as notifications/message.
            required(:level) => logging_level()
          }
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{}
        }

  @type logging_level :: String.t()

  @spec handle(request()) :: result()
  def handle(%{id: id, params: %{level: _level}} = _request) do
    # In a real implementation, this would set the logging level
    # based on the request parameters

    %{
      id: id,
      jsonrpc: "2.0",
      result: %{}
    }
  end

  # Handle case where params might be missing
  def handle(%{id: id} = _request) do
    %{
      id: id,
      jsonrpc: "2.0",
      result: %{}
    }
  end
end
