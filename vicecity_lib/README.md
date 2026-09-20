# vicecity_lib

A configurable FiveM/GTA V compatibility and utility library.

## Installation

1. Add `vicecity_lib` to the server resources directory.
2. Start it before resources that consume its exports.
3. Configure `config.lua` for explicit providers or leave providers on `auto`.

```cfg
ensure vicecity_lib
```

## Current baseline

The first implementation provides a namespaced runtime, provider registration, startup readiness, diagnostics, and native standalone fallbacks.

```lua
if exports.vicecity_lib:IsReady() then
    local diagnostics = exports.vicecity_lib:GetDiagnostics()
    print(diagnostics.resolved.framework)
end
```

The public runtime namespace is `ViceCity`. Provider adapters and capability modules will be added behind this stable boundary.

## Configuration

`config.lua` supports:

- `debug`: print startup information
- `strict`: reserved for strict provider validation
- `providerTimeout`: provider operation timeout in milliseconds
- `providers`: explicit provider names or `auto`
- `disabled`: capability categories to disable

Existing resources in this workspace are reference implementations and are not required by the baseline runtime.
