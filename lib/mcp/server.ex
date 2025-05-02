defmodule TodoistMcpServer.Mcp.Server do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    Logger.info("Started Todoist MCP Server with options: #{inspect(opts)}")
    {:ok, opts}
  end

  def process_jsonrpc(request) do
    GenServer.call(__MODULE__, {:process_jsonrpc, request})
  end

  def notify_jsonrpc(notification) do
    GenServer.cast(__MODULE__, {:notify_jsonrpc, notification})
  end

  @impl true
  def handle_call({:process_jsonrpc, request}, _from, state) do
    Logger.info("Processing JSON-RPC request: #{inspect(request)}")

    response = handle_jsonrpc_method(request)

    response_json = Jason.encode!(response, pretty: true)
    IO.puts("\n=== BEGIN RESPONSE ===")
    IO.puts(response_json)
    IO.puts("=== END RESPONSE ===\n")

    {:reply, response, state}
  end

  @impl true
  def handle_call(_request, _from, state) do
    {:reply, %{"error" => "Invalid request"}, state}
  end

  defp handle_jsonrpc_method(request) do
    case request do
      %{"method" => method} ->
        dispatch_method(method, request)

      _ ->
        # Handle invalid request without method
        %{
          "jsonrpc" => "2.0",
          "error" => %{
            "code" => -32600,
            "message" => "Invalid Request: method field is required"
          },
          "id" => request["id"]
        }
    end
  end

  defp dispatch_method(method, request) do
    case method do
      "tools/list" ->
        result = TodoistMcpServer.Mcp.Methods.ToolsList.handle()
        jsonrpc_success_response(request["id"], result)

      _ ->
        # Method not found
        %{
          "jsonrpc" => "2.0",
          "error" => %{
            "code" => -32601,
            "message" => "Method not found: #{method}"
          },
          "id" => request["id"]
        }
    end
  end

  defp jsonrpc_success_response(id, result) do
    %{
      "jsonrpc" => "2.0",
      "result" => result,
      "id" => id
    }
  end
end
