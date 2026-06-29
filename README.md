# Mission Control Dashboard for Hermes Agent Army

> **Status:** v0.1 — Architecture & Setup Guide  
> **Stack:** React 19 + Vite + TypeScript + Tailwind CSS v3 + shadcn/ui  
> **Purpose:** Central command interface for monitoring and managing the Hermes agent fleet

---

## What This Is

The Mission Control Dashboard is a **single-page web application** that connects to your Hermes agent infrastructure to show:

- **Agent Fleet Status** — All 19+ cron jobs, their health, last run, next run
- **Task Bus** — Pending, working, and completed tasks across agents
- **Content Pipeline** — ContentForge queue, published posts, metrics
- **System Health** — Disk, memory, active processes, logs
- **Control Actions** — Start/stop agents, trigger jobs, view logs

It runs as a **standalone web app** on your local machine (or VPS) and communicates with Hermes via:
1. **Tailscale** (for secure access to your VPS from anywhere)
2. **Direct file reads** (when running on the same machine as Hermes)
3. **API endpoints** (future: Hermes gateway REST API)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    YOUR LOCAL MACHINE                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Mission Control Dashboard (React SPA)          │   │
│  │              Runs on: localhost:5173                  │   │
│  │                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │   │
│  │  │  Agent Fleet │  │  Task Bus    │  │  System  │  │   │
│  │  │  Status      │  │  Monitor     │  │  Health  │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                  │
│                           │ Tailscale SSH / Local File Access │
│                           ▼                                  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      VPS (Google Cloud)                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Hermes Agent Runtime                    │   │
│  │         /root/.hermes/ (config, skills, cron)        │   │
│  │                                                      │   │
│  │  Cron Jobs (19 active):                             │   │
│  │  • ContentForge (5 jobs) — publishing pipeline        │   │
│  │  • StockPulse (4 jobs) — market monitoring          │   │
│  │  • Career Ops (1 job) — job search automation       │   │
│  │  • Daily Priority (1 job) — morning check-in          │   │
│  │  • Config Sync (1 job) — backup to GitHub           │   │
│  │  • gbrain (1 job) — repo monitoring                   │   │
│  │  • Micro-System Builder (2 jobs) — nightly builds   │   │
│  │  • DevSecOps (1 job) — learning companion           │   │
│  │  • StockForge (1 job) — stock picks                 │   │
│  │  • Morning Intelligence (1 job) — daily briefing    │   │
│  │                                                      │   │
│  │  Data Sources:                                       │   │
│  │  • ~/.hermes/cron/ (job definitions)                 │   │
│  │  • ~/.hermes/cron/output/ (job logs)                 │   │
│  │  • /tmp/contentforge/ (content state)                 │   │
│  │  • /srv/agent-bus/ (task bus)                         │   │
│  │  • system: df, ps, journalctl                         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## How It Works End-to-End

### 1. Data Collection (On VPS)

The dashboard needs data from the VPS. There are **three modes**:

| Mode | How | Use Case |
|------|-----|----------|
| **Local** | Dashboard runs directly on VPS at `localhost:5173` | Primary — fastest, no network |
| **Tailscale** | Dashboard runs on your Mac, connects via Tailscale SSH to VPS | Remote access from anywhere |
| **API** | Dashboard calls REST API endpoints on VPS (future) | Secure, language-agnostic |

### 2. Data Sources

The dashboard reads from these files/commands on the VPS:

```bash
# Cron job status
hermes cron list --json

# Job logs
ls -la ~/.hermes/cron/output/
cat ~/.hermes/cron/output/<job-id>.log

# ContentForge state
cat /tmp/contentforge/ideas.json
cat /tmp/contentforge/posted.json
cat /tmp/contentforge/queue.json

# System health
df -h
free -h
ps aux

# Task bus (if implemented)
ls /srv/agent-bus/inbox/
ls /srv/agent-bus/outbox/
```

### 3. Dashboard UI Flow

```
User opens dashboard → Dashboard loads data → Shows panels:
  ├─ Fleet Overview (all agents, status, health)
  ├─ Active Operations (running jobs, pending tasks)
  ├─ Content Pipeline (queue, published, metrics)
  ├─ System Health (disk, memory, processes)
  └─ Control Panel (actions: run job, view logs, stop/start)
```

### 4. Text Tag System

The dashboard uses **text tags** to identify and filter agents:

| Tag | Meaning | Example |
|-----|---------|---------|
| `#content` | ContentForge agents | `#content-publisher`, `#content-metrics` |
| `#finance` | Stock/market agents | `#stockpulse`, `#stockforge` |
| `#career` | Job search agents | `#career-ops` |
| `#system` | Infrastructure agents | `#config-sync`, `#backup` |
| `#learning` | Education agents | `#devsecops` |
| `#nightly` | Runs at night | `#micro-system-builder` |
| `#morning` | Runs in morning | `#morning-intelligence`, `#daily-priority` |

