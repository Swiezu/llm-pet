# @swiezu/llm-pet-mcp

An MCP server (stdio) that lets an LLM drive [llm-pet](https://github.com/Swiezu/llm-pet), a pixel Clawd on your macOS desktop. It talks to the app through the JS SDK from [`sdk/js`](../sdk/js), so `llm-pet.app` has to be running.

| tool | what it does |
|---|---|
| `pet_say` | speech bubble (`text` up to 4000 characters, line breaks kept, longer text collapses and expands on click), optional `title` and `subtitle` (one-line header: bold at the top left, smaller at the top right), `style` (`bubble` default, `left`/`right` chat-like messages for a conversation), `channel`, `animation`, `seconds` (1-3600, `0` = until the user closes it), `link` (URL or absolute path, opened on click) |
| `pet_action` | animation only (`name`) |
| `pet_actions` | list of animations |
| `pet_channels` | list of channels (including mute state) |
| `pet_add_channel` | new channel (`name`, optional `color` #RRGGBB) |
| `pet_remove_channel` | delete a channel (not the main one) |
| `pet_status` | is it running, is it visible, what is it doing |

Muting channels is only possible in the app (settings, menu bar, right-click menu on the pet), not through MCP.

## Setup
```bash
git clone https://github.com/Swiezu/llm-pet.git && cd llm-pet && npm install
claude mcp add llm-pet -- node "$PWD/mcp/server.mjs"
```
Any other MCP client: command `node`, argument the absolute path to `mcp/server.mjs`. Tests: `npm test` in the repository root.

License: MIT.
