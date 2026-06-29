# Text Tag System

## What Are Text Tags?

Text tags are **hashtags embedded in job names** that categorize and filter agents. They make it easy to:
- Group related agents (e.g., all `#content` agents)
- Filter the dashboard view
- Trigger actions on tagged groups
- Search and organize

## How Tags Work

### In Job Names

```
"ContentForge Rollout (Daily Single Post) #content #publishing #daily"
"StockPulse Pre-Market #finance #morning"
"Career Ops - Daily Full Pipeline #career #system"
```

### Parsing Tags

```typescript
// Extract tags from job name
function extractTags(name: string): string[] {
  const tagRegex = /#(\w+(-\w+)*)/g;
  const matches = name.matchAll(tagRegex);
  return Array.from(matches).map(m => m[1]);
}

// Example
extractTags("ContentForge Rollout #content #daily");
// Returns: ["content", "daily"]
```

## Tag Categories

### By Domain

| Tag | Description | Agents |
|-----|-------------|--------|
| `#content` | Content creation & publishing | ContentForge jobs |
| `#finance` | Stock market & investing | StockPulse, StockForge |
| `#career` | Job search & career | Career Ops |
| `#system` | Infrastructure & maintenance | Config sync, backups |
| `#learning` | Education & skill building | DevSecOps |

### By Schedule

| Tag | Description | Agents |
|-----|-------------|--------|
| `#morning` | Runs in morning (6-10 AM) | Morning Intelligence, Daily Priority |
| `#midday` | Runs midday (12-2 PM) | StockPulse Mid-Day |
| `#evening` | Runs evening (6-8 PM) | — |
| `#night` | Runs at night (2 AM) | Micro-System Builder |
| `#daily` | Runs every day | Most jobs |
| `#weekdays` | Runs Mon-Fri | StockPulse jobs |

### By Status

| Tag | Description | Use Case |
|-----|-------------|----------|
| `#active` | Currently enabled | Filter for running jobs |
| `#paused` | Temporarily stopped | Jobs to review |
| `#error` | Last run failed | Jobs needing attention |
| `#healthy` | Last run succeeded | Jobs working well |

### By Priority

| Tag | Description | Agents |
|-----|-------------|--------|
| `#critical` | Must not fail | Config sync |
| `#important` | High value | Content publishing |
| `#experimental` | New or testing | Experiment orchestrator |
| `#background` | Low priority | Cleanup jobs |

## Tag Colors (Dashboard UI)

```typescript
// Tag color mapping
const tagColors: Record<string, { bg: string; text: string }> = {
  content: { bg: 'bg-blue-100', text: 'text-blue-800' },
  finance: { bg: 'bg-green-100', text: 'text-green-800' },
  career: { bg: 'bg-purple-100', text: 'text-purple-800' },
  system: { bg: 'bg-gray-100', text: 'text-gray-800' },
  learning: { bg: 'bg-yellow-100', text: 'text-yellow-800' },
  daily: { bg: 'bg-indigo-100', text: 'text-indigo-800' },
  morning: { bg: 'bg-orange-100', text: 'text-orange-800' },
  night: { bg: 'bg-slate-100', text: 'text-slate-800' },
  critical: { bg: 'bg-red-100', text: 'text-red-800' },
  experimental: { bg: 'bg-pink-100', text: 'text-pink-800' },
};
```

## Tag Filtering in Dashboard

```typescript
// Filter jobs by tag
function filterJobsByTag(jobs: CronJob[], tag: string): CronJob[] {
  return jobs.filter(job => 
    extractTags(job.name).includes(tag)
  );
}

// Filter by multiple tags (AND)
function filterJobsByTags(jobs: CronJob[], tags: string[]): CronJob[] {
  return jobs.filter(job => {
    const jobTags = extractTags(job.name);
    return tags.every(tag => jobTags.includes(tag));
  });
}

// Examples
filterJobsByTag(allJobs, 'content');
// Returns: All ContentForge jobs

filterJobsByTags(allJobs, ['content', 'daily']);
// Returns: Daily content jobs

filterJobsByTags(allJobs, ['finance', 'morning']);
// Returns: Morning finance jobs (StockPulse)
```

## Tag-Based Actions

```typescript
// Run all jobs with a specific tag
async function runTaggedJobs(tag: string) {
  const jobs = filterJobsByTag(await getCronJobs(), tag);
  for (const job of jobs) {
    await runJob(job.job_id);
  }
}

// Pause all experimental jobs
async function pauseExperimentalJobs() {
  const jobs = filterJobsByTag(await getCronJobs(), 'experimental');
  for (const job of jobs) {
    await pauseJob(job.job_id);
  }
}
```

## Current Job Tags (As of 2026-06-28)

| Job Name | Suggested Tags |
|----------|--------------|
| ContentForge Rollout | `#content` `#publishing` `#daily` |
| ContentForge Daily Report | `#content` `#metrics` `#daily` |
| ContentForge Metrics | `#content` `#metrics` `#daily` |
| ContentForge Experiment | `#content` `#experimental` `#daily` |
| ContentForge 14-Day Aggregator | `#content` `#analytics` `#daily` |
| StockPulse Pre-Market | `#finance` `#morning` `#weekdays` |
| StockPulse Mid-Day | `#finance` `#midday` `#weekdays` |
| StockPulse Pre-Close | `#finance` `#evening` `#weekdays` |
| StockPulse Post-Market | `#finance` `#night` `#weekdays` |
| StockForge Daily Picks | `#finance` `#morning` `#weekdays` `#important` |
| Career Ops Daily | `#career` `#system` `#daily` |
| Daily Priority Check | `#system` `#morning` `#daily` |
| Config Sync | `#system` `#critical` `#daily` |
| Morning Intelligence | `#system` `#morning` `#daily` |
| gbrain Update Check | `#system` `#learning` `#daily` |
| DevSecOps Check-in | `#learning` `#daily` |
| Micro-System Builder | `#system` `#experimental` `#night` |

## Adding Tags to Jobs

### Method 1: Rename Job (Hermes CLI)
```bash
hermes cron update <job-id> --name "New Name #tag1 #tag2"
```

### Method 2: Edit Cron Definition
```bash
# Edit job definition file
nano ~/.hermes/cron/jobs/<job-id>.json
# Add tags to "name" field or "tags" array
```

### Method 3: Dashboard UI (Future)
```typescript
// Click tag to add/remove
await updateJobTags(jobId, [...currentTags, 'new-tag']);
```

## Tag Best Practices

1. **Be consistent** — Use same tags across similar jobs
2. **Don't over-tag** — 2-3 tags per job is enough
3. **Use standard tags** — Stick to the categories above
4. **Tag by function** — What the job does, not how it does it
5. **Update tags** — When job purpose changes, update tags

## Tag Search

```typescript
// Search jobs by tag
function searchJobsByTag(jobs: CronJob[], query: string): CronJob[] {
  const lowerQuery = query.toLowerCase();
  return jobs.filter(job => {
    const tags = extractTags(job.name);
    return tags.some(tag => tag.toLowerCase().includes(lowerQuery));
  });
}

// Example: search for "content"
searchJobsByTag(allJobs, 'content');
// Returns: All jobs with #content tag
```
