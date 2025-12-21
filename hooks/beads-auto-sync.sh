#!/bin/bash
#
# Beads Auto-Sync Hook for Claude Code
#
# This hook automatically syncs beads when appropriate events occur.
# Triggers: post-commit, session-end, pre-compact
#
# Companion: beads-context-monitor.sh (monitors token usage thresholds)
# Installation: Place in ~/.claude/hooks/ and configure in settings

set -euo pipefail

# Check if beads is installed
if ! command -v bd &> /dev/null; then
  echo "❌ Beads (bd) is not installed!"
  echo ""
  echo "The beads-task-management skill requires beads."
  echo ""
  echo "Install with:"
  echo "  brew install steveyegge/beads/bd"
  echo ""
  echo "Or visit: https://github.com/steveyegge/beads"
  exit 1
fi

# Check if this project uses beads
if [ ! -d ".beads" ]; then
  echo "ℹ️  This project doesn't use beads (.beads/ directory not found)"
  echo ""
  echo "To initialize beads in this project:"
  echo "  bd init"
  echo ""
  echo "Or disable the beads-task-management skill if not needed."
  exit 1
fi

# Get the hook event type (passed by Claude Code)
EVENT="${1:-unknown}"

case "$EVENT" in
  "post-commit")
    # After a git commit, sync beads
    echo "🔄 Auto-syncing beads after commit..."
    bd sync --quiet || echo "⚠️  Beads sync failed (non-fatal)"
    ;;

  "session-end")
    # Before session ends, ensure beads are synced
    echo "🔄 Syncing beads before session end..."
    bd sync || {
      echo "❌ Beads sync failed - manual sync required!"
      exit 1
    }
    ;;

  "pre-compact")
    # Before compact, verify recovery card exists
    if ! bd list 2>/dev/null | grep -q "RECOVERY:"; then
      echo "⚠️  WARNING: No recovery card found!"
      echo "   Create one with: bd create 'RECOVERY: Current Session Context' -p 0"
      echo "   (Keep status 'open' so it appears in bd ready)"
      exit 1
    fi

    # Sync beads
    echo "🔄 Syncing beads before compact..."
    bd sync || {
      echo "❌ Beads sync failed - cannot compact safely!"
      exit 1
    }

    echo "✅ Recovery card exists and beads synced"
    ;;

  *)
    # Unknown event, do nothing
    exit 0
    ;;
esac

exit 0
