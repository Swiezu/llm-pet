# llm-pet API and SDKs

On launch the app starts an HTTP server bound to `127.0.0.1` only (random port) and writes `~/Library/Application Support/llm-pet/server.json` (`port`, `token`, `pid`; mode 0600; a new token on every launch; removed on quit). Every request needs an `Authorization: Bearer <token>` header. Responses are JSON; errors look like `{"error": "..."}`.

| method and path | body | what it does |
|---|---|---|
| `GET /status` | | `{enabled, action, speaking, fps}` |
| `POST /say` | `{"text": "...", "channel": "Build", "animation": "party", "seconds": 5}` (everything except `text` is optional) | speech bubble on a channel (main by default), optionally with an animation; returns `{ok, shown, channel}`, `shown: false, muted: true` for a muted channel; 404 unknown channel, 400 unknown animation, 409 pet hidden |
| `POST /action` | `{"name": "typing"}` | animation only; 409 when hidden |
| `GET /actions` | | `{actions: [{name, title, seconds}]}` (`seconds: null` = endless) |
| `GET /channels` | | `{channels: [{id, name, color, muted, main}]}` |
| `POST /channels` | `{"name": "Build", "color": "#3B4A6B"}` (`color` optional) | new channel, 201 `{channel}`; 409 when the name is taken |
| `DELETE /channels/<id or name>` | | deletes a channel; 400 for the main one |
| `POST /show`, `POST /hide` | | show (with the teleport) or hide the pet |

A channel is addressed by name (case insensitive) or `id`. There is no mute in the API: only the user can mute channels, in the app settings.

## Clients
| directory | usage |
|---|---|
| `js/` | `import { say, action, actions, channels, addChannel, removeChannel, status, show, hide } from 'llm-pet-sdk'`; `say('Build is green', { channel: 'Build', animation: 'party' })` (Node 22+, no dependencies, `"llm-pet-sdk": "file:<path>/sdk/js"`); tests: `npm test` |
| `swift/` | Swift package `LlmPetKit`: `try await LlmPet().say("Build is green", channel: "Build", animation: "party")`, `.action("typing")`, `.actions()`, `.channels()`, `.addChannel("Build", color: "#3B4A6B")`, `.removeChannel("Build")`, `.status()`; local dependency `.package(path: "<path>/sdk/swift")` |
| `shell/llm-pet` | `llm-pet say "text" -c Build -a party -s 5`, `llm-pet action typing`, `llm-pet actions`, `llm-pet channels`, `llm-pet channel-add Build "#3B4A6B"`, `llm-pet channel-remove Build`, `llm-pet status`, `llm-pet show`, `llm-pet hide` (curl and jq shipped with macOS) |

Errors: when the app is not running you get status 503 in JS, `LlmPetError.notRunning` in Swift and exit code 1 in the shell.
