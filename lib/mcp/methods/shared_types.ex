defmodule TodoistMcpServer.Mcp.Methods.SharedTypes do
  @moduledoc """
  Module for handling shared types in the Todoist MCP server.
  """

  @typedoc """
  The sender or recipient of messages and data in a conversation.
  Can be "role" or "assistant".
  """
  @type role :: String.t()

  @type annotations :: %{
          # Describes who the intended customer of this object or data is.
          # It can include multiple entries to indicate content useful for multiple audiences (e.g., `["user", "assistant"]`).
          optional(:audience) => list(role()),

          # Describes how important this data is for operating the server.
          #
          # A value of 1 means "most important," and indicates that the data is
          # effectively required, while 0 means "least important," and indicates that
          # the data is entirely optional.
          optional(:priority) => float()
        }
end
