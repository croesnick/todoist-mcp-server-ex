defmodule TodoistMcpServer.Mcp.Methods.ToolsList do
  @moduledoc """
  Module for handling the `tools/list` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L675
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

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            # An opaque token representing the pagination position after the last returned result.
            # If present, there may be more results available.
            optional(:nextCursor) => String.t(),
            required(:tools) => list(tool())
          }
        }

  @type tool :: %{
          # The name of the tool.
          required(:name) => String.t(),

          # A human-readable description of the tool.
          # This can be used by clients to improve the LLM's understanding of available tools. It can be thought of like a "hint" to the model.
          optional(:description) => String.t(),

          # A JSON Schema object defining the expected parameters for the tool.
          required(:inputSchema) => %{
            required(:type) => String.t(),
            optional(:properties) => %{optional(String.t()) => map()},
            optional(:required) => list(String.t())
          },

          # Optional additional tool information.
          optional(:annotations) => tool_annotations()
        }

  @type tool_annotations :: %{
          # A human-readable title for the tool.
          optional(:title) => String.t(),

          # If true, the tool does not modify its environment.
          #
          # Default: false
          optional(:readOnlyHint) => boolean(),

          # If true, the tool may perform destructive updates to its environment.
          # If false, the tool performs only additive updates.
          #
          # (This property is meaningful only when `readOnlyHint == false`)
          #
          # Default: true
          optional(:destructiveHint) => boolean(),

          # If true, calling the tool repeatedly with the same arguments
          # will have no additional effect on its environment.
          #
          # (This property is meaningful only when `readOnlyHint == false`)
          #
          # Default: false
          optional(:idempotentHint) => boolean(),

          # If true, this tool may interact with an "open world" of external entities.
          # If false, the tool's domain of interaction is closed.
          #
          # For example, the world of a web search tool is open, whereas that of a memory tool is not.
          #
          # Default: true
          optional(:openWorldHint) => boolean()
        }

  @doc """
  Handles the [`tools/list`](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L675) method.
  """
  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    result =
      %{
        tools: [%{
          name: "list_tasks",
          description: "List all tasks in Todoist",
          inputSchema: %{
            type: "object",
            properties: %{
              project_id: %{
                type: "string",
                description: "The ID of the project to list tasks from"
              },
              limit: %{
                type: "number",
                description: "The number of objects to return"
              },
              required: []
            },
          },
          annotations: %{
            title: "List all tasks in Todoist",
            readOnlyHint: true,
            destructiveHint: false,
            idempotentHint: true,
            openWorldHint: false
          }
        }]
      }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
