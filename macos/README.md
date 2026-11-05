# llm-pet for macOS

A pixel Clawd (8×6 body, 1×1 eyes, 2×2 arms, 4 legs) in its own transparent window that stays on top (`.statusBar` level, on every Space). A standalone menu bar app that takes messages through a local API (see [API](#api)).

## Menu bar (paw icon) and right-click menu
Right-clicking the pet opens the same menu (`PetMenu`).
| item | what it does |
|---|---|
| Show / Hide pet | showing plays a random entrance from `Action.entrances` and a greeting, hiding a random exit from `Action.exits` (the window stays until it ends); state in `UserDefaults` (`petEnabled`) |
| Settings… (⌘,) | settings window |
| Animations | switch; off = no animations at all (API, menu and click are ignored, no teleport, no blinking), the pet stands still (`animationsEnabled`) |
| Fast mode | switch; animations run at the fast speed from the settings (`fastMode`) |
| Channels | a switch per channel, checked = shown, unchecked = muted (same as in the settings) |
| DEBUG ANIMATION | plays the chosen animation, grouped by `Action.Category` (basics, entrances, exits, work, delivery, power, breaks, channels) |
| DEBUG TEXT | five test texts (`DebugTexts.Sample`: short, sentence, five lines, a word without spaces, long to expand), a conversation (left and right) and 12 bubbles at once (queue); every one of them uses the options below (`DebugBubble`, kept until quit): title and subtitle, a random trick, time (by length, 10 s, until closed), link (none, website, folder), style (bubble, chat left, chat right) and channel (checks color and muting) |
| Quit (⌘Q) | plays a random exit first (`applicationShouldTerminate` answers `.terminateLater`, with a 10 s fallback); a hidden pet quits at once |

## Settings
- **Language**: English or Polish; asked once on first launch, changeable later. Applies to the menu, settings, animation titles, test texts and the greeting. The API, MCP and SDKs are always in English.
- **Channels**: the main channel (cannot be deleted) and any number of others: name, bubble color (text color adapts to the background), title color and accent color (subtitle, "more"/"less"; both default to a tint that suits the background), mute, delete. Muting is only possible here; messages sent to a muted channel are not shown. Stored in `UserDefaults` (`channels`). Muting or unmuting a channel (here, in the menu bar or the right-click menu) plays the `mute` or `unmute` animation.
- **Size**: pet size 50-200% (`petScale`; while the slider moves the pet springs to the new size, straining with raised paws and an aura when it grows, squeezing and sweating when it shrinks) bubble text 10-22 pt (`bubbleFont`), bubble width 160-800 pt (`bubbleWidth`, default 300) and height 2-30 lines (`bubbleLines`, default 8) of a collapsed bubble (section "Max bubble size"), width 300-2000 pt (`expandedWidth`, default 800) and height 5-120 lines (`expandedLines`, default 40) of an expanded bubble (section "Expanded bubble"); visible bubbles adapt live, with no bubble on screen a sample one appears.
- **Animation**: speed 0.25-3× (`animationSpeed`, default 1) and speed in fast mode 1-5× (`fastSpeed`, default 2), both scale the animation clock and walking (bubbles keep their own timing; changing speed mid-animation re-anchors the clock, so nothing jumps), in 0.25× steps; fast mode and animations switches (also in the menus); frames per second on power (`fpsPower`) and on battery (`fpsBattery`), picked by the current power source (IOKit power source notifications, shown under the section): 15, 30, 60, 120, 144, 165 and 240, only those the display supports (`NSScreen.maximumFramesPerSecond`), plus VSync as the last option (stored as 0), which follows the display refresh rate; older values (12, 24) move to the nearest option. The pet is drawn with a display synced `TimelineView(.animation)`, capped at the FPS. Movement is time based, so the pet moves at the same speed at any frame rate.

## Behaviour
On its own the pet just stands and blinks: no random actions, no random texts. Animations are triggered from the DEBUG menu, the API or a click (a random trick from `Action.tricks`). Drag it to move it (it dangles and flails), with its head up to the top edge of the screen (`Pet.top`; the taller window, room for the props, may go past the edge, and the screen is picked by the body, not the window center); on release it settles gently a few points down (`Pet.drop`) and stays where you left it. It walks and stands on the Dock strip too (`Pet.area`: the full screen height below the menu bar). The position (`petX`, `petY`) is saved after landing, after a walk, on hide and on quit, and restored on show and launch.

Speech bubble (separate window, keeps to screen edges, flips below the head when it does not fit above and there is more room below, follows hops): `Pet.shared.say("text", title: "header", subtitle: "note", style: .left, on: channel)` (title and subtitle optional: a one-line header, the title bold on the left, the subtitle on the right next to the X, in the channel's title and accent colors; `style` `.bubble` by default, `.left` / `.right` = a chat-like message shifted to that side with the tail in the outer corner, stacked with a small gap instead of overlapping). Text heights are measured with SwiftUI itself (`Bubble.height`), as `NSString` measuring gives lines 1 pt shorter at some font sizes. Text types and erases itself, reading time depends on length unless `for:` sets it (`.infinity` = until closed), line breaks are kept, size limited by `bubbleWidth` and `bubbleLines` from the settings, colors come from the channel. Text that does not fit ends with "…" and gets "more" at the bottom left: it expands the bubble to the full text (at most `expandedWidth` and `expandedLines` and the room on screen; a longer text scrolls in a viewport of whole lines, with an always visible scrollbar under the X that can be dragged), the bubble animates its size over 0.35 s (`Bubble.foldTime`, crossfading the short and full text, the ring around the X fading out), the countdown pauses; "less" collapses it and the countdown resumes. The API turns `\r\n` and a literal `\\n` into line breaks. Top right: an X that closes the bubble, inside a ring that empties over the reading time (no ring for a bubble without a time limit or an expanded one). `link:` adds a link at the bottom right (host, file name or scheme) that opens with `NSWorkspace` and closes the bubble. The bubble window takes clicks only while the cursor is over the bubble itself (`ignoresMouseEvents` follows the mouse every frame), so its transparent margin never blocks other bubbles or apps. A bubble that can expand gets a window sized for its expanded state (`BubbleCanvas` places the bubble inside it), so the fold animation never resizes or moves the window. `BubbleStack` shows `bubbleCount` bubbles from the settings (0 = auto, as many as fit up to the edge of the screen), never more than fit in the room above the head, recounted every frame, so lifting the pet hides the bubbles that no longer fit back into the queue and lowering it shows them again (the stack goes below the pet only when not even one bubble fits above and there is more room below); the nearest one has the tail, and `newestFirst` decides whether the newest or the oldest is nearest (a new message in the newest first order scrolls back to it). The rest waits (up to 20 hidden, then the API answers 429), with a "+n" badge on the outer bubble. Scrolling over a bubble (a local `scrollWheel` monitor, no scrollbar) moves the window over the queue one bubble per 40 pt; an expanded bubble that scrolls its own text keeps the scroll. A bubble outside the window is parked (`Bubble.park`: window hidden, countdown frozen) and resumes where it stopped; a new bubble starts typing only when it first enters the window, and an animation sent with it plays then.

| animation | what happens |
|---|---|
| `idle` | standing, blinking |
| `walk` | walks to a random spot on screen |
| `hop` | a series of hops with a mid-air tilt |
| `flag` | checkered flag, 3/4 view, "^ ^" eyes, marching in place |
| `party` | squats with a raised paw, confetti |
| `workout` | puts the headband on (the band glides smoothly from the paw over the head), flexing, dumbbells, presses with an in-between frame, takes the headband off and tucks it away |
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
| `smoke` | smoke break: takes a cigarette out, puts it in its mouth, lights it with a lighter (flame, glowing tip, wisps), a long drag, exhales smoke, holds it in its paw and blows a smoke ring, a second drag, drops the butt and stomps it out twice, sighs |
| `chill` | takes out a brown wrap, sprinkles it, rolls a thick one with quick paw moves, puts it in its mouth and lights it, a long drag, exhales big clouds; then heavy lidded red eyes (`Eyes.stoned`), a slow lazy sway to floating notes and fits of giggles, a last drag on the short end, one more cloud |
| `lunch` | lunch break: the tummy growls (shaking, "!", squiggles), takes out a burger (sesame bun, lettuce, cheese, patty), four bites that shrink it with chewing and flying crumbs, pats its full belly, drinks a soda, burps a cloud, a happy heart |
| `mute` | a speaker pops up above its head, gets crossed out in red, Claude covers its mouth and zips it shut, nods; plays when a channel is muted |
| `unmute` | the crossed out speaker, Claude unzips its mouth, the cross disappears, sound waves and singing notes, a little dance; plays when a channel is unmuted |
| `shipit` | Ship it!: packs code into a box, tapes it, stamps a green ✓, a little ship sails in, the box lands on deck and sails away, Claude salutes |
| `beamdown` | entrance: a thin beam drops from the sky and widens into a pillar of light (`Beaming`), Claude materializes top down pixel by pixel (`Pose.dissolve`), glowing (`Pose.glow`), lands, looks around, waves |
| `poofin` | entrance: a spark, a puff of smoke (`Pose.cloud`) with sparkles, Claude appears inside it, a squash, a ta-da hop |
| `flyin` | entrance: a little coral Clawd bird flies in, lands, hops, poofs into Claude, who shakes off a feather |
| `portalout` | exit: a portal opens on the ground on the left, Claude turns, crouches and leaps in (the part already inside is hidden), the portal collapses into a spark |
| `beamup` | exit: the pillar of light comes down, Claude raises its paws, glows white, stretches and dissolves into pixels up the beam, the beam narrows and leaves, a sparkle in the sky |
| `poof` | exit: a wave, a crouch, a little jump and gone in a puff of smoke with sparkles |
| `flyaway` | exit: "!", a jump, a puff of smoke, Claude turns into a little bird that flies off to the top right, a feather floats down |

All animations use the same sprite on the same pixel grid (`Style.unit`); props (envelope, sheet, plane, bulb, portal, rocket, mug…) are pixel art in half sprite pixels (`Render/PixelArt.swift`, `Render/Props.swift`). The pet window is 360×320 pt to fit the portal, beams and flights.

## API
On launch an HTTP server starts on `127.0.0.1` with a token in `~/Library/Application Support/llm-pet/server.json`: messages (with channel and animation), animations, channels (list, add, delete), show and hide. Reference and clients in [`../sdk/README.md`](../sdk/README.md), MCP in [`../mcp/README.md`](../mcp/README.md).

## Build and run
```bash
macos/build.sh          # release, ad hoc signed -> build/llm-pet.app
macos/build.sh --open   # same, then relaunch the app
```
Bundle id: `pl.frostbyte.llm-pet`. Requires macOS 26+ and Swift 6.2+ (Command Line Tools or Xcode). `.build/` and `.app` are not tracked.

Frames without a screen: `swift build && .build/debug/llm-pet --dump-frames <dir>` writes `<name>.png` with 18 timed frames for every animation (`Pet/FrameDump.swift`); `--render-docs <dir>` writes the logo and the GIFs used in the main README (also `resize.gif`) (`Pet/DocsRender.swift`).

## Code (`macos/Sources/LlmPet/`)
| directory / file | what |
|---|---|
| `LlmPetApp.swift` | app entry, menu bar menu with the DEBUG items, first launch language choice |
| `Pet/Pet.swift` | pet state, window, movement loop (walk, drop, drag), entrance on show and exit on hide or quit, spring scaling to the size from the settings |
| `Pet/Action.swift` | animations: API name, localized title, category for the DEBUG menu, duration, click tricks |
| `Pet/DebugTexts.swift` | test texts, the greeting (English and Polish) and the DEBUG TEXT options (`DebugBubble`) |
| `Pet/FrameDump.swift` | `--dump-frames`: animation frame sheets as PNG |
| `Pet/DocsRender.swift` | `--render-docs`: logo and animation GIFs for `docs/` |
| `Settings/` | `AppSettings` (language, FPS, channels, pet size, bubble text size), `Language` (translations and first launch picker), `Channel` (color, mute), `SettingsView`, `SettingsWindow` |
| `Server/` | `PetServer` (HTTP on loopback, Network.framework, token), `ServerInfo` (`server.json`) |
| `Bubble/` | speech bubbles: `Bubble` (one bubble: text, colors, typing and erasing phases, countdown, link, window), `BubbleStack` (how many on screen, order, queue, scrolling, layout), `BubbleView` |
| `Render/Pose.swift` | one frame: eyes, arms, props, offsets, scale, legs, scene items |
| `Render/SpriteView.swift` | draws Clawd from a `Pose` (Canvas) |
| `Render/PetView.swift` | `PetView` (frame clock from settings, gestures) and `PetFrame` (one frame: shadow, effects, sprite, portal mask, flying props) |
| `Render/Effects.swift` | effects around the pet: confetti, sleep "z", portal, pillar of light, smoke puff, dissolve mask, flying envelope and plane, beam, flame aura, shockwave, scene items |
| `Render/PixelArt.swift`, `Render/Props.swift` | pixel art props and their palette |
| `Render/Style.swift` | pixel size, canvas, colors |
| `Animations/Choreography.swift` | picks the pose for the pet state and action |
| `Animations/Stage.swift` | scene props (`Pose.items`): placement relative to the pet, context bar, easing |
| `Animations/<Action>.swift` | one animation = one file with a `mutating func` on `Pose` |
| `Animations/Resize.swift` | pose while the pet changes size (not an API action): straining when it grows, squeezing when it shrinks |

## New animation
1. A `case` in `Pet/Action.swift` with `title` (English and Polish), `category` and `duration` (optionally in `tricks`); it shows up in its category in the DEBUG ANIMATION menu and the API automatically.
2. `Animations/<Name>.swift`: `extension Pose { mutating func <name>(t: TimeInterval, clock: TimeInterval) }`.
3. A branch in `Animations/Choreography.swift`; new props: a field in `Pose` drawn in `SpriteView` or scene items via `place(...)` (art in `Render/Props.swift`), effects in `Effects.swift`.
4. Check the frames with `--dump-frames` and refresh the README GIFs with `--render-docs docs`.
