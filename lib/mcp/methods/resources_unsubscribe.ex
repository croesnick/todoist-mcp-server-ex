defmodule TodoistMcpServer.Mcp.Methods.ResourcesUnsubscribe do
  @moduledoc """
  Module for handling the `resources/unsubscribe` method in the Todoist MCP server.

  This method is used by the client to request cancellation of resources/updated notifications from the server.
  This should follow a previous resources/subscribe request.

  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L558
  """

  @typedoc """
  Request to unsubscribe from resource updates.
  """
  @type request :: %{
          required(:id) => String.t() | integer(),
          # Must be: "resources/unsubscribe"
          required(:method) => String.t(),
          required(:jsonrpc) => String.t(),
          required(:params) => %{
            # The URI of the resource to unsubscribe from.
            required(:uri) => String.t(),
            optional(:_meta) => %{
              optional(:progressToken) => String.t()
            }
          }
        }

  @typedoc """
  Result of an unsubscription request. This is an empty result indicating success.
  """
  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{}
        }

  @doc """
  Handles a resources/unsubscribe request.

  This cancels a subscription for the specified resource URI, which will stop the server
  from sending notifications/resources/updated notifications to the client when the resource changes.
  """
  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    # For now, just return an empty result
    # In a real implementation, this would cancel a subscription for the resource
    result = %{}

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
