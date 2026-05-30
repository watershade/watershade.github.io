#!/bin/bash
# deploy.sh - 构建并上传博客静态文件到腾讯云轻应用服务器
#
# 用法: ./deploy.sh
# 前置条件: ~/.secret_info/LoginWithSSH.pem (SSH密钥)
#           bundle (jekyll构建环境)
#
# 工作流程:
#   1. 在本地用 Jekyll 构建静态站点 (docs/_site/)
#   2. 通过 rsync/ssh 将静态文件同步到服务器

set -e

# ========== 配置 ==========
SITE_DIR="$(cd "$(dirname "$0")/docs" && pwd)"
REMOTE_USER="root"
REMOTE_HOST="129.204.230.64"
REMOTE_PORT="22"
REMOTE_PATH="/www/wwwroot/129.204.230.64/"
SSH_KEY="$HOME/.secret_info/LoginWithSSH.pem"

# ========== 颜色 ==========
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ========== 检查前置条件 ==========
if [ ! -f "$SSH_KEY" ]; then
    error "SSH密钥不存在: $SSH_KEY"
    exit 1
fi

# 尝试加载 bundle (可能安装在 gem 用户目录)
if ! command -v bundle &> /dev/null; then
    export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
    if ! command -v bundle &> /dev/null; then
        error "未找到 bundle 命令，请先安装 bundler"
        exit 1
    fi
fi

if [ ! -d "$SITE_DIR" ]; then
    error "站点目录不存在: $SITE_DIR"
    exit 1
fi

SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# ========== 1. 构建 ==========
info "🔨 构建静态站点..."
cd "$SITE_DIR"
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
bundle exec jekyll build

BUILD_STATUS=$?
if [ $BUILD_STATUS -ne 0 ]; then
    error "构建失败，请检查错误日志"
    exit $BUILD_STATUS
fi
info "✅ 构建完成"

# ========== 2. 上传 ==========
info "📦 上传到 $REMOTE_HOST:$REMOTE_PATH"
info "   建议: 首次部署前请备份服务器现有文件"

rsync -avz --delete \
    -e "ssh $SSH_OPTS -p $REMOTE_PORT" \
    "$SITE_DIR/_site/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"

RSYNC_STATUS=$?
if [ $RSYNC_STATUS -ne 0 ]; then
    error "上传失败 (rsync exit code: $RSYNC_STATUS)"
    exit $RSYNC_STATUS
fi

# ========== 3. 设置权限 ==========
info "🔧 设置文件权限..."
ssh $SSH_OPTS -p $REMOTE_PORT "$REMOTE_USER@$REMOTE_HOST" \
    "chown -R www:www $REMOTE_PATH && find $REMOTE_PATH -type d -exec chmod 755 {} \; && find $REMOTE_PATH -type f -exec chmod 644 {} \;"

echo ""
info "🎉 部署完成！"
echo "   访问: http://$REMOTE_HOST"
