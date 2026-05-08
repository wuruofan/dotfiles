#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_FILE="$SCRIPT_DIR/AGENTS.md"

TARGETS=()

backup_file() {
    local target="$1"
    local backup="${target}.bak.$(date +%Y%m%d_%H%M%S)"
    echo "备份 ${target} -> ${backup}"
    cp "$target" "$backup"
}

is_link_to_source() {
    local target="$1"
    if [ -L "$target" ]; then
        local link_target=$(readlink "$target")
        if [ "$link_target" = "$SOURCE_FILE" ] || [ "$(readlink -f "$target")" = "$(readlink -f "$SOURCE_FILE")" ]; then
            return 0
        fi
    fi
    return 1
}

create_link() {
    local target_file="$1"
    
    echo ""
    echo "处理目标: $target_file"

    if is_link_to_source "$target_file"; then
        echo "✅ 当前目标已经是指向源文件的链接，跳过"
        return 0
    fi

    if [ -e "$target_file" ]; then
        if [ -L "$target_file" ]; then
            echo "⚠️ 目标位置存在符号链接，指向: $(readlink "$target_file")"
        else
            echo "⚠️ 目标位置已存在文件"
        fi
        read -p "是否覆盖（自动备份）? (Y/n): " overwrite_choice
        if [ "$overwrite_choice" = "y" ] || [ "$overwrite_choice" = "Y" ] || [ -z "$overwrite_choice" ]; then
            backup_file "$target_file"
        else
            echo "跳过"
            return 0
        fi
    fi

    echo "创建链接: $SOURCE_FILE -> $target_file"
    ln -sf "$SOURCE_FILE" "$target_file"
    echo "✅ 链接创建成功! 验证: $(readlink "$target_file")"
}

echo "=== AGENTS.md 链接创建工具 ==="
echo "源文件: $SOURCE_FILE"
echo ""
echo "请选择目标位置:"
echo "  1) ~/AGENTS.md"
echo "  2) ~/.claude/CLAUDE.md"
echo "  3) 两个都创建"
read -p "输入选择 (1/2/3): " choice

case "$choice" in
    1)
        TARGETS+=("$HOME/AGENTS.md")
        ;;
    2)
        TARGET_DIR="$HOME/.claude"
        if [ ! -d "$TARGET_DIR" ]; then
            echo "创建目录: $TARGET_DIR"
            mkdir -p "$TARGET_DIR"
        fi
        TARGETS+=("$TARGET_DIR/CLAUDE.md")
        ;;
    3)
        TARGETS+=("$HOME/AGENTS.md")
        TARGET_DIR="$HOME/.claude"
        if [ ! -d "$TARGET_DIR" ]; then
            echo "创建目录: $TARGET_DIR"
            mkdir -p "$TARGET_DIR"
        fi
        TARGETS+=("$TARGET_DIR/CLAUDE.md")
        ;;
    *)
        echo "无效选择，退出"
        exit 1
        ;;
esac

for target in "${TARGETS[@]}"; do
    create_link "$target"
done

echo ""
echo "=== 操作完成 ==="