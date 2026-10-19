# llm-pet API and SDKs

On launch the app starts an HTTP server bound to `127.0.0.1` only (random port) and writes `~/Library/Application Support/llm-pet/server.json` (`port`, `token`, `pid`; mode 0600; a new token on every launch; removed on quit). Every request needs an `Authorization: Bearer <token>` header. Responses are JSON; errors look like `{"error": "..."}`.

| method and path | body | what it does |
|---|---|---|
| `GET /status` | | `{enabled, action, speaking, bubbles, queued, fps}` (`bubbles` on screen, `queued` waiting) |
| `POST /say` | `{"text": "...", "channel": "Build", "animation": "party", "seconds": 5, "link": "https://..."}` (everything except `text` is optional) | speech bubble on a channel (main by default), optionally with an animation; `seconds` 1-3600 (default: based on length), `0` = stays until the user closes it with X; `link` = clickable link at the bottom right (URL with a scheme: `https://`, `file://`, `myapp://`, or an absolute path, `~` allowed; checked only syntactically, the app never touches the file until the user clicks); returns `{ok, shown, queued, channel}` (`queued`: 0 = on screen now, otherwise its place in the queue; the animation plays when the bubble appears), `shown: false, muted: true` for a muted channel; 404 unknown channel, 400 unknown animation or a link without a scheme, 409 pet hidden, 429 queue full (20) |
| `POST /action` | `{"name": "typing"}` | animation only; 409 when hidden |
| `GET /actions` | | `{actions: [{name, title, seconds}]}` (`seconds: null` = endless) |
| `GET /channels` | | `{channels: [{id, name, color, muted, main}]}` |
| `POST /channels` | `{"name": "Build", "color": "#3B4A6B"}` (`color` optional) | new channel, 201 `{channel}`; 409 when the name is taken |
| `DELETE /channels/<id or name>` | | deletes a channel; 400 for the main one |
| `POST /show`, `POST /hide` | | show (with the teleport) or hide the pet |

At most 2 bubbles are on screen, stacked above the pet (the oldest nearest to it); new ones wait in a queue and the outer bubble shows a "+n" badge with the number waiting. A bubble with a duration shows a ring in its top right corner that empties until the bubble disappears; a bubble with `seconds: 0` shows an X instead. Clicking the link opens it (`NSWorkspace`: browser, Finder, the app that owns the scheme) and closes the bubble.

A channel is addressed by name (case insensitive) or `id`. There is no mute in the API: only the user can mute channels, in the app settings.

## Clients
| directory | usage |
|---|---|
| `js/` | [`@swiezu/llm-pet-sdk`](https://www.npmjs.com/package/@swiezu/llm-pet-sdk): `npm install @swiezu/llm-pet-sdk`, then `import { say, action, actions, channels, addChannel, removeChannel, status, show, hide } from '@swiezu/llm-pet-sdk'`; `say('Build is green', { channel: 'Build', animation: 'party', seconds: 0, link: 'https://...' })` (Node 22+, no dependencies); tests: `npm test` in the repository root |
| `swift/` | Swift package `LlmPetKit`: `try await LlmPet().say("Build is green", channel: "Build", animation: "party", seconds: 0, link: "https://...")`, `.action("typing")`, `.actions()`, `.channels()`, `.addChannel("Build", color: "#3B4A6B")`, `.removeChannel("Build")`, `.status()`; local dependency `.package(path: "<path>/sdk/swift")` |
| `shell/llm-pet` | `llm-pet say "text" -c Build -a party -s 5 -l https://...` (`-s 0` = until closed), `llm-pet action typing`, `llm-pet actions`, `llm-pet channels`, `llm-pet channel-add Build "#3B4A6B"`, `llm-pet channel-remove Build`, `llm-pet status`, `llm-pet show`, `llm-pet hide` (curl and jq shipped with macOS) |

Errors: when the app is not running you get status 503 in JS, `LlmPetError.notRunning` in Swift and exit code 1 in the shell.
