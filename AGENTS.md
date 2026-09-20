# Project Guidelines

## Scope

- This workspace contains independent FiveM resources, not one unified application. Treat `0r_lib`, `cd_bridge`, `codem-lib`, `CubX-Bridge`, `dusa_bridge`, `nass_lib`, and `utility_lib` as separate resources with separate manifests and public APIs.
- Before editing, identify the owning resource and inspect its `fxmanifest.lua`, config, and nearby implementation. Do not assume conventions from one bridge apply to another.

## Lua and Resource Conventions

- Keep Lua 5.4 enabled where the resource already declares `lua54 'yes'` or `lua54 "yes"`.
- Preserve manifest load order and client/server/shared boundaries. A file loaded on one runtime must not rely on globals or natives that only exist on the other runtime.
- Treat exports, events, config keys, bridge globals, and framework/inventory adapter names as public compatibility surfaces. Preserve them unless the task explicitly requires a breaking change.
- When changing a module discovered through `LoadResourceFile`, update the corresponding manifest `files` entry and preserve its runtime path.
- Keep optional integrations optional. Follow the resource's existing detection/configuration pattern before adding a hard dependency.
- Match the local Lua style and naming in the edited resource; avoid broad cleanup of decompiled or escrow-related code while changing behavior.

## Validation

- There is no workspace-wide build or test command. Validate changes against the edited resource's manifest and run the narrowest available Lua/static check.
- For runtime changes, test in a FiveM server with the required framework, database, inventory, target, and UI resources started in the manifest's expected order.
- For NUI changes, verify the resource's `ui_page` and `files` entries, then exercise the affected export/event in game.
- Check both client and server paths when changing shared bridge state, detection, callbacks, or adapters.

## Documentation

- Resource-specific guidance is documented in [codem-lib/README.md](codem-lib/README.md), [utility_lib/README.md](utility_lib/README.md), [0r_lib/README_CLEANUP.md](0r_lib/README_CLEANUP.md), and [dusa_bridge/textui/README.md](dusa_bridge/textui/README.md). Read the relevant document instead of copying its contents into new instructions.
- Record new public exports, configuration options, dependencies, or startup requirements in the owning resource's documentation when the change warrants it.
