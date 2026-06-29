# Data Sources Guide

## What Data the Dashboard Reads

### 1. Cron Jobs (Agent Fleet)

**Source:** Hermes CLI output
**Command:** `hermes cron list --json`

**Example output:**
```json
[
  {
    "job_id": "766e4a696f4d",
    "name": "ContentForge Rollout (Daily Single Post)",
    "schedule": "0 10 * * *",
    "next_run_at": "2026-06-29T10:00:00+00:00",
    "last_run_at": "2026-06-28T10:00:22.526821+00:00",
    "last_status": "ok",
    "enabled": true,
    "state": "scheduled"
  }
]
```

**Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `job_id` | string | Unique identifier |
| `name` | string | Human-readable name (may include tags like `#content`) |
| `schedule` | string | Cron expression |
| `next_run_at` | ISO date | When it will run next |
| `last_run_at` | ISO date | When it last ran |
| `last_status` | string | `ok`, `error`, `running`, `skipped` |
| `enabled` | boolean | Whether job is active |
| `state` | string | `scheduled`, `paused`, `running` |

---

### 2. Job Logs

**Source:** File system
**Path:** `~/.hermes/cron/output/<job-id>.log`

**Example:**
```
[2026-06-28T10:00:22] INFO: Starting ContentForge Rollout
[2026-06-28T10:00:23] INFO: Checking eligibility...
[2026-06-28T10:00:24] WARN: No content qualified for publishing
[2026-06-28T10:00:24] INFO: Skip event recorded
[2026-06-28T10:00:25] INFO: Job completed successfully
```

---

### 3. ContentForge State

**Source:** JSON files
**Paths:**
- `/tmp/contentforge/ideas.json` — Content ideas pool
- `/tmp/contentforge/posted.json` — Published content
- `/tmp/contentforge/queue.json` — Pending queue

**Example ideas.json:**
```json
[
  {
    "id": "idea-001",
    "topic": "Kubernetes networking",
    "category": "devops",
    "quality_score": 8.5,
    "status": "ready",
    "created_at": "2026-06-27T14:00:00Z"
  }
]
```

**Example posted.json:**
```json
[
  {
    "id": "post-042",
    "url": "https://x.com/unplugged_kk/status/...",
    "topic": "Docker best practices",
    "posted_at": "2026-06-28T10:05:00Z",
    "metrics": {
      "impressions": 1200,
      "likes": 45,
      "reposts": 12,
      "replies": 3
    }
  }
]
```

---

### 4. System Health

**Source:** Linux system commands

**Disk usage:**
```bash
df -h /
# Filesystem      Size  Used Avail Use%
# /dev/root        38G   34G  4.3G  89%
```

**Memory usage:**
```bash
free -h
#               total   used   free
# Mem:           16G    8.2G   7.8G
# Swap:          2G     0.5G   1.5G
```

**Load average:**
```bash
uptime
# load average: 0.52, 0.48, 0.42
```

**Active processes:**
```bash
ps aux | wc -l
# 42
```

---

### 5. Task Bus (Future)

**Source:** File system (if implemented)
**Path:** `/srv/agent-bus/`

**Structure:**
```
/srv/agent-bus/
├── inbox/      # Pending tasks
├── working/    # In-progress tasks
├── outbox/     # Completed tasks
└── archive/    # Old tasks
```

**Task file format:**
```json
{
  "task_id": "uuid",
  "from": "orchestrator",
  "to": "hermes-contentforge",
  "type": "draft_tweet",
  "priority": "high",
  "payload": { "topic": "Kubernetes", "style": "translation_pattern" },
  "created_at": "2026-06-28T10:00:00Z",
  "status": "pending"
}
```

---

## How to Read This Data

### Method 1: Direct File Access (Dashboard on VPS)

```typescript
// Read local files
const fs = await import('fs/promises');

async function getCronJobs() {
  const output = await fs.readFile(
    '/root/.hermes/cron/output/latest.json', 
    'utf-8'
  );
  return JSON.parse(output);
}
```

### Method 2: SSH Remote Commands (Dashboard on Local Mac)

```typescript
import { NodeSSH } from 'node-ssh';

const ssh = new NodeSSH();

async function getCronJobs() {
  await ssh.connect({
    host: '100.x.x.x', // Tailscale IP
    username: 'root',
    privateKeyPath: '~/.ssh/id_ed25519',
  });
  
  const result = await ssh.execCommand('hermes cron list --json');
  await ssh.dispose();
  
  return JSON.parse(result.stdout);
}
```

### Method 3: REST API (Future Implementation)

```typescript
// VPS runs a small HTTP server that exposes endpoints
const response = await fetch('http://100.x.x.x:8080/api/cron-jobs');
return response.json();
```

---

## Data Refresh Strategy

| Data Type | Refresh Interval | Strategy |
|-----------|-----------------|----------|
| Cron jobs | 30 seconds | Poll |
| Job logs | On demand | Fetch when viewing |
| System health | 10 seconds | Poll |
| ContentForge | 60 seconds | Poll |
| Task bus | 30 seconds | Poll or WebSocket |

---

## Caching

```typescript
// Simple in-memory cache with TTL
class DataCache {
  private cache = new Map<string, { data: any; expires: number }>();
  
  get(key: string) {
    const entry = this.cache.get(key);
    if (entry && entry.expires > Date.now()) {
      return entry.data;
    }
    return null;
  }
  
  set(key: string, data: any, ttlMs: number) {
    this.cache.set(key, { data, expires: Date.now() + ttlMs });
  }
}
```
