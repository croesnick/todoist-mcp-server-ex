defmodule TodoistMcpServer.Mcp.Methods.ResourcesRead do
  @moduledoc """
  Module for handling the `resources/read` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L371
  """

  @type request :: %{
          required(:id) => String.t() | integer(),
          required(:params) => %{
            # The URI of the resource to read. The URI can use any protocol; it is up to the server how to interpret it.
            required(:uri) => String.t(),
            optional(:_meta) => %{
              optional(:progressToken) => String.t()
            }
          }
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            required(:contents) => list(text_resource_contents() | blob_resource_contents())
          }
        }

  @type resource_contents :: %{
          # The URI of this resource.
          optional(:uri) => String.t(),
          # The MIME type of this resource, if known.
          optional(:mimeType) => String.t()
        }

  @type text_resource_contents :: %{
          # The URI of this resource.
          optional(:uri) => String.t(),
          # The MIME type of this resource, if known.
          optional(:mimeType) => String.t(),
          # The text of the item. This must only be set if the item can actually be represented as text (not binary data).
          required(:text) => String.t()
        }

  @type blob_resource_contents :: %{
          # The URI of this resource.
          optional(:uri) => String.t(),
          # The MIME type of this resource, if known.
          optional(:mimeType) => String.t(),
          # A base64-encoded string representing the binary data of the item.
          # @format byte
          required(:blob) => String.t()
        }

  @doc """
  Handles the [`resources/read`](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L371) method.
  """
  @spec handle(request()) :: result()
  def handle(%{id: id, params: %{uri: _uri}} = _request) do
    result =
      %{
        contents: []
      }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