Tags are stored in:
- Job `name` field (e.g., "ContentForge Rollout `#content`")
- Job metadata (future: `tags` array in cron definition)
- Dashboard filter sidebar

---

## Tailscale Setup (Critical for Remote Access)

Your VPS is already on Tailscale. Here's how it connects:

### VPS Side (Already Done)
```bash
# Tailscale is installed and running
tailscale status
# Should show: connected, with your VPS IP (e.g., 100.x.x.x)
```

### Your Local Machine Side
```bash
# Install Tailscale
# Mac: brew install tailscale
# Then: tailscale up

# Connect to VPS via Tailscale
ssh root@<tailscale-ip-of-vps>
# Or use Tailscale SSH:
tailscale ssh root@<vps-hostname>
```

### Dashboard → VPS Connection
When running dashboard locally, it needs to read VPS files. Options:

**Option A: SSH + Remote Commands (Recommended)**
```typescript
// Dashboard makes SSH calls to VPS
const result = await ssh.execCommand('hermes cron list --json');
```

**Option B: Sync Data to Local**
```bash
# Cron job on VPS syncs data to local machine
rsync -avz ~/.hermes/cron/output/ user@local-machine:~/mission-control-data/
```

**Option C: Run Dashboard ON VPS (Simplest)**
```bash
# On VPS:
cd /root/mission-control-dashboard
npm run dev -- --host 0.0.0.0
# Access via: http://<tailscale-ip>:5173
```

---

## Required Settings & Configuration

### 1. VPS Environment (Where Hermes Runs)

These are already set up on your VPS (`/root/.hermes/`):

```yaml
# ~/.hermes/config.yaml (key sections)
providers:
  # API keys for LLM providers (DO NOT COMMIT)
  anthropic:
    api_key: "sk-ant-..."  # From env var or secret manager
  openai:
    api_key: "sk-..."
  
# Cron jobs are defined in: ~/.hermes/cron/jobs/
# Job outputs go to: ~/.hermes/cron/output/
```

### 2. Dashboard Environment (New)

Create `.env` in dashboard repo:

```bash
# .env
# How dashboard connects to VPS
VITE_CONNECTION_MODE=tailscale  # Options: local, tailscale, api

# Tailscale / SSH settings (for remote mode)
VITE_VPS_TAILSCALE_IP=100.x.x.x
VITE_VPS_HOSTNAME=vps-hermes
VITE_VPS_USER=root
# VITE_VPS_SSH_KEY=~/.ssh/id_ed25519  # Path to SSH key

# Or if running dashboard ON VPS:
VITE_DATA_PATH=/root/.hermes/cron/output
```

### 3. Local Machine (Your Mac)

You need these installed:

```bash
# 1. Node.js 20+
node --version  # Should be v20+

# 2. npm 10+
npm --version

# 3. Tailscale (for remote access)
tailscale status

# 4. Git
git --version

# 5. SSH key (for VPS access)
ssh-keygen -t ed25519 -C "your-email"
ssh-copy-id root@<vps-tailscale-ip>
```

### 4. Hermes CLI (Optional, for local testing)

If you want to run Hermes commands locally (not on VPS):

```bash
# Install Hermes Agent
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash

# This gives you `hermes` CLI
hermes --version
```

**Note:** You don't need Hermes locally to run the dashboard. The dashboard only needs to **read data** from the VPS, not run Hermes itself.

---

## File Structure

```
mission-control-repo/
├── README.md                 # This file
├── docs/
│   ├── ARCHITECTURE.md       # System architecture details
│   ├── DATA_SOURCES.md       # What data is read and how
│   ├── TAILSCALE_SETUP.md    # Tailscale configuration guide
│   ├── TAG_SYSTEM.md         # How text tags work
│   ├── UI_SPEC.md            # Dashboard UI specification
│   └── API_REFERENCE.md      # Future API endpoints
├── config/
│   ├── .env.example          # Environment variables template
│   ├── tailscale.example     # Tailscale ACL example
│   └── nginx.example         # Nginx reverse proxy config
├── scripts/
│   ├── setup.sh              # One-command setup script
│   ├── sync-data.sh          # Sync data from VPS to local
│   └── install-hermes.sh     # Optional: install Hermes locally
├── assets/
│   ├── architecture-diagram.png
│   └── ui-mockup.png         # Placeholder for your UI design
├── examples/
│   ├── agent-card-example.tsx
│   ├── job-status-example.json
│   └── dashboard-layout.tsx
└── dashboard/                # The actual React app (you build this)
    ├── package.json
    ├── vite.config.ts
    ├── tsconfig.json
    ├── tailwind.config.js
    ├── src/
    │   ├── main.tsx
    │   ├── App.tsx
    │   ├── index.css
    │   ├── components/
    │   │   ├── AgentFleet.tsx
    │   │   ├── TaskBus.tsx
    │   │   ├── ContentPipeline.tsx
    │   │   ├── SystemHealth.tsx
    │   │   └── ControlPanel.tsx
    │   ├── hooks/
    │   │   ├── useCronJobs.ts
    │   │   ├── useSystemHealth.ts
    │   │   └── useContentForge.ts
    │   ├── lib/
    │   │   ├── utils.ts
    │   │   └── ssh.ts          # SSH connection helper
    │   └── types/
    │       └── index.ts
    └── .env
```

