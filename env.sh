# 設定顏色變數以便輸出彩色訊息
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# 顯示幫助訊息的函式
show_help() {
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  euv init [python_version]"
    echo "  euv install [package_name]"
    echo "  euv uninstall [package_name]"
    echo ""
}

# 執行 init 的函式
run_init() {
    PYTHON_VERSION=$1
    echo -e "${YELLOW}--- Checking for prerequisites... ---${NC}"

    # 檢查 uv 是否安裝
    if ! command -v uv &> /dev/null; then
        echo -e "${MAGENTA}[EUV] 'uv' command not found. Attempting to install...${NC}"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        echo -e "${GREEN}[EUV] uv is already installed.${NC}"
    fi

    # 檢查 Poetry 是否安裝
    if ! command -v poetry &> /dev/null; then
        echo -e "${MAGENTA}[EUV] 'Poetry' command not found. Attempting to install...${NC}"
        curl -sSL https://install.python-poetry.org | python3 -
    else
        echo -e "${GREEN}[EUV] Poetry is already installed.${NC}"
    fi

    echo ""
    echo -e "${CYAN}--- Running EUV Init for Python ${PYTHON_VERSION} ---${NC}"
    poetry init
    uv venv --python "${PYTHON_VERSION}"
    echo -e "${GREEN}--- EUV Init Complete ---${NC}"
}

# 執行 install 的函式
run_install() {
    PACKAGE_NAME=$1
    echo -e "${CYAN}--- Running EUV install: ${PACKAGE_NAME} ---${NC}"
    poetry add "${PACKAGE_NAME}" --lock
    uv pip compile pyproject.toml -o requirements.txt --all-extras
    uv pip sync requirements.txt
    echo -e "${GREEN}--- EUV install Complete ---${NC}"
}

# 執行 uninstall 的函式
run_uninstall() {
    PACKAGE_NAME=$1
    echo -e "${CYAN}--- Running EUV uninstall: ${PACKAGE_NAME} ---${NC}"
    poetry remove "${PACKAGE_NAME}" --lock
    uv pip compile pyproject.toml -o requirements.txt --all-extras
    uv pip sync requirements.txt
    echo -e "${GREEN}--- EUV uninstall Complete ---${NC}"
}

# --- 主程式邏輯 ---
# 檢查是否提供了至少一個參數
if [ -z "$1" ]; then
    show_help
    exit 1
fi

# 使用 case 語句判斷第一個參數
case "$1" in
    init)
        run_init "$2"
        ;;
    install)
        run_install "$2"
        ;;
    uninstall)
        run_uninstall "$2"
        ;;
    *)
        echo -e "Error: Unknown command '$1'"
        show_help
        exit 1
        ;;
esac
