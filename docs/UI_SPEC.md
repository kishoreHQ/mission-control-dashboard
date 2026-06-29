# UI Specification

## Dashboard Layout

### Overall Structure

```
┌─────────────────────────────────────────────────────────────┐
│  Header (fixed, top)                                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  🎛️ Mission Control    [Connected]    Last refresh:  │   │
│  │                        [🟢]           10:30 AM      │   │
│  └─────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  Sidebar (fixed, left, 240px)    │  Main Content Area       │
│  ┌────────────────────────────┐  │  ┌────────────────────┐  │
│  │  🏠 Overview               │  │  │  [Active Panel]    │  │
│  │  🤖 Agent Fleet            │  │  │                    │  │
│  │  📋 Task Bus               │  │  │                    │  │
│  │  📝 Content Pipeline       │  │  │                    │  │
│  │  💻 System Health          │  │  │                    │  │
│  │  ⚙️ Control Panel          │  │  │                    │  │
│  │  ──────────────────────    │  │  │                    │  │
│  │  🏷️ Tags                   │  │  │                    │  │
│  │    #content (5)           │  │  │                    │  │
│  │    #finance (4)            │  │  │                    │  │
│  │    #system (6)             │  │  │                    │  │
│  │    #morning (3)            │  │  │                    │  │
│  └────────────────────────────┘  │  └────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Panel Specifications

### Panel 1: Agent Fleet Overview

```
┌─────────────────────────────────────────────────────────────┐
│  🤖 Agent Fleet                    [Filter ▼] [Refresh 🔄]   │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ ContentForge │ │ StockPulse   │ │ Career Ops   │       │
│  │ Rollout      │ │ Pre-Market   │ │ Daily        │       │
│  │              │ │              │ │              │       │
│  │ 🟢 Healthy   │ │ 🟢 Healthy   │ │ 🟢 Healthy   │       │
│  │ Last: 10:00  │ │ Last: 02:30  │ │ Last: 02:30  │       │
│  │ Next: 10:00  │ │ Next: 02:30  │ │ Next: 02:30  │       │
│  │ #content     │ │ #finance     │ │ #career      │       │
│  │ #daily       │ │ #morning     │ │ #system      │       │
│  │              │ │ #weekdays    │ │ #daily       │       │
│  │ [Logs] [Run] │ │ [Logs] [Run] │ │ [Logs] [Run] │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ Config Sync  │ │ Morning      │ │ DevSecOps    │       │
│  │              │ │ Intelligence │ │ Check-in     │       │
│  │ 🟢 Healthy   │ │ 🟢 Healthy   │ │ 🟢 Healthy   │       │
│  │ Last: 08:00  │ │ Last: 06:00  │ │ Last: 04:30  │       │
│  │ Next: 08:00  │ │ Next: 06:00  │ │ Next: 04:30  │       │
│  │ #system      │ │ #system      │ │ #learning    │       │
│  │ #critical    │ │ #morning     │ │ #daily       │       │
│  │ #daily       │ │ #daily       │ │              │       │
│  │ [Logs] [Run] │ │ [Logs] [Run] │ │ [Logs] [Run] │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

**Card Design:**
- Border: 1px solid `border`
- Border radius: `radius` (0.5rem)
- Padding: 1rem
- Status indicator: Colored dot (🟢🟡🔴)
- Tags: Small badges with tag colors
- Actions: Small buttons (Logs, Run Now)

### Panel 2: Active Operations

```
┌─────────────────────────────────────────────────────────────┐
│  📋 Active Operations              [Auto-refresh: 30s]        │
├─────────────────────────────────────────────────────────────┤
│  Running Jobs (0)                                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ No jobs currently running                           │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Recent Completions (5)                                     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Job Name          │ Status │ Time    │ Duration    │   │
│  │ ContentForge      │ ✅ OK  │ 10:00   │ 23s         │   │
│  │ Morning Intel     │ ✅ OK  │ 06:01   │ 45s         │   │
│  │ DevSecOps         │ ✅ OK  │ 04:31   │ 2m 12s      │   │
│  │ Career Ops        │ ✅ OK  │ 02:35   │ 5m 30s      │   │
│  │ Config Sync       │ ✅ OK  │ 08:01   │ 12s         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Pending Tasks (0)                                          │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ No pending tasks                                    │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Panel 3: Content Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│  📝 Content Pipeline                                           │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────┐ │
│  │ Queue (3)        │  │ Published (42)   │  │ Metrics     │ │
│  │                  │  │                  │  │             │ │
│  │ • Kubernetes     │  │ • Docker Best    │  │ Today:      │ │
│  │   networking     │  │   Practices      │  │ Posts: 1    │ │
│  │   Score: 8.5     │  │   1.2K views     │  │ Views: 1.2K │ │
│  │                  │  │                  │  │ Likes: 45   │ │
│  │ • CI/CD patterns │  │ • K8s Tips       │  │ Reposts: 12 │ │
│  │   Score: 7.8     │  │   890 views      │  │             │ │
│  │                  │  │                  │  │ 7-Day:      │ │
│  │ • GitOps guide   │  │ • DevOps Trends  │  │ Posts: 7    │ │
│  │   Score: 9.2     │  │   2.1K views     │  │ Views: 8.5K │ │
│  │                  │  │                  │  │             │ │
│  │ [Publish Next]   │  │ [View All]       │  │ [Details]   │ │
│  └──────────────────┘  └──────────────────┘  └─────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Panel 4: System Health

```
┌─────────────────────────────────────────────────────────────┐
│  💻 System Health                                              │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────┐ │
│  │ Disk Usage       │  │ Memory Usage     │  │ Load Avg    │ │
│  │                  │  │                  │  │             │ │
│  │ ████████████░░   │  │ ██████░░░░░░░░   │  │ 0.52 0.48   │ │
│  │ 89% (34G/38G)   │  │ 51% (8.2G/16G)   │  │ 0.42        │ │
│  │ ⚠️ Warning       │  │ ✅ OK            │  │ ✅ OK       │ │
│  │                  │  │                  │  │             │ │
│  └──────────────────┘  └──────────────────┘  └─────────────┘ │
│                                                             │
│  Active Processes (42)                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ PID   │ Name          │ CPU  │ Memory │ Status      │   │
│  │ 1234  │ node          │ 2.3% │ 156MB  │ Running     │   │
│  │ 1235  │ python3       │ 1.1% │ 89MB   │ Running     │   │
│  │ ...   │ ...           │ ...  │ ...    │ ...         │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Panel 5: Control Panel

