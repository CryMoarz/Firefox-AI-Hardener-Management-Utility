#!/bin/bash

# ==============================================================================
# Firefox AI Hardener & Management Utility v3.1
# Optimized for: macOS, Linux (Snap/Flatpak/Native), and BSD
# Repo: https://github.com/CryMoarz/Firefox-AI-Hardener-Management-Utility
# ==============================================================================

# Tags for the managed block
TAG_START="// BEGIN FF-AI-HARDENER"
TAG_END="// END FF-AI-HARDENER"
MAX_BACKUPS=5

# Preferences block
PREFS_BLOCK="$TAG_START
user_pref(\"browser.ml.enable\", false);
user_pref(\"browser.ml.chat.enabled\", false);
user_pref(\"browser.ml.chat.menu\", false);
user_pref(\"browser.ml.chat.shortcuts\", false);
user_pref(\"browser.ml.chat.shortcuts.custom\", false);
user_pref(\"extensions.ml.enabled\", false);
user_pref(\"browser.ml.linkPreview.enabled\", false);
user_pref(\"browser.tabs.groups.smart.enabled\", false);
user_pref(\"browser.tabs.groups.smart.userEnabled\", false);
$TAG_END"

SEARCH_PATHS=(
    "$HOME/.mozilla/firefox"
    "$HOME/Library/Application Support/Firefox/Profiles"
    "$HOME/snap/firefox/common/.mozilla/firefox"
    "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
)

# --- UI Helpers ---

log()   { echo -e "[\033[1;34mINFO\033[0m] $1"; }
warn()  { echo -e "[\033[1;33mWARN\033[0m] $1"; }
error() { echo -e "[\033[1;31mERROR\033[0m] $1"; }

# --- Core Logic ---

# Portable SED with escaped delimiters for safety
run_sed_delete_block() {
    local file="$1"
    # Escaping slashes and common regex chars for SED safety
    local esc_start=$(printf '%s\n' "$TAG_START" | sed 's/[\/&[].*^$]/\\&/g')
    local esc_end=$(printf '%s\n' "$TAG_END" | sed 's/[\/&[].*^$]/\\&/g')
    
    if sed --version >/dev/null 2>&1; then
        sed -i "/$esc_start/,/$esc_end/d" "$file"         # GNU
    else
        sed -i '' "/$esc_start/,/$esc_end/d" "$file"      # BSD/macOS
    fi
}

# Rotates backups to keep only the last N
rotate_backups() {
    local user_js="$1"
    # Find backups, sort by time, skip the first $MAX_BACKUPS, and remove the rest
    ls -1t "${user_js}.bak."* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) | xargs -r rm 2>/dev/null
}

check_running() {
    if pgrep -f "firefox" >/dev/null; then
        warn "Firefox process detected. Please restart Firefox after completion for changes to take effect."
    fi
}

# --- Actions ---

apply() {
    check_running
    log "Scanning for Firefox profiles..."
    local processed=0
    local modified=0

    for base in "${SEARCH_PATHS[@]}"; do
        [ ! -d "$base" ] && continue
        
        while IFS= read -r -d '' prefs_path; do
            ((processed++))
            profile_dir=$(dirname "$prefs_path")
            user_js="$profile_dir/user.js"
            
            if [ -f "$user_js" ]; then
                cp "$user_js" "${user_js}.bak.$(date +%s)"
                rotate_backups "$user_js"
            else
                log "Creating new user.js in: $(basename "$profile_dir")"
                touch "$user_js"
            fi
            
            run_sed_delete_block "$user_js"
            echo "$PREFS_BLOCK" >> "$user_js"
            log "Hardened: $(basename "$profile_dir")"
            ((modified++))
            
        done < <(find "$base" -type f -name "prefs.js" -print0 2>/dev/null)
    done
    
    log "Summary: Processed $processed profile(s), Modified $modified."
}

rollback() {
    log "Initiating rollback..."
    local processed=0
    local cleaned=0

    for base in "${SEARCH_PATHS[@]}"; do
        [ ! -d "$base" ] && continue
        
        while IFS= read -r -d '' prefs_path; do
            ((processed++))
            profile_dir=$(dirname "$prefs_path")
            user_js="$profile_dir/user.js"
            
            if [ -f "$user_js" ]; then
                run_sed_delete_block "$user_js"
                log "Cleaned: $(basename "$profile_dir")"
                ((cleaned++))
            else
                warn "No user.js found in $(basename "$profile_dir"), skipping rollback."
            fi
        done < <(find "$base" -type f -name "prefs.js" -print0 2>/dev/null)
    done
    log "Rollback finished. Cleaned $cleaned of $processed profile(s)."
}

# --- Router ---

case "$1" in
    --apply) apply ;;
    --rollback) rollback ;;
    --help|-h)
        echo "Firefox AI Hardener v3.1"
        echo "Usage: $0 [OPTION]"
        echo "  --apply      Apply AI privacy hardening to all Firefox profiles"
        echo "  --rollback   Remove the hardening block from all profiles"
        echo "  --help, -h   Show this help message"
        ;;
    *)
        error "Invalid argument. Use --help for usage instructions."
        exit 1
        ;;
esac
