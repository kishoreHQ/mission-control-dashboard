# Architecture Details

## System Components

### 1. Dashboard (React SPA)
- **Runtime:** Browser (Chrome, Safari, Firefox)
- **Build Tool:** Vite 6
- **Framework:** React 19 + TypeScript 5
- **Styling:** Tailwind CSS v3 + shadcn/ui components
- **State:** React hooks + localStorage (for preferences)
- **Data Fetching:** Custom hooks (SSH, file reads, or API)

### 2. Data Layer

The dashboard needs a **data adapter** that can work in multiple modes:

```typescript
// src/lib/data-adapter.ts
interface DataAdapter {
  getCronJobs(): Promise<CronJob[]>;
  getJobLogs(jobId: string): Promise<string>;
  getSystemHealth(): Promise<SystemHealth>;
  getContentForgeState(): Promise<ContentForgeState>;
  getTaskBus(): Promise<TaskBus>;
}

// Mode A: Local file reads (dashboard on VPS)
class LocalFileAdapter implements DataAdapter {
  async getCronJobs() {
    const output = await exec(`hermes cron list --json`);
    return JSON.parse(output);
  }
}

// Mode B: SSH remote commands (dashboard on local Mac)
class SSHAdapter implements DataAdapter {
  private ssh: NodeSSH;
  async getCronJobs() {
    const output = await this.ssh.execCommand('hermes cron list --json');
    return JSON.parse(output.stdout);
  }
}

// Mode C: REST API (future)
class APIAdapter implements DataAdapter {
  async getCronJobs() {
    const response = await fetch('/api/cron-jobs');
    return response.json();
  }
}
```

### 3. Hermes Integration Points

| Feature | Hermes Command | Output Location |
|---------|---------------|-----------------|
| Cron jobs | `hermes cron list` | CLI output |
| Job logs | `hermes cron log <id>` | `~/.hermes/cron/output/` |
| Job status | `hermes cron status` | CLI output |
| System info | `hermes status` | CLI output |

### 4. Security Model

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Your Browser   │────▶│  Tailscale VPN  │────▶│  VPS (Hermes)   │
│  (localhost:5173)│     │  (WireGuard)    │     │  (localhost)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
       │                        │                        │
       │  HTTPS/WSS            │  Encrypted tunnel      │  Local file access
       │  (if using nginx)     │  (no open ports)       │  (no network)
       │                        │                        │
       └────────────────────────┴────────────────────────┘
                              Secure by default
```

**Key security features:**
- Tailscale: No open ports on VPS firewall
- SSH keys: No passwords
- File permissions: Dashboard reads only, no write access to Hermes config
- No API keys exposed in frontend (all keys stay on VPS)

---

## Data Flow

```
User opens dashboard
    │
    ▼
┌─────────────────┐
│  Dashboard loads │
│  - React mounts  │
│  - Hooks fetch   │
└─────────────────┘
    │
    ├──────────────────────────────────────────┐
    │                                          │
    ▼                                          ▼
┌──────────┐                            ┌──────────┐
│ Local    │                            │ Remote   │
│ Adapter  │                            │ Adapter  │
│ (VPS)    │                            │ (SSH)    │
└──────────┘                            └──────────┘
    │                                          │
    ▼                                          ▼
┌──────────┐                            ┌──────────┐
│ Read     │                            │ SSH exec │
│ files    │                            │ command  │
└──────────┘                            └──────────┘
    │                                          │
    ▼                                          ▼
┌──────────┐                            ┌──────────┐
│ Parse    │                            │ Parse    │
│ JSON     │                            │ JSON     │
└──────────┘                            └──────────┘
    │                                          │
    └──────────────────────────────────────────┘
                    │
                    ▼
            ┌──────────┐
            │  Render  │
            │  UI      │
            └──────────┘
```

---

## Component Hierarchy

```
App
├── Header
│   ├── Title: "Mission Control"
│   ├── Status indicator (connected/disconnected)
│   └── Last refresh time
│
├── Navigation (sidebar or tabs)
│   ├── Fleet Overview
│   ├── Active Operations
│   ├── Content Pipeline
│   ├── System Health
│   └── Settings
│
├── Main Content Area
│   ├── FleetOverview
│   │   ├── AgentCard[] (for each cron job)
│   │   │   ├── Name + Tags
│   │   │   ├── Status badge (ok/error/running)
│   │   │   ├── Last run time
│   │   │   ├── Next run time
│   │   │   └── Actions (view logs, run now)
│   │   └── FilterBar (by tag, status, schedule)
│   │
│   ├── ActiveOperations
│   │   ├── RunningJobsTable
│   │   └── PendingTasksTable
│   │
│   ├── ContentPipeline
│   │   ├── QueuePanel
│   │   ├── PublishedPanel
│   │   └── MetricsPanel
│   │
│   ├── SystemHealth
│   │   ├── DiskUsage
│   │   ├── MemoryUsage
│   │   ├── LoadAverage
│   │   └── ProcessList
│   │
│   └── ControlPanel
│       ├── Run Job Button
│       ├── Stop Job Button
│       ├── View Logs Button
│       └── Refresh Data Button
│
└── Footer
    ├── Version info
    └── Connection status
```

---

## State Management

### Local State (React hooks)
```typescript
// Per-component state
const [jobs, setJobs] = useState<CronJob[]>([]);
const [selectedJob, setSelectedJob] = useState<string | null>(null);
const [filter, setFilter] = useState<string>('all');
```

### Global State (React Context)
```typescript
// Connection context
interface ConnectionContext {
  mode: 'local' | 'tailscale' | 'api';
  status: 'connected' | 'disconnected' | 'error';
  lastRefresh: Date;
}

// Data context
interface DataContext {
  cronJobs: CronJob[];
  systemHealth: SystemHealth;
  contentForge: ContentForgeState;
  refresh: () => Promise<void>;
}
```

### Persistent State (localStorage)
```typescript
// User preferences
interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  defaultView: 'fleet' | 'operations' | 'content' | 'system';
  refreshInterval: number; // seconds
  filters: Record<string, string[]>;
}
```

---

## Performance Considerations

| Concern | Solution |
|---------|----------|
| Large log files | Paginate / stream / tail |
| Frequent refreshes | Configurable interval (default: 30s) |
| SSH connection overhead | Keep connection alive, reuse |
| Many cron jobs | Virtual scrolling for table |
| 3D visualizations | Optional, lazy-loaded |

---

## Error Handling

```typescript
// src/lib/error-handler.ts
class DashboardError extends Error {
  constructor(
    message: string,
    public code: 'CONNECTION' | 'AUTH' | 'DATA' | 'UNKNOWN',
    public retryable: boolean
  ) {
    super(message);
  }
}

// Usage
try {
  const jobs = await dataAdapter.getCronJobs();
} catch (error) {
  if (error instanceof DashboardError && error.retryable) {
    // Show retry button
  } else {
    // Show error message
  }
}
```

---

## Future Enhancements

1. **WebSocket updates** — Real-time job status changes
2. **Mobile app** — React Native or PWA
3. **Alerting** — Push notifications for failures
4. **Multi-VPS** — Monitor multiple Hermes instances
5. **Custom agents** — Add your own agent types
6. **Log search** — Full-text search across job logs
7. **Metrics graphs** — Time-series charts (Recharts)
8. **Dark mode** — Toggle (already supported by shadcn)