```
┌─────────────────────────────────────────────────────────────┐
│  ⚙️ Control Panel                                              │
├─────────────────────────────────────────────────────────────┤
│  Quick Actions                                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│  │ 🔄 Refresh   │ │ 📊 Run Report│ │ 🧹 Cleanup   │       │
│  │ All Data     │ │ Now          │ │ Logs         │       │
│  └──────────────┘ └──────────────┘ └──────────────┘       │
│                                                             │
│  Agent Actions                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Select Agent: [ContentForge Rollout ▼]              │   │
│  │                                                     │   │
│  │ [Run Now] [Pause] [Resume] [View Logs] [Edit]       │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Settings                                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Refresh Interval: [30 seconds ▼]                    │   │
│  │ Theme: [Dark ▼]                                   │   │
│  │ Connection: [Tailscale ▼]                         │   │
│  │ VPS IP: [100.64.123.45]                          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Color Scheme

### Light Mode

```css
:root {
  --background: #ffffff;
  --foreground: #0f172a;
  --card: #ffffff;
  --card-border: #e2e8f0;
  --primary: #3b82f6;
  --primary-foreground: #ffffff;
  --success: #22c55e;
  --warning: #f59e0b;
  --error: #ef4444;
  --muted: #64748b;
  --accent: #f1f5f9;
}
```

### Dark Mode (Default)

```css
.dark {
  --background: #0f172a;
  --foreground: #f8fafc;
  --card: #1e293b;
  --card-border: #334155;
  --primary: #60a5fa;
  --primary-foreground: #0f172a;
  --success: #4ade80;
  --warning: #fbbf24;
  --error: #f87171;
  --muted: #94a3b8;
  --accent: #334155;
}
```

## Component Specifications

### Agent Card

```tsx
interface AgentCardProps {
  name: string;
  status: 'healthy' | 'warning' | 'error' | 'running';
  lastRun: Date;
  nextRun: Date;
  tags: string[];
  onViewLogs: () => void;
  onRunNow: () => void;
}

// Size: 280px wide, auto height
// Layout: Flex column
// Border: 1px solid card-border
// Border radius: 0.5rem
// Padding: 1rem
// Gap between cards: 1rem
```

### Status Badge

```tsx
interface StatusBadgeProps {
  status: 'healthy' | 'warning' | 'error' | 'running';
}

// Size: 8px dot + text
// Colors:
//   healthy: bg-green-500, text-green-400
//   warning: bg-yellow-500, text-yellow-400
//   error: bg-red-500, text-red-400
//   running: bg-blue-500, text-blue-400 (with pulse animation)
```

### Tag Badge

```tsx
interface TagBadgeProps {
  tag: string;
}

// Size: Small, inline
// Border radius: 9999px (pill)
// Padding: 0.125rem 0.5rem
// Font size: 0.75rem
// Colors: From tagColors mapping
```

## Responsive Design

### Breakpoints

| Breakpoint | Width | Layout |
|------------|-------|--------|
| Mobile | < 640px | Single column, stacked panels |
| Tablet | 640-1024px | 2-column grid |
| Desktop | > 1024px | 3-column grid, sidebar visible |

### Mobile Adaptations

- Sidebar becomes bottom navigation or hamburger menu
- Agent cards stack vertically
- Tables become cards
- Charts simplify

## Animations

### Status Pulse

```css
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.status-running {
  animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
}
```

### Card Hover

```css
.agent-card {
  transition: transform 0.2s, box-shadow 0.2s;
}

.agent-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}
```

### Data Refresh

```css
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.refresh-icon.spinning {
  animation: spin 1s linear infinite;
}
```

## Icons

Use **Lucide React** (already in shadcn/ui):

| Icon | Usage |
|------|-------|
| `Home` | Overview nav |
| `Bot` | Agent Fleet nav |
| `ClipboardList` | Task Bus nav |
| `FileText` | Content Pipeline nav |
| `Monitor` | System Health nav |
| `Settings` | Control Panel nav |
| `CheckCircle` | Healthy status |
| `AlertTriangle` | Warning status |
| `XCircle` | Error status |
| `Loader` | Running status |
| `RefreshCw` | Refresh button |
| `Play` | Run now button |
| `Pause` | Pause button |
| `Eye` | View logs button |
| `Tag` | Tag icon |
| `Clock` | Time icon |
| `TrendingUp` | Metrics icon |

## Accessibility

- All interactive elements have focus states
- Color is not the only indicator (icons + text)
- ARIA labels for screen readers
- Keyboard navigation support
- Reduced motion support: `@media (prefers-reduced-motion: reduce)`
