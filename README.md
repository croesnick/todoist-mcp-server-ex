# Todoist MCP Server written in Elixir

Todoist is a task-management and to-do list application.
MCP stands for "Model Context Protocol" and, broadly speaking, is API definition for LLMs to interact with other applications --- like Todoist.

## Motivation

So... why do I want an MCP Server for Todoist? And why writing it in Elixir?
Second question first: Because I like Elixir, and I want to extend the AI ecosystem for it. 🙂
And regarding the first question: I want to interact with my todos from various applications, like from within Obsidian via the BMO Chatbot. Or maybe someday build a AI-based personal assistant for myself. Both of which need access to my todos and projects.

## How to run

```shell
mix run --no-halt`
```

If you want to test is locally without having an MCP Client (like Cursor, Cline, ...) at hand, just go bare-minimum and run:

```shell
echo '{"jsonrpc": "2.0", "id": 1, "method": "tools/list"}' | nc localhost 4000
```

## Documentation

- Basic MCP message-format introduction on [modelcontextprotocol.io](https://modelcontextprotocol.io/docs/concepts/transports#message-format)
- [MCP specification overview](https://modelcontextprotocol.io/specification/2025-03-26)
- [MCP schema definition](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/schema/2025-03-26/schema.ts) (in Typescript)
