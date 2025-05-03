defmodule TodoistMcpServer.Mcp.Error do
  @moduledoc """
  This module defines the standard JSON-RPC error codes used in the MCP protocol.
  @see https://modelcontextprotocol.io/docs/concepts/architecture#error-handling
  """

  def parse_error, do: -32_700
  def invalid_request, do: -32_600
  def method_not_found, do: -32_601
  def invalid_params, do: -32_602
  def internal_error, do: -32_603
end
