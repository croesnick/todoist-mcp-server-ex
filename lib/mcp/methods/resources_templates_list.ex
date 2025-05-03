defmodule TodoistMcpServer.Mcp.Methods.ResourcesTemplatesList do
  @moduledoc """
  Module for handling the `resources/templates/list` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L1022
  """

  alias TodoistMcpServer.Mcp.Methods.SharedTypes

  @type request :: %{
          required(:id) => String.t() | integer(),
          # Must be: "resources/templates/list"
          required(:method) => String.t(),
          required(:jsonrpc) => String.t(),
          optional(:params) => %{
            optional(:_meta) => %{
              optional(:progressToken) => String.t()
            },
            optional(:cursor) => String.t()
          }
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            required(:resourceTemplates) => list(resource_template()),
            optional(:nextCursor) => String.t()
          }
        }

  @type resource_template :: %{
          # A URI template (according to RFC 6570) that can be used to construct resource URIs.
          # @format uri-template
          required(:uriTemplate) => String.t(),

          # A human-readable name for the type of resource this template refers to.
          # This can be used by clients to populate UI elements.
          required(:name) => String.t(),

          # A description of what this template is for.
          # This can be used by clients to improve the LLM's understanding of available resources.
          # It can be thought of like a "hint" to the model.
          optional(:description) => String.t(),

          # The MIME type for all resources that match this template.
          # This should only be included if all resources matching this template have the same type.
          optional(:mimeType) => String.t(),

          # Optional annotations for the client.
          optional(:annotations) => SharedTypes.annotations()
        }

  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    result =
      %{
        resourceTemplates: [],
      }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
