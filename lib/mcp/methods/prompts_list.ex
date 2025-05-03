defmodule TodoistMcpServer.Mcp.Methods.PromptsList do
  @moduledoc """
  Module for handling the `prompts/list` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L558
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
            prompts: list(prompt())
          }
        }

  @type prompt :: %{
          # The name of the prompt or prompt template.
          required(:name) => String.t(),
          # An optional description of what this prompt provides
          optional(:description) => String.t(),
          # A list of arguments to use for templating the prompt.
          optional(:arguments) => [argument()]
        }

  @type argument :: %{
          # The name of the argument.
          required(:name) => String.t(),
          # A human-readable description of the argument.
          optional(:description) => String.t(),
          # Whether this argument must be provided.
          optional(:required) => boolean()
        }

  @spec handle(request()) :: result()
  def handle(%{id: id} = _request) do
    result =
      %{
        prompts: []
      }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
