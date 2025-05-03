defmodule TodoistMcpServer.Mcp.Methods.Initialize do
  @moduledoc """
  Module for handling the `initialize` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L144
  """

  require Logger

  @type request :: %{
          required(:id) => String.t() | integer(),
          optional(:params) => params()
        }

  @type params :: %{
          optional(:_meta) => %{
            optional(:progressToken) => String.t()
          },
          optional(:cursor) => String.t(),
          # The latest version of the Model Context Protocol that the client supports.
          # The client MAY decide to support older versions as well.
          protocolVersion: String.t(),
          capabilities: map(),
          serverInfo: implementation()
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            # The version of the Model Context Protocol that the server wants to use.
            # This may not match the version that the client requested.
            # If the client cannot support this version, it MUST disconnect.
            protocolVersion: String.t(),
            capabilities: server_capabilities(),
            serverInfo: implementation()
          }
        }

  @type server_capabilities :: %{
          # Experimental, non-standard capabilities that the server supports.
          optional(:experimental) => %{optional(String.t()) => any},
          # Present if the server supports sending log messages to the client.
          optional(:logging) => map(),
          # Present if the server supports argument autocompletion suggestions.
          optional(:completions) => map(),
          # Present if the server offers any prompt templates.
          optional(:prompts) => %{
            # Whether this server supports notifications for changes to the prompt list.
            optional(:listChanged) => boolean()
          },
          # Present if the server offers any resources to read.
          optional(:resources) => %{
            # Whether this server supports subscribing to resource updates.
            optional(:subscribe) => boolean(),
            # Whether this server supports notifications for changes to the resource list.
            optional(:listChanged) => boolean()
          },
          # Present if the server offers any tools to call.
          optional(:tools) => %{
            # Whether this server supports notifications for changes to the tool list.
            optional(:listChanged) => boolean()
          }
        }

  @typedoc """
  Describes the name and version of an MCP implementation.
  """
  @type implementation :: %{
          name: String.t(),
          version: String.t()
        }

  @spec handle(request()) :: result()
  def handle(%{id: id, params: %{protocolVersion: protocolVersion}}) do
    result =
      %{
        protocolVersion: protocolVersion,
        capabilities: %{
          resources: %{subscribe: false, listChanged: false},
          tools: %{listChanged: false}
        },
        serverInfo: %{
          name: "Todoist MCP Server",
          version: "0.1.0"
        }
      }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end
end
