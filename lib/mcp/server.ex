defmodule TodoistMcpServer.Mcp.Server do
  @moduledoc """
  The MCP server module is responsible for handling incoming requests and notifications from the MCP client.
  It processes requests, executes the appropriate methods, and sends responses back to the client.
  The server also manages the registration of tools and their corresponding handlers.
  """

  use GenServer
  require Logger

  alias TodoistMcpServer.Mcp.Methods.ToolsCall
  alias TodoistMcpServer.Mcp.Error

  alias TodoistMcpServer.Transport.StdioServer

  @methods %{
    "completions/complete" => TodoistMcpServer.Mcp.Methods.CompletionsComplete,
    "initialize" => TodoistMcpServer.Mcp.Methods.Initialize,
    "logging/setLevel" => TodoistMcpServer.Mcp.Methods.LoggingSetLevel,
    "ping" => TodoistMcpServer.Mcp.Methods.Ping,
    "prompts/get" => TodoistMcpServer.Mcp.Methods.PromptsGet,
    "prompts/list" => TodoistMcpServer.Mcp.Methods.PromptsList,
    "resources/list" => TodoistMcpServer.Mcp.Methods.ResourcesList,
    "resources/read" => TodoistMcpServer.Mcp.Methods.ResourcesRead,
    "resources/subscribe" => TodoistMcpServer.Mcp.Methods.ResourcesSubscribe,
    "resources/templates/list" => TodoistMcpServer.Mcp.Methods.ResourcesTemplatesList,
    "resources/unsubscribe" => TodoistMcpServer.Mcp.Methods.ResourcesUnsubscribe,
    "tools/call" => TodoistMcpServer.Mcp.Methods.ToolsCall,
    "tools/list" => TodoistMcpServer.Mcp.Methods.ToolsList
  }

  @type tool :: {String.t(), module()}
  @type tools :: list(tool())
  @type opts :: %{
          tools: tools()
        }

  @type tools_map :: %{
          String.t() => module()
        }
  @type state :: %{
          tools: tools_map()
        }

  @spec start_link(opts()) :: {:ok, pid()} | {:error, any()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  @spec init(opts()) :: {:ok, state()}
  def init(opts) do
    Logger.info("Started Todoist MCP Server", %{opts: opts})
    {:ok, %{tools: Enum.into(opts.tools, %{})}}
  end

  @spec handle_request(ToolsCall.request()) :: :ok
  def handle_request(request) do
    GenServer.cast(__MODULE__, {:handle_request, request})
  end

  def notify(notification) do
    GenServer.cast(__MODULE__, {:notify, notification})
  end

  @impl true
  def handle_cast({:handle_request, request}, state) do
    Logger.info("Processing MCP Client request", %{request: request})

    request
    |> Jason.decode!(keys: :atoms)
    |> process_request(state)
    |> then(fn data ->
      case data do
        {:ok, nil} ->
          nil

        {:ok, response} ->
          response
          |> Jason.encode!(pretty: false)
          |> tap(fn response ->
            Logger.info("Returning MCP Server response", %{response: response})
          end)
          |> StdioServer.send_output()
      end
    end)

    {:noreply, state}
  end

  @impl true
  def handle_cast(request, state) do
    request
    |> invalid_request()
    |> Jason.encode!(pretty: false)
    |> tap(fn response -> Logger.info("Returning MCP Server response", %{response: response}) end)
    |> StdioServer.send_output()

    {:noreply, state}
  end

  @spec process_request(ToolsCall.request(), state()) ::
          {:ok, any()} | {:error, String.t()}
  defp process_request(%{id: id, method: "tools/call"} = request, state) do
    Logger.metadata(request_id: id, request_method: "tools/call")

    tool = request.params.name
    args = request.params.arguments

    result =
      case Map.get(state.tools, tool) do
        nil ->
          tool
          |> tool_not_found_error()

        tool_call_handler ->
          case apply(tool_call_handler, :handle_call, [tool, args]) do
            {:ok, result} ->
              result
              |> ToolsCall.response(request)

            {:error, error} ->
              error
              |> tool_execution_error()
          end
      end

    {:ok, result}
  end

  defp process_request(%{id: id, method: method} = request, _state) do
    Logger.metadata(request_id: id, request_method: method)

    response =
      case Map.get(@methods, method) do
        nil ->
          Logger.warning("No handler found for method")
          method_not_found(method, request)

        module ->
          Logger.metadata(request_handler: module)
          Logger.debug("Found method handler, starting preparing the response")
          apply(module, :handle, [request])
      end

    {:ok, response}
  end

  defp process_request(%{method: method} = request, _state) do
    Logger.metadata(request_method: method)

    response =
      if String.starts_with?(method, "notifications/") do
        Logger.info("Received notification: #{method}")
        nil
      else
        Logger.warning("No handler found for method")
        method_not_found(method, request)
      end

    {:ok, response}
  end

  defp invalid_request(%{id: id} = request) do
    %{
      jsonrpc: "2.0",
      id: id,
      error: %{
        code: Error.invalid_request(),
        message: "Invalid request",
        data: %{
          request: request
        }
      }
    }
  end

  defp method_not_found(method, %{id: id} = _request) do
    %{
      jsonrpc: "2.0",
      id: id,
      error: %{
        code: Error.method_not_found(),
        message: "Method not found: #{method}"
      }
    }
  end

  defp tool_execution_error(error) do
    %{
      jsonrpc: "2.0",
      error: %{
        code: Error.internal_error(),
        message: "Tool execution error",
        data: %{
          error: error
        }
      }
    }
  end

  # https://modelcontextprotocol.io/docs/concepts/architecture#error-handling
  defp tool_not_found_error(tool) do
    %{
      jsonrpc: "2.0",
      error: %{
        code: Error.invalid_request(),
        message: "Tool not found",
        data: %{
          tool: tool
        }
      }
    }
  end
end