---

## How to Build This (Your Part)

### Step 1: Clone This Repo
```bash
git clone https://github.com/kishoreHQ/mission-control-dashboard.git
cd mission-control-dashboard
```

### Step 2: Install Dependencies
```bash
cd dashboard
npm install
```

### Step 3: Configure Environment
```bash
cp ../config/.env.example .env
# Edit .env with your VPS details
```

### Step 4: Design the UI
```bash
npm run dev
# Open http://localhost:5173
# Design your layout, components, color scheme
# The data hooks are stubbed — replace with real data fetching
```

### Step 5: Implement Data Fetching

**Option A: Local file reads (if running on VPS)**
```typescript
// src/hooks/useCronJobs.ts
export async function fetchCronJobs() {
  const response = await fetch('/api/cron-jobs'); // Proxy to local file
  return response.json();
}
```

**Option B: SSH remote commands (if running locally)**
```typescript
// src/lib/ssh.ts
import { NodeSSH } from 'node-ssh';

export async function execOnVPS(command: string) {
  const ssh = new NodeSSH();
  await ssh.connect({
    host: import.meta.env.VITE_VPS_TAILSCALE_IP,
    username: 'root',
    privateKeyPath: '~/.ssh/id_ed25519',
  });
  const result = await ssh.execCommand(command);
  await ssh.dispose();
  return result.stdout;
}
```

### Step 6: Build & Deploy
```bash
npm run build
# Deploy dist/ to VPS or static hosting
```

---

## Data Schema Reference

### Cron Job Status
```json
{
  "job_id": "766e4a696f4d",
  "name": "ContentForge Rollout (Daily Single Post) #content",
  "schedule": "0 10 * * *",
  "last_run_at": "2026-06-28T10:00:22Z",
  "last_status": "ok",
  "next_run_at": "2026-06-29T10:00:00Z",
  "enabled": true,
  "tags": ["content", "publishing", "daily"]
}
```

### ContentForge State
```json
{
  "queue": [{ "id": "1", "topic": "Kubernetes", "status": "pending" }],
  "posted": [{ "id": "42", "url": "https://x.com/...", "posted_at": "..." }],
  "metrics": { "impressions": 1200, "likes": 45 }
}
```

### System Health
```json
{
  "disk": { "total": "38G", "used": "34G", "available": "4.3G" },
  "memory": { "total": "16G", "used": "8.2G", "free": "7.8G" },
  "load_average": [0.5, 0.3, 0.2],
  "active_processes": 42
}
```

---

## Workflow: How Changes Flow

```
You (local Mac)
  │
  ├─ Design UI in Figma / Cursor / VS Code
  ├─ Edit React components in dashboard/src/
  ├─ Commit & push to GitHub
  │
  ▼
GitHub repo: kishoreHQ/mission-control-dashboard
  │
  ▼
Hermes (on VPS, or me reading your changes)
  │
  ├─ Pull latest changes
  ├─ Run npm install
  ├─ Build: npm run build
  ├─ Serve: npm run preview (or nginx)
  │
  ▼
Dashboard live at: http://<vps-tailscale-ip>:5173
  │
  ▼
You access via Tailscale from anywhere
```

---

## What You Need to Provide

1. **UI Design** — How you want it to look (Figma, sketch, or description)
2. **Color Scheme** — Dark mode? Brand colors?
3. **Layout Preference** — Sidebar? Cards? Table? Grid?
4. **Priority Features** — Which panels matter most?
5. **VPS Details** — Tailscale IP, SSH key path (for remote mode)

---

## What I Will Do When You Finish

1. Clone your repo
2. Install dependencies
3. Configure environment (Tailscale IP, SSH keys)
4. Build and run on VPS
5. Verify all data sources connect
6. Expose via Tailscale for your access
7. Document any issues

---

## Quick Start Commands

```bash
# Clone repo
git clone https://github.com/kishoreHQ/mission-control-dashboard.git

# Setup everything
./scripts/setup.sh

# Or manually:
cd dashboard
npm install
cp ../config/.env.example .env
# Edit .env
npm run dev
```

---

## Support & Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't connect to VPS | Check Tailscale status: `tailscale status` |
| SSH fails | Verify SSH key: `ssh -i ~/.ssh/id_ed25519 root@<ip>` |
| Data not loading | Check VPS file paths exist |
| Build fails | Ensure Node 20+: `node --version` |
| CORS errors | Use Vite proxy or run dashboard on VPS |

---

## Next Steps

1. **You:** Design UI, push to repo
2. **You:** Tag me when ready
3. **Me:** Pull, install, verify, deploy
4. **Together:** Iterate based on usage

---

*Built for the Hermes Agent Army.  
Mission Control: eyes on everything, hands on nothing.*
