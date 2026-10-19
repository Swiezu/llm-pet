# @swiezu/llm-pet-sdk

JavaScript client for the local API of [llm-pet](https://github.com/Swiezu/llm-pet), a pixel Clawd that lives on your macOS desktop. Show speech bubbles, play animations and manage channels from Node.

```bash
npm install @swiezu/llm-pet-sdk
```

```js
import { say, action, actions, channels, addChannel, removeChannel, status, show, hide } from '@swiezu/llm-pet-sdk'

await say('Build is green', { channel: 'Build', animation: 'shipit' })
await say('Review needed', { seconds: 0, link: 'https://github.com/Swiezu/llm-pet/pulls' })
await action('deploy')
console.log((await actions()).map(a => a.name))
await addChannel('Build', '#3B4A6B')
```

The app has to be running: it writes its port and a one-time token to `~/Library/Application Support/llm-pet/server.json`, which the SDK reads on every call. When the app is not running, calls reject with a `PetError` with `status` 503. Node 22+, no dependencies.

API reference: [sdk/README.md](https://github.com/Swiezu/llm-pet/blob/main/sdk/README.md). License: MIT.
