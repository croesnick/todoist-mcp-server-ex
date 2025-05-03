defmodule TodoistMcpServer.Mcp.Methods.ResourcesSubscribe do
  @moduledoc """
  Module for handling the `resources/subscribe` method in the Todoist MCP server.

  This method is used by the client to request resources/updated notifications from the server
  whenever a particular resource changes.

  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L558
  """

  @typedoc """
  Request to subscribe to resource updates.
  """
  @type request :: %{
          required(:id) => String.t() | integer(),
          # Must be: "resources/subscribe"
          required(:method) => String.t(),
          required(:jsonrpc) => String.t(),
          required(:params) => %{
            # The URI of the resource to subscribe to. The URI can use any protocol;
            # it is up to the server how to interpret it.
            required(:uri) => String.t(),
            optional(:_meta) => %{
              optional(:progressToken) => String.t()
            }
          }
        }

  @typedoc """
  Result of a subscription request. This is an empty result indicating success.
  """
  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{}
        }

  @doc """
  Handles a resources/subscribe request.

  This sets up a subscription for the specified resource URI, which will cause the server
  to send notifications/resources/updated notifications to the client whenever the resource changes.
  """
  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    # For now, just return an empty result
    # In a real implementation, this would set up a subscription for the resource
    result = %{}

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
