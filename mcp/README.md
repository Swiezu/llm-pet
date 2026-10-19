# @swiezu/llm-pet-mcp

An MCP server (stdio) that lets an LLM drive [llm-pet](https://github.com/Swiezu/llm-pet), a pixel Clawd on your macOS desktop. It talks to the app through [`@swiezu/llm-pet-sdk`](https://www.npmjs.com/package/@swiezu/llm-pet-sdk), so `llm-pet.app` has to be running.

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

## Setup
```bash
claude mcp add llm-pet -- npx -y @swiezu/llm-pet-mcp
```
Any other MCP client: command `npx`, arguments `-y @swiezu/llm-pet-mcp`.

## From the repository
```bash
npm install && npm test
claude mcp add llm-pet -- node "$PWD/mcp/server.mjs"
```

License: MIT.
