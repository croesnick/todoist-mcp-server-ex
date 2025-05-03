defmodule TodoistMcpServer.Mcp.Methods.ResourcesList do
  @moduledoc """
  Module for handling the `resources/list` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L344
  """

  @type request :: %{
          required(:id) => String.t() | integer(),
          optional(:params) => %{
            optional(:_meta) => %{
              optional(:progressToken) => String.t()
            },
            optional(:cursor) => String.t()
          }
        }

  @type resource :: %{
          required(:uri) => String.t(),
          required(:name) => String.t(),
          optional(:description) => String.t(),
          optional(:mimeType) => String.t(),
          optional(:annotations) => map(),
          optional(:size) => integer()
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            required(:resources) => [resource()],
            optional(:nextCursor) => String.t()
          }
        }

  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    result = %{
      resources: []
    }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
