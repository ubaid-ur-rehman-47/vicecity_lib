## Plan: Build `vicecity_lib`

Build a new FiveM/GTA V resource with one clean, configurable API. The existing libraries will be used as reference implementations only, not merged blindly. External frameworks, inventories, databases, phones, HUDs, and similar resources remain optional adapters, while native FiveM functionality is implemented directly where possible.

**Steps**

### 1. Core Foundation

1. Create `e:\vicecity_lib\vicecity_lib\` as a new Lua 5.4 resource.
2. Add namespaced runtime APIs such as `ViceCity.Framework`, `ViceCity.Inventory`, `ViceCity.Database`, `ViceCity.UI`, and `ViceCity.Events`.
3. Define normalized return values, error handling, readiness state, version access, lifecycle management, and client/server boundaries.
4. Add a central configuration system supporting:
   - Explicit provider selection
   - Auto-detection and priority lists
   - Disabled modules
   - Native fallback behavior
   - Debugging and diagnostics
   - Timeouts and locales
   - Custom provider registration

### 2. Provider System

1. Implement one provider registry and detector instead of separate detection logic per module.
2. Track provider states such as `missing`, `stopped`, `started`, `configured`, and `failed`.
3. Add diagnostics showing selected providers, fallback reasons, dependencies, and configuration errors.
4. Prevent duplicate event handlers and make initialization restart-safe.

### 3. Framework, Database, and Inventory

1. Add adapters for ESX, QBCore, Qbox, and standalone mode.
2. Normalize player loading, characters, identifiers, names, jobs, gangs, duty, money, permissions, callbacks, and server player lookup.
3. Add an oxmysql-first database adapter with query, transaction, timeout, error, and migration support.
4. Add inventory adapters for the major systems already represented in the repository.
5. Normalize items, metadata, slots, weight, weapons, add/remove operations, images, and inventory UI.
6. Add appearance and clothing adapters with custom-provider support.

### 4. Feature Modules

Implement each module behind a common contract with configuration, provider priority, fallback behavior, and diagnostics:

- Notifications
- Text UI
- Progress bars
- Skill checks
- Menus and dialogues
- Markers, blips, points, peds, zones, and targets
- Phones and HUDs
- Garages and dealerships
- Vehicle keys, fuel, vehicles, and mechanic systems
- Door locks and wardrobe
- Weather
- Billing and society/banking
- Dispatch, MDT, medical, and ambulance
- Loading screens, version checks, common events, and general utilities

### 5. Documentation and Examples

1. Add a complete README covering installation, startup order, configuration, provider selection, diagnostics, and API usage.
2. Add documentation for architecture, provider authoring, database behavior, security, NUI, troubleshooting, and migration.
3. Add examples for custom providers, forced providers, callbacks, zones, targets, and native fallbacks.
4. Add limited opt-in compatibility shims only after the new API is stable.

### 6. Validation

1. Validate manifests, load order, runtime boundaries, `files`, `ui_page`, exports, and `LoadResourceFile` usage.
2. Add static Lua checks and contract tests for configuration, provider resolution, normalization, callbacks, and fallback selection.
3. Test standalone/native mode, ESX, QBCore, and Qbox.
4. Test provider absence, stopped providers, forced providers, runtime errors, restart order, and NUI focus cleanup.
5. Deliver incrementally: kernel, framework/inventory/database, interaction/UI, gameplay modules, provider expansion, then documentation and shims.

**Relevant reference files**

- `fxmanifest.lua` — broad existing module structure.
- `boot.lua` — provider detection and diagnostics.
- `client.lua` — normalized ESX API.
- `client.lua` — QBCore/Qbox API pattern.
- `auto_detect.lua` — provider catalog.
- `config.lua` — configurable provider overrides.
- `init.lua` — module registration.
- `api.lua` — target and zone option normalization.
- `bridge.lua` — startup validation ideas.
- `AGENTS.md` — workspace-specific implementation rules.

**Decisions**

- FiveM/GTA V only for the first version.
- Existing resources remain untouched and serve as references.
- Consumers use one `vicecity_lib` API.
- External systems remain optional adapters when they own authoritative data or functionality.
- Native functionality is built into `vicecity_lib` wherever practical.
- Framework-authoritative persistence, accounts, character data, and databases require adapters unless a standalone backend is later designed.
- The recommended new resource path is `e:\vicecity_lib\vicecity_lib\`.

The detailed persistent plan is saved in `/memories/session/plan.md`.

huds, billing, doorlock, fuel, mdt, dispatch, medical, ambulance, notification, progress, skills, targers, texuis, vehicles, weather, dealership, mechanic, dialogues, menus, markers, blips, callbacks, loading, version, points, peds, zones, database
