#!/bin/bash
#
# Nuclear Plugin Cleanup Script
# Completely removes a plugin and its marketplace from Claude Code
#
# Usage: ./nuclear-cleanup.sh <plugin_name> <marketplace_name> [github_repo]
#
# Example: ./nuclear-cleanup.sh vd_workflow vd_workflow jyaunches/vd_workflow
#

set -e

PLUGIN_NAME="${1:-vd_workflow}"
MARKETPLACE_NAME="${2:-vd_workflow}"
GITHUB_REPO="${3:-}"

CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"

echo "=== Nuclear Plugin Cleanup ==="
echo "Plugin: $PLUGIN_NAME"
echo "Marketplace: $MARKETPLACE_NAME"
echo ""

# 1. Clean cache
echo "[1/5] Cleaning plugin cache..."
rm -rf "$PLUGINS_DIR/cache/$MARKETPLACE_NAME"
rm -rf "$PLUGINS_DIR/cache/$PLUGIN_NAME"

# 2. Clean marketplace directories
echo "[2/5] Cleaning marketplace directories..."
rm -rf "$PLUGINS_DIR/marketplaces/$MARKETPLACE_NAME"
rm -rf "$PLUGINS_DIR/marketplaces/github.com-"*"$MARKETPLACE_NAME"*

# 3. Clean settings.json
echo "[3/5] Cleaning settings.json..."
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    cat "$CLAUDE_DIR/settings.json" | \
        jq "del(.enabledPlugins[\"${PLUGIN_NAME}@${MARKETPLACE_NAME}\"]) | del(.extraKnownMarketplaces[\"${MARKETPLACE_NAME}\"])" \
        > /tmp/settings_clean.json && \
        mv /tmp/settings_clean.json "$CLAUDE_DIR/settings.json"
fi

# 4. Clean known_marketplaces.json
echo "[4/5] Cleaning known_marketplaces.json..."
if [ -f "$PLUGINS_DIR/known_marketplaces.json" ]; then
    cat "$PLUGINS_DIR/known_marketplaces.json" | \
        jq "del(.[\"${MARKETPLACE_NAME}\"])" \
        > /tmp/km_clean.json && \
        mv /tmp/km_clean.json "$PLUGINS_DIR/known_marketplaces.json"
fi

# 5. Clean installed_plugins.json
echo "[5/5] Cleaning installed_plugins.json..."
if [ -f "$PLUGINS_DIR/installed_plugins.json" ]; then
    cat "$PLUGINS_DIR/installed_plugins.json" | \
        jq "del(.plugins[\"${PLUGIN_NAME}@${MARKETPLACE_NAME}\"])" \
        > /tmp/ip_clean.json && \
        mv /tmp/ip_clean.json "$PLUGINS_DIR/installed_plugins.json"
fi

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "Next steps:"
echo "1. Restart Claude Code completely (quit and reopen)"
echo ""
echo "2. Re-add the marketplace:"
if [ -n "$GITHUB_REPO" ]; then
    echo "   /plugin marketplace add $GITHUB_REPO"
else
    echo "   /plugin marketplace add <owner>/<repo>"
fi
echo ""
echo "3. Install the plugin from the Discover tab in /plugin menu"
echo ""
