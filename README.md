# Raycast Chrome Switcher

Raycast scripts to quickly switch Chrome tabs between different server environments.

## Description

Two AppleScript commands for seamless URL switching during development:

- **Toggle Local Development**: Toggles between your local development environment and default server
- **Switch Server**: Choose between multiple production servers using short keys

Both scripts preserve the full URL path and query parameters during switching.

## Configuration

Edit `config.json` with your server mappings:

```json
{
  "defaultLocal": "dev",
  "defaultRemote": "prod",
  "servers": {
    "prod": "https://www.example.com",
    "staging": "https://staging.example.com",
    "dev": "http://127.0.0.1:9001"
  },
  "debugMode": false
}
```

**Usage Examples:**
- **Toggle Local**:
  - From remote: `https://www.example.com/dashboard` → `http://127.0.0.1:9001/dashboard`
  - From local: `http://127.0.0.1:9001/dashboard` → `https://www.example.com/dashboard`
- **Switch Server**: Type "staging" to go from any URL to `https://staging.example.com/dashboard`

The toggle script uses `defaultLocal` and `defaultRemote` keys to determine which servers to toggle between.

## Installation

1. Clone this repository
2. Copy `config.example.json` to `config.json` and edit with your server URLs
3. Add the script directory to Raycast (Extensions → Script Commands → Add Script Directory)
4. Grant Raycast accessibility permissions in System Preferences

**Note:** Your `config.json` file is gitignored to keep your server configurations private.

## License

MIT License - see [LICENSE](LICENSE) file for details.
