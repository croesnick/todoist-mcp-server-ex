defmodule TodoistMcpServer.Mcp.Methods.ToolsCall do
  @moduledoc """
  Module for handling the `tools/call` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L1022
  """

  @typedoc """
  Used by the client to invoke a tool provided by the server.
  """
  @type request :: %{
          required(:id) => String.t() | integer(),
          # Must be: "tools/call"
          required(:method) => String.t(),
          required(:jsonrpc) => String.t(),
          required(:params) => %{
            # The name of the tool to call
            required(:name) => String.t(),
            # Optional arguments to pass to the tool
            optional(:arguments) => %{String.t() => any()}
          }
        }

  @typedoc """
  The server's response to a tool call.

  Any errors that originate from the tool SHOULD be reported inside the result
  object, with `isError` set to true, _not_ as an MCP protocol-level error
  response. Otherwise, the LLM would not be able to see that an error occurred
  and self-correct.

  However, any errors in _finding_ the tool, an error indicating that the
  server does not support tool calls, or any other exceptional conditions,
  should be reported as an MCP error response.
  """
  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            # The content returned by the tool
            required(:content) => list(content()),
            # Whether the tool call ended in an error.
            # If not set, this is assumed to be false (the call was successful).
            optional(:isError) => boolean()
          }
        }

  @typedoc """
  Content types that can be returned in a tool call result.
  """
  @type content :: text_content() | image_content() | audio_content() | embedded_resource()

  @typedoc """
  Text provided to or from an LLM.
  """
  @type text_content :: %{
          # The text content of the message.
          required(:text) => String.t(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @typedoc """
  An image provided to or from an LLM.
  """
  @type image_content :: %{
          # The base64-encoded image data.
          # @format byte
          required(:data) => String.t(),
          # The MIME type of the image. Different providers may support different image types.
          required(:mimeType) => String.t(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @typedoc """
  Audio provided to or from an LLM.
  """
  @type audio_content :: %{
          # The base64-encoded audio data.
          # @format byte
          required(:data) => String.t(),
          # The MIME type of the audio. Different providers may support different audio types.
          required(:mimeType) => String.t(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @typedoc """
  The contents of a resource, embedded into a prompt or tool call result.

  It is up to the client how best to render embedded resources for the benefit
  of the LLM and/or the user.
  """
  @type embedded_resource :: %{
          # Must be: "resource".
          required(:type) => String.t(),
          required(:resource) => text_resource_contents() | blob_resource_contents(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @typedoc """
  The text contents of a specific resource or sub-resource.
  """
  @type text_resource_contents :: %{
          # The URI of this resource.
          # @format uri
          required(:uri) => String.t(),
          # The MIME type of this resource, if known.
          optional(:mimeType) => String.t(),
          # The text of the item. This must only be set if the item can actually be represented as text (not binary data).
          required(:text) => String.t()
        }

  @typedoc """
  The binary contents of a specific resource or sub-resource.
  """
  @type blob_resource_contents :: %{
          # The URI of this resource.
          # @format uri
          required(:uri) => String.t(),
          # The MIME type of this resource, if known.
          optional(:mimeType) => String.t(),
          # A base64-encoded string representing the binary data of the item.
          # @format byte
          required(:blob) => String.t()
        }

  @typedoc """
  Optional annotations for the client. The client can use annotations to inform how objects are used or displayed.
  """
  @type annotations :: %{
          # Describes who the intended customer of this object or data is.
          # It can include multiple entries to indicate content useful for multiple audiences (e.g., ["user", "assistant"]).
          optional(:audience) => list(role()),
          # Describes how important this data is for operating the server.
          # A value of 1 means "most important," and indicates that the data is
          # effectively required, while 0 means "least important," and indicates that
          # the data is entirely optional.
          # @minimum 0
          # @maximum 1
          optional(:priority) => float()
        }

  @typedoc """
  The sender or recipient of messages and data in a conversation.
  """
  @type role :: :user | :assistant

  @spec json_resource(String.t(), any()) :: embedded_resource()
  def json_resource(uri, data) do
    base64_encoded = data |> Jason.encode!(pretty: false) |> Base.encode64()

    %{
      type: "resource",
      resource: %{
        uri: uri,
        mimeType: "application/json",
        blob: base64_encoded
      }
    }
  end

  @spec json_resource(String.t(), any(), annotations()) :: embedded_resource()
  def json_resource(uri, data, annotations) do
    base64_encoded = data |> Jason.encode!(pretty: false) |> Base.encode64()

    %{
      type: "resource",
      resource: %{
        uri: uri,
        mimeType: "application/json",
        blob: base64_encoded
      },
      annotations: annotations
    }
  end

  @spec response(list(content()), request()) :: result()
  def response(content, %{id: id} = _request) do
    %{
      id: id,
      jsonrpc: "2.0",
      result: %{
        content: content,
        isError: false
      }
    }
  end

  # @spec handle(request()) :: result()
  # def handle(%{id: id, params: %{name: name}} = request) do
  #   content =
  #     case name do
  #       "list_tasks" ->
  #         map_task_to_content = fn task ->
  #           task_base64_encoded = task |> Jason.encode!() |> Base.encode64()

  #           %{
  #             type: "resource",
  #             resource: %{
  #               uri: TodoistMcpServer.Todoist.Api.task_url(task["id"]),
  #               mimeType: "application/json",
  #               blob: task_base64_encoded
  #             },
  #             annotations: %{
  #               audience: [:user],
  #               priority: 1
  #             }
  #           }
  #         end

  #         Map.get(request.params, :arguments, %{})
  #         |> TodoistMcpServer.Todoist.Api.get_tasks()
  #         |> then(fn {:ok, tasks} -> Enum.map(tasks, map_task_to_content) end)

  #       _ ->
  #         # Default implementation - you would replace this with actual tool call handling
  #         # arguments = Map.get(request.params, :arguments, %{})
  #         %{
  #           type: "text",
  #           text: "Tool '#{name}' was called with arguments: #{inspect(request.params)}"
  #         }
  #     end

  #   %{
  #     id: id,
  #     jsonrpc: "2.0",
  #     result: %{
  #       content: content,
  #       isError: false
  #     }
  #   }
  # end
end
