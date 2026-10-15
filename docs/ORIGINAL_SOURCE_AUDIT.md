# Source audit: Vortex X Sage [MM2]

This note records what was found in the supplied source and why the Studio project is being adapted rather than pasted in unchanged.

## Source facts
- The file identifies itself as **Vortex X Sage [MM2] - WindUI**.
- It references MM2-specific role/tool/remotes and player-targeting behavior.
- The uploaded copy ends inside the Night Mode water-restoration block; the final expression is incomplete.
- It loads UI code from external GitHub URLs at runtime.
- It uses executor-only functions including `getgenv`, `gethui`, `firetouchinterest`, `identifyexecutor`, `loadstring`, and `game:HttpGet`. These are not standard Roblox Studio APIs.
- A `Players.PlayerRemoving` callback references `cleanESP` before the later local declaration, which can resolve incorrectly unless forward-declared.

## Adaptation decisions
| Original area | Starfall direction |
| --- | --- |
| WindUI window and tabs | Recreate the navigation with native Studio UI first; no runtime loader dependency |
| Branding | Starfall / Personal Edition, navy + blue + violet |
| Graphics and night mode | Local Lighting preset with explicit restore |
| FPS/performance | Lightweight client FPS counter and Output diagnostics |
| Movement | Local test toggle for the developer's own place; restores the prior speed |
| MM2 combat, remote abuse, silent aim, kill aura, forced touch, farming | Not ported as public-game cheats; implement legitimate mechanics in your own experience with server-side validation |

## Testing checklist
- [ ] Run as a LocalScript under `StarterPlayerScripts`
- [ ] Verify RightShift show/hide and close button
- [ ] Apply Nightfall and restore lighting
- [ ] Toggle test speed twice and confirm the original speed returns
- [ ] Respawn and check for errors in Output
- [ ] Test at different viewport sizes
- [ ] Review any warnings in Output before expanding the feature set
