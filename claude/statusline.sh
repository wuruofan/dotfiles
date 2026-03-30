#!/bin/bash
# Claude Code Status Line - 分隔符风格 + 渐变进度条

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
current_usage=$(echo "$input" | jq -r '.context_window.current_usage // empty')

# 优先从 llama-server 获取真实的 context 大小（如果配置了 LLAMA_SERVER_URL）
if [ -n "$LLAMA_SERVER_URL" ]; then
    llama_ctx=$(curl -s "${LLAMA_SERVER_URL}/props" 2>/dev/null | jq -r '.default_generation_settings.params.n_ctx // empty')
fi
if [ -n "$llama_ctx" ] && [ "$llama_ctx" != "null" ]; then
    total_tokens=$llama_ctx
else
    # 回退到 Claude Code 提供的值（第三方 API 或官方 Claude）
    total_tokens=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
fi

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "unknown"')

if [ -z "$used_pct" ] || [ "$used_pct" = "null" ]; then
    exit 0
fi

cd "$cwd" 2>/dev/null || true

# Colors
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
MAGENTA="\033[35m"
GRAY="\033[90m"
DIM="\033[2m"

# 1. 当前目录
current_dir=$(basename "$cwd" 2>/dev/null || echo "?")

# 2. 分支
branch=$(git branch --show-current 2>/dev/null | head -c15)
[ -z "$branch" ] && branch="no-git"

# 3. 模型名（简化处理，移除 claude- 前缀如果太长）
model_display="$model"
if [ ${#model} -gt 20 ]; then
    model_display=$(echo "$model" | sed 's/^claude-//')
fi

# 4. 渐变进度条（根据百分比改变颜色）
bar_length=10
filled=$((used_pct * bar_length / 100))
[ $filled -gt $bar_length ] && filled=$bar_length
empty=$((bar_length - filled))

# 渐变：0-30% 绿色, 31-70% 黄色, 71-100% 红色
if [ "$used_pct" -le 30 ]; then
    FILLED_COLOR=$GREEN
elif [ "$used_pct" -le 70 ]; then
    FILLED_COLOR=$YELLOW
else
    FILLED_COLOR=$RED
fi

# 未填充部分用灰色
bar="${FILLED_COLOR}"
for ((i=0; i<filled; i++)); do bar+="█"; done
bar+="${GRAY}"
for ((i=0; i<empty; i++)); do bar+="░"; done
bar+="${RESET}"

# 5. Token 格式化
format_tokens() {
    local n=$1
    if [ "$n" -ge 1000 ]; then
        local k=$((n / 1000))
        local rem=$(((n % 1000) / 100))
        [ "$rem" -eq 0 ] && echo "${k}k" || echo "${k}.${rem}k"
    else
        echo "$n"
    fi
}

if [ "$current_usage" != "null" ] && [ -n "$current_usage" ]; then
    input_tokens=$(echo "$current_usage" | jq -r '.input_tokens // 0')
    output_tokens=$(echo "$current_usage" | jq -r '.output_tokens // 0')
    in_fmt=$(format_tokens "$input_tokens")
    out_fmt=$(format_tokens "$output_tokens")
    tokens_str="↑${in_fmt} ↓${out_fmt}"
else
    tokens_str="↑0 ↓0"
fi

# 格式化总 context 大小
total_fmt=""
if [ -n "$total_tokens" ] && [ "$total_tokens" != "null" ]; then
    total_fmt=$(format_tokens "$total_tokens")
fi

# 6. Git 状态
git_status=$(git status --porcelain 2>/dev/null)
if [ -n "$git_status" ]; then
    staged=$(echo "$git_status" | grep -c "^[AMD]" 2>/dev/null || echo 0)
    modified=$(echo "$git_status" | grep -c "^.M" 2>/dev/null || echo 0)
    deleted=$(echo "$git_status" | grep -c "^.D" 2>/dev/null || echo 0)
    untracked=$(echo "$git_status" | grep -c "^??" 2>/dev/null || echo 0)
    
    git_str=""
    [ "$staged" -gt 0 ] && git_str+="${GREEN}+${staged}${RESET} "
    [ "$modified" -gt 0 ] && git_str+="${YELLOW}~${modified}${RESET} "
    [ "$deleted" -gt 0 ] && git_str+="${RED}-${deleted}${RESET} "
    [ "$untracked" -gt 0 ] && git_str+="${MAGENTA}?${untracked}${RESET} "
    git_str=$(echo "$git_str" | sed 's/ *$//')
else
    git_str="${GREEN}✓${RESET}"
fi

# 分隔符
SEP="${GRAY}•${RESET}"

# 布局：目录(分支) • 模型 [进度条] 百分比(总大小) • Token • Git
output="${BOLD}${CYAN}${current_dir}${RESET} "
output+="${MAGENTA}( ${branch})${RESET} "
output+="${GRAY}󰚩  ${model_display}${RESET} "
output+="${bar} "
# 修改这里：百分比后面加上总 context 大小
if [ -n "$total_fmt" ]; then
    output+="${GRAY}${used_pct}%(${total_fmt})${RESET} "
else
    output+="${GRAY}${used_pct}%${RESET} "
fi
output+="${SEP} "
output+="${BLUE}${tokens_str}${RESET} "
output+="${SEP} "
output+="${git_str}"

echo -e "$output"
