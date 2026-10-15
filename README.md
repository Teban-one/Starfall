# Starfall

**Starfall | Personal Edition** is a Roblox Studio-native personal testing UI, inspired by the layout of the supplied WindUI script. It uses a dark navy / blue / violet visual identity.

## Status
This repository starts with a Studio-compatible foundation. The supplied `Vortex X Sage [MM2]` source ends mid-expression in Night Mode and relies on executor-only APIs (`getgenv`, `gethui`, `firetouchinterest`, `loadstring`, `game:HttpGet`, and executor remotes). Those parts cannot be run as-is in Roblox Studio and are not copied into this project as public-game cheats.

## Install in Roblox Studio
1. Open your own experience in Studio.
2. In **Explorer**, open `StarterPlayer > StarterPlayerScripts`.
3. Create a **LocalScript** named `Starfall.client.lua`.
4. Copy the contents of [Starfall.client.lua](./Starfall.client.lua) into it.
5. Press **Play**. Press **RightShift** to show/hide the panel.

No external loader, executor, or HTTP request is needed.

## Included
- Native Roblox UI and tab navigation
- Blue/violet Starfall branding
- FPS display and local performance diagnostics
- Local environment preset with reversible Lighting changes
- Local character movement test toggle, restored when disabled
- Reset controls and notification feedback

## Safety / architecture
This is a client-side UI for testing in your own Studio experience. It intentionally does not include MM2 remote abuse, silent aim, kill aura, forced touch interactions, coin farming, or executor APIs. For gameplay mechanics in your own experience, implement and validate them on the server rather than trusting a LocalScript.

## Roadmap
- [x] Empty repository bootstrap
- [x] Studio-native Starfall UI foundation
- [x] Reversible environment settings
- [ ] Split UI, settings, and environment code into ModuleScripts
- [ ] Add server-authorized test tools for the specific mechanics in your own place
