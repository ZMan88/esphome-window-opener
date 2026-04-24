# Firmware

ESPHome config for the window opener. Entry point: `window-opener.yaml`.

## First-time setup

```
cp common/secrets.example.yaml common/secrets.yaml
# edit common/secrets.yaml with real values
```

Generate a fresh API encryption key and OTA password:

```
openssl rand -base64 32   # api_encryption_key
openssl rand -base64 16   # ota_password, fallback_password
```

## Build / flash

Run from the repo root, not from `firmware/`:

```
esphome config firmware/window-opener.yaml   # validate YAML only
esphome run    firmware/window-opener.yaml   # compile + flash + follow logs
esphome logs   firmware/window-opener.yaml   # tail logs from a running device
```

`esphome run` auto-detects USB vs OTA — plug in over USB the first time, then subsequent flashes go over the network.

## Switching actuator variant

Edit the `packages:` block in `window-opener.yaml`:

```yaml
packages:
  base: !include common/base.yaml
  variant: !include variants/linear-actuator.yaml   # or variants/stepper.yaml
```

Only one `variant:` line should be uncommented. Both variants expose the same HA entity (`cover.window_opener`), so no HA-side change is needed when switching.

## File layout

- `window-opener.yaml` — top-level config, variant selector
- `common/base.yaml` — Wi-Fi, API, OTA, logger, uptime
- `common/secrets.example.yaml` — template for `secrets.yaml`
- `variants/linear-actuator.yaml` — BTS7960 + time-based cover
- `variants/stepper.yaml` — TMC2209 + stepper + endstop + template cover
