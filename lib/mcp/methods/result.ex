defmodule TodoistMcpServer.Mcp.Methods.Result do
  @moduledoc false

  @typedoc """
  Base result type with optional metadata and arbitrary key-value pairs
  """
  @type result :: %{
          required(:jsonrpc) => String.t(),
          required(:id) => String.t() | integer(),
          required(:result) => %{
            optional(:_meta) => %{optional(String.t()) => any()},
            optional(:nextCursor) => String.t(),
            optional(String.t()) => any()
          }
        }
end
