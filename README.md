# Raycast Chrome Switcher

Raycast scripts to quickly switch Chrome tabs between production and local development environments.

## Description

Two AppleScript commands that perform simple find-and-replace on your current Chrome tab's URL:

- **Switch to Local Development**: Replaces production URL with local development URL
- **Switch to Production**: Replaces local development URL with production URL

Simple string replacement preserves the full path and query parameters.

## Configuration

Edit `config.json` with your full URLs:

```json
{
  "productionURL": "https://www.mysite.com",
  "localURL": "http://127.0.0.1:9001",
  "debugMode": false
}
```

## Installation

1. Clone this repository
2. Copy `config.example.json` to `config.json` and edit with your URLs
3. Add the script directory to Raycast (Extensions → Script Commands → Add Script Directory)
4. Grant Raycast accessibility permissions in System Preferences

## License

MIT License - see [LICENSE](LICENSE) file for details.
