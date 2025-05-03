defmodule TodoistMcpServer.Mcp.Methods.Request do
  @moduledoc false

  @typedoc """
  Base request type
  """
  @type request :: %{
          required(:jsonrpc) => String.t(),
          required(:id) => String.t() | integer(),
          required(:method) => String.t(),
          optional(:params) => params(),
          optional(String.t()) => any()
        }

  @typedoc """
  Request params with optional metadata
  """
  @type params :: %{
          optional(:_meta) => %{
            optional(:progressToken) => String.t()
          },
          # optional(:cursor) => String.t(),
          optional(String.t()) => any()
        }
end
