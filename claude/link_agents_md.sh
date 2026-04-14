#!/bin/bash
# 把 claude/AGENTS.md 链接到 ~/AGENTS.md
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ln -sf "$SCRIPT_DIR/AGENTS.md" ~/AGENTS.md
echo "已创建 ~/AGENTS.md -> $SCRIPT_DIR/AGENTS.md"
