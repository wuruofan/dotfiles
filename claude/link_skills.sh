#!/bin/bash
# 将 claude/skills 下的 skill 链接到 ~/.claude/skills/
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
CLAUDE_SKILLS_SRC="$SCRIPT_DIR/skills"

for skill in "$CLAUDE_SKILLS_SRC"/*/; do
    skill_name=$(basename "$skill")
    link_path="$SKILLS_DIR/$skill_name"
    if [ -L "$link_path" ]; then
        rm "$link_path"
    elif [ -e "$link_path" ]; then
        echo "警告: $link_path 已存在且不是符号链接，跳过"
        continue
    fi
    ln -s "$skill" "$link_path"
    echo "已创建 $link_path -> $skill"
done
