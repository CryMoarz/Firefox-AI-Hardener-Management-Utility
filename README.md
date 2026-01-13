# Firefox AI Hardener & Management Utility v3.1 (Experimental)

⚠️ **Experimental:** This script is in development and should be used with caution. While designed to be safe, it **modifies Firefox `user.js` files** and may have unexpected effects on profiles. Always ensure you have backups before use.

A cross-platform Bash script to **disable AI/ML features in Firefox** and enforce privacy preferences. Supports **Linux (native, Snap, Flatpak), macOS, and BSD**. Provides **apply, rollback, and backup management**.

---

## Features

- Disables Firefox AI/ML features like `browser.ml.chat`, `extensions.ml.enabled`, etc.
- Applies changes across all Firefox profiles on the system.
- Automatic creation and rotation of timestamped `user.js` backups (configurable).
- Rollback functionality to remove applied hardening safely.
- Works on profiles with spaces in their paths.
- Process-aware: warns if Firefox is running.

**⚠️ Experimental notes:**
- This tool is not officially supported by Mozilla.
- Changes may be overwritten by Firefox updates or extensions.
- Always test on non-critical profiles first.

---

## Installation

1. Clone the repository:

```bash
git clone https://github.com/CryMoarz/Firefox-AI-Hardener-Management-Utility.git
cd Firefox-AI-Hardener-Management-Utility
```

2. Make the script executable:

```bash
chmod +x firefox-ai-hardener.sh
```

3. (Optional) Move it to a directory in your PATH:

```bash
sudo mv firefox-ai-hardener.sh /usr/local/bin/firefox-ai-hardener
```

---

## Usage

```bash
# Apply AI privacy hardening to all Firefox profiles
./firefox-ai-hardener.sh --apply

# Remove the applied hardening
./firefox-ai-hardener.sh --rollback

# Show help message
./firefox-ai-hardener.sh --help
```

**Notes:**
- Backups of `user.js` are automatically created and rotated (default: last 5 backups retained).
- Only `user.js` is modified; **profiles, bookmarks, and extensions are not deleted**.
- If Firefox is running, you will be warned. Restart Firefox for changes to take effect.

---

## Configuration

- `MAX_BACKUPS` determines how many backup copies of `user.js` are retained.
- `SEARCH_PATHS` lists directories to scan for Firefox profiles. Add custom paths if needed.

---

## License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

---

## Contributing

Contributions are welcome! Please keep in mind this script is experimental. Test thoroughly before submitting fixes or new features.

---

## Disclaimer

⚠️ **Use at your own risk.** The script modifies Firefox `user.js` files but is designed to **avoid deleting profiles or personal data**. Always backup your profiles before use. Firefox updates or extensions may override these settings.
