#!/bin/bash
# Claude Code Status Line - 分隔符风格 + 渐变进度条
# 自动检测 llama-server 配置，无需额外环境变量

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
current_usage=$(echo "$input" | jq -r '.context_window.current_usage // empty')

# 从 Claude Code 配置中检测本地模型服务地址
detect_llama_server() {
    # 从 ANTHROPIC_BASE_URL 提取 base URL（Claude Code 本地模式的标准变量）
    # 支持 any-scale://host:port 或 http://host:port 格式
    if [ -n "$ANTHROPIC_BASE_URL" ]; then
        # 去掉 /v1、/v1/ 等路径和末尾斜杠
        local server_url=$(echo "$ANTHROPIC_BASE_URL" | sed -E 's|/v1/?$||' | sed -E 's|/$||')
        # 验证是否是本地地址
        if echo "$server_url" | grep -qE '^(http|https|any-scale)://(localhost|127\.0\.0\.1)'; then
            echo "$server_url"
            return
        fi
    fi

    echo ""
}

# 从 llama-server 获取 context 大小（带缓存）
get_llama_context() {
    local server_url=$1
    local cache_file="/tmp/claude_code_llama_ctx_$(echo "$server_url" | tr '/:' '_').cache"
    local cache_ttl=300  # 5分钟缓存

    # 检查缓存
    if [ -f "$cache_file" ]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)))
        if [ "$cache_age" -lt "$cache_ttl" ]; then
            cat "$cache_file" 2>/dev/null
            return
        fi
    fi

    local ctx=""

    # 尝试 /props 端点（llama.cpp server 标准端点）
    if [ -z "$ctx" ] || [ "$ctx" = "null" ]; then
        ctx=$(curl -s "${server_url}/props" 2>/dev/null | jq -r '.default_generation_settings.n_ctx // .default_generation_settings.params.n_ctx // empty')
    fi

    # 尝试 /v1/models 端点（OpenAI 兼容）
    if [ -z "$ctx" ] || [ "$ctx" = "null" ]; then
        ctx=$(curl -s "${server_url}/v1/models" 2>/dev/null | jq -r '.data[0].meta.n_ctx // .data[].meta.n_ctx // empty')
    fi

    # 尝试 /slots 端点（llama.cpp 内部状态）
    if [ -z "$ctx" ] || [ "$ctx" = "null" ]; then
        ctx=$(curl -s "${server_url}/slots" 2>/dev/null | jq -r '.[0].n_ctx // .[].n_ctx // empty')
    fi

    # 写入缓存
    if [ -n "$ctx" ] && [ "$ctx" != "null" ]; then
        echo "$ctx" > "$cache_file" 2>/dev/null
    fi

    echo "$ctx"
}

# 主逻辑：获取 total_tokens
total_tokens=""

# 首先尝试从 llama-server 获取
llama_server_url=$(detect_llama_server)
if [ -n "$llama_server_url" ]; then
    llama_ctx=$(get_llama_context "$llama_server_url")
    if [ -n "$llama_ctx" ] && [ "$llama_ctx" != "null" ] && [ "$llama_ctx" -gt 0 ] 2>/dev/null; then
        total_tokens=$llama_ctx
    fi
fi

# 回退到 Claude Code 提供的值
if [ -z "$total_tokens" ] || [ "$total_tokens" = "null" ]; then
    total_tokens=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
fi

# 如果还是没有，使用常见默认值
if [ -z "$total_tokens" ] || [ "$total_tokens" = "null" ]; then
    # 从模型名推断常见 context 大小
    model_id=$(echo "$input" | jq -r '.model.id // empty')
    case "$model_id" in
        *"8b"*|*"9b"*) total_tokens=32768 ;;
        *"14b"*|*"32b"*) total_tokens=65536 ;;
        *"70b"*|*"100b"*) total_tokens=131072 ;;
        *) total_tokens=32768 ;;  # 默认 32k
    esac
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

# 3. 模型名（简化处理）
model_display="$model"
if [ ${#model} -gt 20 ]; then
    model_display=$(echo "$model" | sed 's/^claude-//')
fi

# 4. 渐变进度条
bar_length=10
filled=$((used_pct * bar_length / 100))
[ $filled -gt $bar_length ] && filled=$bar_length
empty=$((bar_length - filled))

if [ "$used_pct" -le 30 ]; then
    FILLED_COLOR=$GREEN
elif [ "$used_pct" -le 70 ]; then
    FILLED_COLOR=$YELLOW
else
    FILLED_COLOR=$RED
fi

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

# 布局
output="${BOLD}${CYAN}${current_dir}${RESET} "
output+="${MAGENTA}( ${branch})${RESET} "
output+="${GRAY}󰚩  ${model_display}${RESET} "
output+="${bar} "
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
