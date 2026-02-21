#!/bin/bash
# deploy.sh - Twelve Stones: Ephod Quest Deployment Script
# Automates building and exporting for all target platforms

set -e  # Exit on any error

# Configuration
PROJECT_NAME="twelve-stones"
GODOT_PATH="${GODOT_PATH:-godot}"  # Allow override via environment
BUILD_DIR="build"
WEB_DIR="$BUILD_DIR/web"
ANDROID_DIR="$BUILD_DIR/android"
WINDOWS_DIR="$BUILD_DIR/windows"
LINUX_DIR="$BUILD_DIR/linux"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Godot exists
check_godot() {
    if ! command -v "$GODOT_PATH" &> /dev/null; then
        log_error "Godot not found at: $GODOT_PATH"
        log_error "Please install Godot 4.3+ or set GODOT_PATH environment variable"
        log_error "Example: export GODOT_PATH=/path/to/godot"
        exit 1
    fi

    # Check Godot version
    GODOT_VERSION=$("$GODOT_PATH" --version)
    log_info "Using Godot: $GODOT_VERSION"

    if [[ ! "$GODOT_VERSION" =~ ^4\.[3-9] ]]; then
        log_warning "Godot version $GODOT_VERSION detected. Twelve Stones requires 4.3+"
    fi
}

# Create build directories
create_build_dirs() {
    log_info "Creating build directories..."
    mkdir -p "$WEB_DIR" "$ANDROID_DIR" "$WINDOWS_DIR" "$LINUX_DIR"
}

# Export for web
export_web() {
    log_info "Exporting for Web..."
    "$GODOT_PATH" --headless --export-debug "Web" "$WEB_DIR/index.html"
    log_success "Web build completed: $WEB_DIR/index.html"
}

# Export for Android
export_android() {
    log_info "Exporting for Android..."
    "$GODOT_PATH" --headless --export-debug "Android" "$ANDROID_DIR/$PROJECT_NAME.apk"
    log_success "Android build completed: $ANDROID_DIR/$PROJECT_NAME.apk"
}

# Export for Windows
export_windows() {
    log_info "Exporting for Windows..."
    "$GODOT_PATH" --headless --export-debug "Windows Desktop" "$WINDOWS_DIR/$PROJECT_NAME.exe"
    log_success "Windows build completed: $WINDOWS_DIR/$PROJECT_NAME.exe"
}

# Export for Linux
export_linux() {
    log_info "Exporting for Linux..."
    "$GODOT_PATH" --headless --export-debug "Linux/X11" "$LINUX_DIR/$PROJECT_NAME.x86_64"
    log_success "Linux build completed: $LINUX_DIR/$PROJECT_NAME.x86_64"
}

# Run tests (requires web export first)
run_tests() {
    if [ ! -f "$WEB_DIR/index.html" ]; then
        log_error "Web build not found. Run web export first or use --all flag"
        return 1
    fi

    log_info "Running Playwright E2E tests..."
    cd tests
    if command -v npm &> /dev/null; then
        npm test
        log_success "Tests completed"
    else
        log_warning "npm not found. Skipping tests. Install Node.js to run tests."
    fi
    cd ..
}

# Show usage
usage() {
    echo "Twelve Stones Deployment Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all          Export for all platforms and run tests"
    echo "  --web          Export for web only"
    echo "  --android      Export for Android only"
    echo "  --windows      Export for Windows only"
    echo "  --linux        Export for Linux only"
    echo "  --test         Run tests (requires web export)"
    echo "  --clean        Clean build directory"
    echo "  --help         Show this help"
    echo ""
    echo "Environment Variables:"
    echo "  GODOT_PATH     Path to Godot executable (default: 'godot')"
    echo ""
    echo "Examples:"
    echo "  $0 --all                    # Full deployment"
    echo "  GODOT_PATH=./godot $0 --web # Use custom Godot path"
    echo "  $0 --test                   # Run tests only"
}

# Clean build directory
clean() {
    log_info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
    log_success "Build directory cleaned"
}

# Main function
main() {
    case "${1:-}" in
        --all)
            check_godot
            create_build_dirs
            export_web
            export_android
            export_windows
            export_linux
            run_tests
            log_success "Full deployment completed!"
            echo ""
            echo "Build artifacts:"
            echo "  Web:     $WEB_DIR/index.html"
            echo "  Android: $ANDROID_DIR/$PROJECT_NAME.apk"
            echo "  Windows: $WINDOWS_DIR/$PROJECT_NAME.exe"
            echo "  Linux:   $LINUX_DIR/$PROJECT_NAME.x86_64"
            ;;
        --web)
            check_godot
            create_build_dirs
            export_web
            ;;
        --android)
            check_godot
            create_build_dirs
            export_android
            ;;
        --windows)
            check_godot
            create_build_dirs
            export_windows
            ;;
        --linux)
            check_godot
            create_build_dirs
            export_linux
            ;;
        --test)
            run_tests
            ;;
        --clean)
            clean
            ;;
        --help|"")
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            echo ""
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
