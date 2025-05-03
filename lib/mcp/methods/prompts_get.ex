defmodule TodoistMcpServer.Mcp.Methods.PromptsGet do
  @moduledoc """
  Module for handling the `prompts/get` method in the Todoist MCP server.
  Schema: https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts#L558
  """

  @type request :: %{
          required(:id) => String.t() | integer(),
          optional(:params) => %{
            optional(:_meta) => %{
              optional(:progressToken) => String.t()
            },
            # The name of the prompt or prompt template.
            required(:name) => String.t(),
            # Arguments to use for templating the prompt.
            optional(:arguments) => %{String.t() => String.t()}
          }
        }

  @type result :: %{
          required(:id) => String.t() | integer(),
          required(:jsonrpc) => String.t(),
          required(:result) => %{
            # An optional description for the prompt.
            optional(:description) => String.t(),
            required(:messages) => list(prompt_message())
          }
        }

  @type prompt_message :: %{
          required(:role) => role(),
          required(:content) =>
            text_content() | image_content() | audio_content() | embedded_resource()
        }

  @type role :: String.t()

  @type text_content :: %{
          required(:type) => String.t(),
          # The text content of the message.
          required(:text) => String.t(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @type image_content :: %{
          required(:type) => String.t(),
          # The base64-encoded image data.
          required(:data) => String.t(),
          # The MIME type of the image. Different providers may support different image types.
          required(:mimeType) => String.t(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @type audio_content :: %{
          required(:type) => String.t(),
          # The base64-encoded audio data.
          required(:data) => String.t(),
          # The MIME type of the audio. Different providers may support different audio types.
          required(:mimeType) => String.t(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @type embedded_resource :: %{
          required(:type) => String.t(),
          required(:resource) => text_resource_contents() | blob_resource_contents(),
          # Optional annotations for the client.
          optional(:annotations) => annotations()
        }

  @type text_resource_contents :: %{
          # The URI of this resource.
          required(:uri) => String.t(),
          # The MIME type of this resource, if known.
          optional(:mimeType) => String.t(),
          # The text of the item. This must only be set if the item can actually be represented as text (not binary data).
          required(:text) => String.t()
        }

  @type blob_resource_contents :: %{
          # The URI of this resource.
          required(:uri) => String.t(),
          # The MIME type of this resource, if known.
          optional(:mimeType) => String.t(),
          # A base64-encoded string representing the binary data of the item.
          required(:blob) => String.t()
        }

  @type annotations :: %{
          # Describes who the intended customer of this object or data is.
          optional(:audience) => list(role()),
          # Describes how important this data is for operating the server.
          optional(:priority) => float()
        }

  @spec handle(request()) :: result()
  def handle(%{id: id, params: %{name: name}} = _request) do
    # Extract arguments if they exist
    # arguments = Map.get(request.params, :arguments, %{})

    # In a real implementation, you would use the name and arguments to fetch the prompt
    # For now, we'll return a simple placeholder result
    result = %{
      description: "Sample prompt description",
      messages: [
        %{
          role: "assistant",
          content: %{
            type: "text",
            text: "This is a sample prompt response for: #{name}"
          }
        }
      ]
    }

    %{
      id: id,
      jsonrpc: "2.0",
      result: result
    }
  end

  def handle(%{id: id}) do
    # Handle case where params or name is missing
    %{
      id: id,
      jsonrpc: "2.0",
      result: %{
        description: nil,
        messages: []
      }
    }
  end
end
