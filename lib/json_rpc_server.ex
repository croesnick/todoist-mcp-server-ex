defmodule TodoistMcpServer.JsonRpcServer do
  @moduledoc """
  JSON-RPC 2.0 server that listens for incoming TCP connections, parses JSON-RPC messages, and forwards them to `TodoistMcpServer.Mcp.Server`.
  """

  use GenServer
  require Logger

  @doc """
  Starts the JSON-RPC server.
  """
  def start_link(opts) do
    {server_opts, _rest} = Keyword.split(opts, [:port])
    port = Keyword.get(server_opts, :port, 4000)
    GenServer.start_link(__MODULE__, %{port: port}, name: __MODULE__)
  end

  @impl true
  def init(%{port: port}) do
    # Listen options - using packet 0 (raw mode) for maximum compatibility
    listen_opts = [
      :binary,
      packet: 0,
      active: false,
      reuseaddr: true,
      # Disable Nagle's algorithm
      nodelay: true
    ]

    case :gen_tcp.listen(port, listen_opts) do
      {:ok, listen_socket} ->
        Logger.info("JSON-RPC server listening on port #{port}")
        # Start accepting connections
        pid = spawn_link(fn -> accept_connections(listen_socket) end)
        Logger.debug("Acceptor process started with PID: #{inspect(pid)}")
        {:ok, %{listen_socket: listen_socket}}

      {:error, reason} ->
        Logger.error("Failed to start JSON-RPC server: #{inspect(reason)}")
        {:stop, reason}
    end
  end

  @impl true
  def terminate(_reason, %{listen_socket: listen_socket}) do
    :gen_tcp.close(listen_socket)
  end

  # Accept client connections
  defp accept_connections(listen_socket) do
    Logger.debug("Waiting for connection...")

    case :gen_tcp.accept(listen_socket) do
      {:ok, client_socket} ->
        Logger.debug("Accepted new client connection")
        # Spawn a new process to handle this client
        pid = spawn_link(fn -> handle_client(client_socket) end)
        Logger.debug("Client handler started with PID: #{inspect(pid)}")
        # Continue accepting new connections
        accept_connections(listen_socket)

      {:error, reason} ->
        Logger.error("Error accepting client connection: #{inspect(reason)}")
        # Try to continue accepting connections despite the error
        accept_connections(listen_socket)
    end
  end

  defp handle_client(socket) do
    # Get peer information for better logging
    peer_info =
      case :inet.peername(socket) do
        {:ok, {addr, port}} -> "#{:inet.ntoa(addr)}:#{port}"
        _ -> "unknown"
      end

    Logger.debug("Handling client from #{peer_info}")

    # Receive data in passive mode first to ensure we get any initial data
    case :gen_tcp.recv(socket, 0, 5000) do
      {:ok, data} ->
        Logger.debug("Initial data received (passive mode): #{inspect(data)}")
        process_data(socket, data)

      {:error, :timeout} ->
        Logger.debug("No initial data received within timeout, switching to active mode")
        switch_to_active_mode(socket)

      {:error, reason} ->
        Logger.error("Error receiving initial data: #{inspect(reason)}")
        :gen_tcp.close(socket)
    end
  end

  defp switch_to_active_mode(socket) do
    # Set socket options for active mode
    case :inet.setopts(socket, active: true, packet: 0) do
      :ok ->
        Logger.debug("Socket set to active mode successfully")
        client_loop(socket, "")

      {:error, reason} ->
        Logger.error("Failed to set socket options: #{inspect(reason)}")
        :gen_tcp.close(socket)
    end
  end

  defp client_loop(socket, buffer) do
    receive do
      {:tcp, ^socket, data} -> handle_tcp_data(socket, buffer, data)
      {:tcp_closed, ^socket} -> handle_tcp_closed(socket)
      {:tcp_error, ^socket, reason} -> handle_tcp_error(socket, reason)
      other -> handle_unknown_message(socket, buffer, other)
    after
      60000 -> handle_timeout(socket)
    end
  end

  defp handle_tcp_data(socket, buffer, data) do
    new_buffer = buffer <> data
    process_data(socket, new_buffer)
    client_loop(socket, "")
  end

  defp handle_tcp_closed(_socket) do
    Logger.info("Client disconnected")
    :ok
  end

  defp handle_tcp_error(socket, reason) do
    Logger.error("TCP error: #{inspect(reason)}")
    :gen_tcp.close(socket)
  end

  defp handle_unknown_message(socket, buffer, other) do
    Logger.warning("Unexpected message in client_loop: #{inspect(other)}")
    client_loop(socket, buffer)
  end

  defp handle_timeout(socket) do
    Logger.info("Connection timed out after inactivity")
    :gen_tcp.close(socket)
  end

  defp process_data(socket, data) do
    case Jason.decode(data) do
      {:ok, json} -> process_jsonrpc(json, socket)
      {:error, _} -> handle_json_decode_error(socket, data)
    end
  end

  defp handle_json_decode_error(socket, data) do
    if String.length(data) > 0 do
      client_loop(socket, data)
    else
      send_parse_error(socket)
      switch_to_active_mode(socket)
    end
  end

  # Process a JSON-RPC message
  defp process_jsonrpc(json, socket) do
    Logger.debug("Processing JSON-RPC message: #{inspect(json)}")

    # Check if it's a valid JSON-RPC message
    if !is_map(json) or !Map.has_key?(json, "jsonrpc") or json["jsonrpc"] != "2.0" or
         !Map.has_key?(json, "method") do
      Logger.error("Invalid JSON-RPC format")
      send_invalid_request_error(socket, json["id"])
    end

    # Check if it's a notification (no id) or a request (has id)
    if Map.has_key?(json, "id") do
      # It's a request - process and send response
      Logger.debug("Processing request with id: #{json["id"]}")
      response = TodoistMcpServer.Mcp.Server.process_jsonrpc(json)
      Logger.debug("Sending response: #{inspect(response)}")
      send_response(socket, response)
    else
      # It's a notification - just process, no response
      Logger.debug("Processing notification (no response needed)")
      TodoistMcpServer.Mcp.Server.notify_jsonrpc(json)
    end
  end

  # Send a JSON-RPC response to the client
  defp send_response(socket, response) do
    response_json = Jason.encode!(response) <> "\n"
    Logger.debug("Sending JSON response: #{inspect(response_json)}")

    case :gen_tcp.send(socket, response_json) do
      :ok ->
        Logger.debug("Response sent successfully")
        :ok

      {:error, reason} ->
        Logger.error("Failed to send response: #{inspect(reason)}")
        :gen_tcp.close(socket)
    end
  end

  # Send a parse error to the client
  defp send_parse_error(socket) do
    error = %{
      "jsonrpc" => "2.0",
      "id" => nil,
      "error" => %{
        "code" => -32700,
        "message" => "Parse error"
      }
    }

    send_response(socket, error)
  end

  # Send an invalid request error to the client
  defp send_invalid_request_error(socket, id) do
    error = %{
      "jsonrpc" => "2.0",
      "id" => id,
      "error" => %{
        "code" => -32600,
        "message" => "Invalid Request"
      }
    }

    send_response(socket, error)
  end
end
