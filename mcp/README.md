# llm-pet MCP server

An MCP server (stdio) for LLMs. It talks to the app through [`../sdk/js`](../sdk/README.md), so `llm-pet.app` has to be running.

| tool | what it does |
|---|---|
| `pet_say` | speech bubble (`text` up to 600 characters), optional `channel`, `animation`, `seconds` |
| `pet_action` | animation only (`name`) |
| `pet_actions` | list of animations |
| `pet_channels` | list of channels (including mute state) |
| `pet_add_channel` | new channel (`name`, optional `color` #RRGGBB) |
| `pet_remove_channel` | delete a channel (not the main one) |
| `pet_status` | is it running, is it visible, what is it doing |

Muting channels is only possible in the app settings, not through MCP.

```bash
cd mcp && npm install && npm test
claude mcp add llm-pet -- node "$PWD/server.mjs"
```
