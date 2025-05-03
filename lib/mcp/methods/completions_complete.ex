defmodule TodoistMcpServer.Mcp.Methods.CompletionsComplete do
  @moduledoc """
  Module for handling the `completion/complete` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L1022
  """

  @type request :: %{
          required(:id) => String.t() | integer(),
          required(:method) => String.t(),
          optional(:params) => %{
            optional(:_meta) => %{
              optional(:progressToken) => String.t()
            },
            required(:ref) => prompt_reference() | resource_reference(),
            required(:argument) => %{
              # The name of the argument
              required(:name) => String.t(),
              # The value of the argument to use for completion matching
              required(:value) => String.t()
            }
          }
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            required(:completion) => %{
              # An array of completion values. Must not exceed 100 items.
              required(:values) => list(String.t()),
              # The total number of complet`0ion options available. This can exceed the number of values actually sent in the response.
              optional(:total) => integer(),
              # Indicates whether there are additional completion options beyond those provided in the current response, even if the exact total is unknown.
              optional(:hasMore) => boolean()
            }
          }
        }

  @type prompt_reference :: %{
          required(:type) => String.t(),
          # The name of the prompt or prompt template
          required(:name) => String.t()
        }

  @type resource_reference :: %{
          required(:type) => String.t(),
          # The URI or URI template of the resource.
          required(:uri) => String.t()
        }

  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    result = %{
      completion: %{
        values: []
      }
    }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
