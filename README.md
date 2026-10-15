# Starfall

**Starfall | Personal Edition** is a Roblox Studio-native developer panel for building and testing your own Murder Mystery-style experience. The visual direction is dark navy with blue and violet accents.

## Install
1. Put `Starfall.client.lua` as a **LocalScript** in `StarterPlayer > StarterPlayerScripts`.
2. Put `StarfallServer.server.lua` as a **Script** in `ServerScriptService`.
3. Press **Play**. Press **RightShift** to show/hide the panel.

## Tabs
- **Home:** FPS counter and status.
- **Visuals:** local character and camera diagnostics.
- **Environment:** reversible Nightfall lighting preset.
- **Movement:** local movement test toggle.
- **Roles:** sets your own `StarfallTestRole` attribute to Murderer, Sheriff, or Innocent.
- **Round:** sets a test-round flag and teleports to configured test points.
- **Player Test:** test coins attribute and optional test tools.
- **ESP:** role highlights for players whose test-role attributes are set.
- **Settings:** restore lighting and project info.

## Optional test objects
- `Workspace > StarfallTestPoints > TestSpawn` (Part)
- `Workspace > StarfallTestPoints > GunDrop` (Part)
- `ServerStorage > StarfallTestTools > TestKnife` (Tool)
- `ServerStorage > StarfallTestTools > TestGun` (Tool)

Role and round controls set **test attributes**; they do not implement a complete round system by themselves. Connect `StarfallTestRole` and `StarfallTestRoundEnded` to your server-side round manager. `StarfallTestCoins` is a test value, not a production economy.

## Security
The server script is **Studio-only by default** and validates action names and values on the server. Keep `STUDIO_ONLY = true` while developing. If you later enable a private published test server, configure the numeric Roblox UserId allowlist first; never treat a client UI as authorization.

## Original source notes
The supplied `Vortex X Sage [MM2]` script was incomplete at its final Night Mode block and relies on executor APIs that are not standard Studio APIs. This project recreates useful UI and developer testing features without copying executor-only remote abuse, silent aim, kill aura, forced touch interactions, or public-game farming.

See [source audit](docs/ORIGINAL_SOURCE_AUDIT.md).


## Role ESP test integration (Studio)

The Roles tab now includes a player roster. In a Studio test session, choose Murderer, Sheriff, or Innocent beside a player; the server sets that player's `StarfallTestRole` attribute, which replicates to clients. Enable **Role ESP** to show the colored outline and label. Use **Clear role** to remove a test tag and **Refresh player roster** after the test roster changes.

Install both scripts:
1. `Starfall.client.lua` as a **LocalScript** in `StarterPlayer > StarterPlayerScripts`.
2. `StarfallServer.server.lua` as a **Script** in `ServerScriptService`.

The server script is Studio-only by default (`STUDIO_ONLY = true`). This role roster is a test harness; it does not read the decompiled game's hidden round roles or alter the game's round manager. Do not turn off the Studio restriction for a public experience without adding a secure developer allowlist and reviewing every server action.
