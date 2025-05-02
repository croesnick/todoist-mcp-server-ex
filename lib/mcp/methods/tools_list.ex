defmodule TodoistMcpServer.Mcp.Methods.ToolsList do
  @moduledoc """
  Module for handling the `tools_list` method in the Todoist MCP server.
  """

  @typedoc """
  Base result type that allows for additional metadata and arbitrary properties.
  """
  @type result :: %{
          optional(:_meta) => %{optional(String.t()) => any()},
          optional(String.t()) => any()
        }

  @typedoc """
  Paginated result that extends the base result type.
  """
  @type paginated_result ::
          result()
          | %{
              optional(:nextCursor) => String.t()
            }

  @typedoc """
  Tool representation.
  """
  @type tool :: map()

  @typedoc """
  The server's response to a tools/list request from the client.
  """
  @type list_tools_result ::
          paginated_result()
          | %{
              :tools => [tool()]
            }

  @doc """
  Handles the [`tools/list`](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L675) method.

  ## Returns

    - A map containing the result of the method call.
  """
  @spec handle() :: list_tools_result()
  def handle do
    # noop for now
    %{
      tools: []
    }
  end
end
