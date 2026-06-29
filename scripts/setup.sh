#!/bin/bash
# Mission Control Dashboard - One-Command Setup
# 
# Usage: ./setup.sh [local|vps|both]
#   local - Setup for local development (Mac)
#   vps   - Setup for VPS deployment
#   both  - Setup both (default)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DASHBOARD_DIR="$REPO_ROOT/dashboard"
MODE="${1:-both}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[SETUP]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[SETUP]${NC} $*"; }
log_error() { echo -e "${RED}[SETUP]${NC} $*"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $*"; }

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is not installed. Please install it first."
        return 1
    fi
    log_info "$1 is installed"
    return 0
}

setup_local() {
    log_step "Setting up local development environment..."
    
    # Check prerequisites
    check_command node || exit 1
    check_command npm || exit 1
    check_command git || exit 1
    
    # Check Node version
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 20 ]; then
        log_error "Node.js 20+ required. Found: $(node --version)"
        exit 1
    fi
    
    # Install dashboard dependencies
    if [ -d "$DASHBOARD_DIR" ]; then
        log_info "Installing dashboard dependencies..."
        cd "$DASHBOARD_DIR"
        npm install
    else
        log_warn "Dashboard directory not found at $DASHBOARD_DIR"
        log_info "Please create the dashboard app first:"
        log_info "  cd $REPO_ROOT"
        log_info "  npm create vite@latest dashboard -- --template react-ts"
    fi
    
    # Copy environment template
    if [ ! -f "$DASHBOARD_DIR/.env" ]; then
        log_info "Creating .env from template..."
        cp "$REPO_ROOT/config/.env.example" "$DASHBOARD_DIR/.env"
        log_warn "Please edit $DASHBOARD_DIR/.env with your VPS details"
    fi
    
    # Check Tailscale
    if command -v tailscale &> /dev/null; then
        log_info "Tailscale is installed"
        tailscale status 2>/dev/null || log_warn "Tailscale not connected. Run: tailscale up"
    else
        log_warn "Tailscale not installed. Install from: https://tailscale.com/download"
    fi
    
    log_info "Local setup complete!"
    log_info "Next steps:"
    log_info "  1. Edit $DASHBOARD_DIR/.env"
    log_info "  2. cd $DASHBOARD_DIR && npm run dev"
    log_info "  3. Open http://localhost:5173"
}

setup_vps() {
    log_step "Setting up VPS environment..."
    
    # Check if running on VPS (check for Hermes)
    if [ ! -d "$HOME/.hermes" ]; then
        log_warn "Hermes not found at $HOME/.hermes"
        log_info "This script should be run on the VPS where Hermes is installed"
    fi
    
    # Check prerequisites
    check_command node || exit 1
    check_command npm || exit 1
    
    # Install dashboard dependencies
    if [ -d "$DASHBOARD_DIR" ]; then
        log_info "Installing dashboard dependencies..."
        cd "$DASHBOARD_DIR"
        npm install
        
        # Build for production
        log_info "Building dashboard..."
        npm run build
        
        # Create systemd service (optional)
        log_info "Creating systemd service..."
        sudo tee /etc/systemd/system/mission-control.service > /dev/null <<EOF
[Unit]
Description=Mission Control Dashboard
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$DASHBOARD_DIR
ExecStart=/usr/bin/npm run preview -- --host 0.0.0.0 --port 5173
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
        
        log_info "Systemd service created. To start:"
        log_info "  sudo systemctl enable mission-control"
        log_info "  sudo systemctl start mission-control"
    else
        log_warn "Dashboard directory not found"
    fi
    
    # Check Tailscale
    if command -v tailscale &> /dev/null; then
        log_info "Tailscale is installed"
        VPS_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
        log_info "VPS Tailscale IP: $VPS_IP"
    else
        log_warn "Tailscale not installed"
    fi
    
    log_info "VPS setup complete!"
}

setup_data_sync() {
    log_step "Setting up data sync from VPS to local..."
    
    # Create sync script
    cat > "$REPO_ROOT/scripts/sync-data.sh" <<'EOF'
#!/bin/bash
# Sync data from VPS to local for offline dashboard usage

VPS_IP="${VPS_IP:-100.64.123.45}"
VPS_USER="${VPS_USER:-root}"
LOCAL_DATA_DIR="${LOCAL_DATA_DIR:-$HOME/mission-control-data}"

mkdir -p "$LOCAL_DATA_DIR"

# Sync cron job outputs
rsync -avz "$VPS_USER@$VPS_IP:/root/.hermes/cron/output/" "$LOCAL_DATA_DIR/cron-output/"

# Sync ContentForge data
rsync -avz "$VPS_USER@$VPS_IP:/tmp/contentforge/" "$LOCAL_DATA_DIR/contentforge/"

echo "Data synced to $LOCAL_DATA_DIR"
EOF
    chmod +x "$REPO_ROOT/scripts/sync-data.sh"
    
    log_info "Data sync script created at $REPO_ROOT/scripts/sync-data.sh"
    log_info "Edit it with your VPS IP, then run:"
    log_info "  ./scripts/sync-data.sh"
}

# Main
log_info "Mission Control Dashboard Setup"
log_info "Mode: $MODE"
log_info "Repository: $REPO_ROOT"

case "$MODE" in
    local)
        setup_local
        ;;
    vps)
        setup_vps
        ;;
    both)
        setup_local
        setup_data_sync
        log_info ""
        log_info "To setup VPS side, run this script on the VPS:"
        log_info "  ./scripts/setup.sh vps"
        ;;
    *)
        log_error "Unknown mode: $MODE"
        echo "Usage: ./setup.sh [local|vps|both]"
        exit 1
        ;;
esac

log_info ""
log_info "Setup complete! 🎉"
log_info ""
log_info "Next steps:"
log_info "  1. Design your UI (see docs/UI_SPEC.md)"
log_info "  2. Implement components in dashboard/src/"
log_info "  3. Configure .env with your VPS details"
log_info "  4. Run: npm run dev"
log_info ""
log_info "Documentation:"
log_info "  - Architecture: docs/ARCHITECTURE.md"
log_info "  - Data Sources: docs/DATA_SOURCES.md"
log_info "  - Tailscale: docs/TAILSCALE_SETUP.md"
log_info "  - Tags: docs/TAG_SYSTEM.md"
log_info "  - UI Spec: docs/UI_SPEC.md"
