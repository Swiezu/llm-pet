# llm-pet for macOS

A pixel Clawd (8×6 body, 1×1 eyes, 2×2 arms, 4 legs) in its own transparent window that stays on top (`.statusBar` level, on every Space). A standalone menu bar app that takes messages through a local API (see [API](#api)).

## Menu bar (paw icon)
| item | what it does |
|---|---|
| Show / Hide pet | showing starts with the teleport and a greeting; state in `UserDefaults` (`petEnabled`) |
| Settings… (⌘,) | settings window |
| DEBUG ANIMATION | plays the chosen animation |
| DEBUG TEXT | shows a text from the test pool (`Pet/DebugTexts.swift`) on the main channel |
| DEBUG CHANNEL | a random test text on the chosen channel (checks color and muting) |
| Quit (⌘Q) | |

## Settings
- **Language**: English or Polish; asked once on first launch, changeable later. Applies to the menu, settings, animation titles, test texts and the greeting. The API, MCP and SDKs are always in English.
- **Channels**: the main channel (cannot be deleted) and any number of others: name, bubble color (text color adapts to the background), mute, delete. Muting is only possible here; messages sent to a muted channel are not shown. Stored in `UserDefaults` (`channels`).
- **Animation**: frames per second (12, 24, 30, 60, 120; default 30). Movement is time based, so the pet moves at the same speed at any frame rate.

## Behaviour
On its own the pet just stands and blinks: no random actions, no random texts. Animations are triggered from the DEBUG menu, the API or a click (a random trick from `Action.tricks`). Drag it to move it (it dangles and flails); on release it settles gently a few points down (`Pet.drop`) and stays where you left it.

Speech bubble (separate window, keeps to screen edges, flips below the head when there is no room above, follows hops): `Pet.shared.say("text", on: channel)`. Text types and erases itself, reading time depends on length, max 8 lines and 300 pt, longer text ends with "…", colors come from the channel.

| animation | what happens |
|---|---|
| `idle` | standing, blinking |
| `walk` | walks to a random spot on screen |
| `hop` | a series of hops with a mid-air tilt |
| `flag` | checkered flag, 3/4 view, "^ ^" eyes, marching in place |
| `party` | squats with a raised paw, confetti |
| `workout` | headband, flexing, dumbbells, presses |
| `sleep` | breathing and floating "z" |
| `teleport` | a Claude-world portal (a spark that unfolds into a coral ring with an ivory core) pushes Claude out (the part still inside is hidden), a fast fall, a hard landing with dust, a bounce, dizzy stars, a shake-off; the portal collapses into a spark; then the greeting |
| `typing` | sits down, whips out a keyboard and slams it down, types extremely fast (keys flash, sparks fly), puts it away |
| `dillydally` | wanders off, kicks a pebble, sways and hums (notes), scuffs a foot, wanders back with its head in the clouds, sighs |
| `lockin` | paw on chin and thought dots, then lock in: headband, narrowed eyes with brows, trembling, aura, focus lines, steam; finally a light bulb and a raised paw |
| `letter` | a fluttering letter flies in, "!" and eye tracking, a hop and a catch, opening the envelope, reading (eyes scan the lines), a heart |
| `plane` | takes out a sheet, folds a paper plane in three moves, winds up, throws; the plane glides with a wave and a trail |
| `kamehameha` | wide stance, hands at the hip, a growing blue energy ball (particles pulled in, rising pebbles, trembling), thrust, flash and a thick pulsing beam with recoil, the beam fades, panting |
| `powerup` | Dragon Ball style transformation: powering up, a growing golden flame aura, sparks, pebbles, trembling; a flash and a shockwave, golden spiky hair and teal eyes; levitating in full aura; back to normal, panting |
| `coffee` | kettle and mug, a coffee stream, steam, blowing, two sips, a heart |
| `buffering` | freezes mid-step, a spinner turns above its head, lag spikes; the spinner completes and Claude catches up with a quick trot |
| `deploy` | deploy to prod: a rocket, a remote, a 3, 2, 1 countdown, ignition with smoke, liftoff with a trail, a sparkle in the sky, a green ✓ and a celebration |
| `contextfull` | tokens rain down and pile up, the context bar above its head goes from green to red and blinks, Claude swells, sweats, gets hit by tokens, gets dizzy |
| `compact` | three stomps that compress the token pile, the bar drops from 100% to 20%, the pile becomes a packed cube, Claude pockets it and sighs with relief |
| `helloai` | hello fellow AI: puts on an antenna, LED eyes, a stiff robotic step-by-step wave, signal waves and floating 0s and 1s, then takes the disguise off |
| `shipit` | Ship it!: packs code into a box, tapes it, stamps a green ✓, a little ship sails in, the box lands on deck and sails away, Claude salutes |

All animations use the same sprite on the same pixel grid (`Style.unit`); props (envelope, sheet, plane, bulb, portal, rocket, mug…) are pixel art in half sprite pixels (`Render/PixelArt.swift`, `Render/Props.swift`). The pet window is 360×320 pt to fit the portal, beams and flights.

## API
On launch an HTTP server starts on `127.0.0.1` with a token in `~/Library/Application Support/llm-pet/server.json`: messages (with channel and animation), animations, channels (list, add, delete), show and hide. Reference and clients in [`../sdk/README.md`](../sdk/README.md), MCP in [`../mcp/README.md`](../mcp/README.md).

## Build and run
```bash
macos/build.sh          # release, ad hoc signed -> build/llm-pet.app
macos/build.sh --open   # same, then relaunch the app
```
Bundle id: `pl.frostbyte.llm-pet`. Requires macOS 26+ and Swift 6.2+ (Command Line Tools or Xcode). `.build/` and `.app` are not tracked.

Frames without a screen: `swift build && .build/debug/llm-pet --dump-frames <dir>` writes `<name>.png` with 18 timed frames for every animation (`Pet/FrameDump.swift`); `--render-docs <dir>` writes the logo and the GIFs used in the main README (`Pet/DocsRender.swift`).

## Code (`macos/Sources/LlmPet/`)
| directory / file | what |
|---|---|
| `LlmPetApp.swift` | app entry, menu bar menu with the DEBUG items, first launch language choice |
| `Pet/Pet.swift` | pet state, window, movement loop (walk, drop, drag), teleport on show |
| `Pet/Action.swift` | animations: API name, localized title, duration, click tricks |
| `Pet/DebugTexts.swift` | test texts and the greeting (English and Polish) |
| `Pet/FrameDump.swift` | `--dump-frames`: animation frame sheets as PNG |
| `Pet/DocsRender.swift` | `--render-docs`: logo and animation GIFs for `docs/` |
| `Settings/` | `AppSettings` (language, FPS, channels), `Language` (translations and first launch picker), `Channel` (color, mute), `SettingsView`, `SettingsWindow` |
| `Server/` | `PetServer` (HTTP on loopback, Network.framework, token), `ServerInfo` (`server.json`) |
| `Bubble/` | speech bubble: `Bubble` (text, colors, typing and erasing phases, window, position), `BubbleView` |
| `Render/Pose.swift` | one frame: eyes, arms, props, offsets, scale, legs, scene items |
| `Render/SpriteView.swift` | draws Clawd from a `Pose` (Canvas) |
| `Render/PetView.swift` | `PetView` (frame clock from settings, gestures) and `PetFrame` (one frame: shadow, effects, sprite, portal mask, flying props) |
| `Render/Effects.swift` | effects around the pet: confetti, sleep "z", portal, flying envelope and plane, beam, flame aura, shockwave, scene items |
| `Render/PixelArt.swift`, `Render/Props.swift` | pixel art props and their palette |
| `Render/Style.swift` | pixel size, canvas, colors |
| `Animations/Choreography.swift` | picks the pose for the pet state and action |
| `Animations/Stage.swift` | scene props (`Pose.items`): placement relative to the pet, context bar, easing |
| `Animations/<Action>.swift` | one animation = one file with a `mutating func` on `Pose` |

## New animation
1. A `case` in `Pet/Action.swift` with `title` (English and Polish) and `duration` (optionally in `tricks`); it shows up in the DEBUG ANIMATION menu and the API automatically.
2. `Animations/<Name>.swift`: `extension Pose { mutating func <name>(t: TimeInterval, clock: TimeInterval) }`.
3. A branch in `Animations/Choreography.swift`; new props: a field in `Pose` drawn in `SpriteView` or scene items via `place(...)` (art in `Render/Props.swift`), effects in `Effects.swift`.
4. Check the frames with `--dump-frames` and refresh the README GIFs with `--render-docs docs`.
