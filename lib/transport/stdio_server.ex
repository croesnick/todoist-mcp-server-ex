defmodule TodoistMcpServer.Transport.StdioServer do
  @moduledoc false

  use GenServer
  require Logger

  @type state :: %{
          observers: [module()]
        }

  def start_link(opts \\ %{}) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def send_output(data) do
    GenServer.cast(__MODULE__, {:stdout_data, data})
  end

  @impl true
  def init(opts \\ %{}) do
    myself = self()
    spawn_link(fn -> read_stdin_loop(myself) end)

    {:ok, %{observers: opts.observer || []}}
  end

  @impl true
  def handle_cast({:stdout_data, data}, state) do
    Logger.debug("Writing data to stdout", %{data: data})
    IO.puts(data)

    {:noreply, state}
  end

  @impl true
  @spec handle_info({:stdin_data, String.t()}, state()) :: {:noreply, state()}
  def handle_info({:stdin_data, data}, state) do
    Logger.debug("Received data on stdin", %{data: data})

    Enum.each(state.observers, fn observer ->
      :ok = apply(observer, :handle_request, [data])
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info({:stdin_closed}, state) do
    Logger.debug("stdin was closed, stopping")
    {:stop, :normal, state}
  end

  defp read_stdin_loop(server) do
    case IO.read(:stdio, :line) do
      :eof ->
        send(server, {:stdin_closed})

      {:error, _reason} ->
        send(server, {:stdin_closed})

      data ->
        trimmed_data = String.trim(data)
        send(server, {:stdin_data, trimmed_data})

        read_stdin_loop(server)
    end
  end
end
