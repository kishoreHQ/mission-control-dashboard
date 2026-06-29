# API Reference (Future)

## Overview

This document describes the REST API that the Mission Control Dashboard can use to communicate with the Hermes agent system.

**Note:** This API is not yet implemented. It represents the target architecture for future development.

## Base URL

```
http://<vps-tailscale-ip>:8080/api/v1
```

## Authentication

All endpoints require an API key in the header:

```
X-API-Key: your-api-key-here
```

## Endpoints

### Cron Jobs

#### List All Jobs

```http
GET /cron-jobs
```

**Response:**
```json
{
  "jobs": [
    {
      "job_id": "766e4a696f4d",
      "name": "ContentForge Rollout",
      "schedule": "0 10 * * *",
      "next_run_at": "2026-06-29T10:00:00Z",
      "last_run_at": "2026-06-28T10:00:22Z",
      "last_status": "ok",
      "enabled": true,
      "state": "scheduled"
    }
  ],
  "total": 19
}
```

#### Get Job Details

```http
GET /cron-jobs/:id
```

#### Run Job Now

```http
POST /cron-jobs/:id/run
```

#### Pause Job

```http
POST /cron-jobs/:id/pause
```

#### Resume Job

```http
POST /cron-jobs/:id/resume
```

#### Get Job Logs

```http
GET /cron-jobs/:id/logs?lines=100
```

### System Health

#### Get System Status

```http
GET /system/health
```

**Response:**
```json
{
  "disk": {
    "total": "38G",
    "used": "34G",
    "available": "4.3G",
    "percent": 89
  },
  "memory": {
    "total": "16G",
    "used": "8.2G",
    "free": "7.8G",
    "percent": 51
  },
  "load_average": [0.52, 0.48, 0.42],
  "uptime": "15 days, 3 hours",
  "active_processes": 42
}
```

### ContentForge

#### Get Content State

```http
GET /contentforge/state
```

**Response:**
```json
{
  "queue": [...],
  "posted": [...],
  "metrics": {
    "today": { "posts": 1, "views": 1200 },
    "seven_day": { "posts": 7, "views": 8500 }
  }
}
```

### Task Bus

#### List Tasks

```http
GET /tasks?status=pending&limit=50
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| status | string | Filter by status: pending, working, completed |
| limit | integer | Max results (default: 50) |
| offset | integer | Pagination offset |

#### Create Task

```http
POST /tasks
```

**Body:**
```json
{
  "to": "hermes-contentforge",
  "type": "draft_tweet",
  "priority": "high",
  "payload": { "topic": "Kubernetes" }
}
```

## Error Responses

All errors follow this format:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Job not found",
    "details": { "job_id": "invalid-id" }
  }
}
```

## Rate Limiting

- 100 requests per minute per API key
- Rate limit headers included in response:
  - `X-RateLimit-Limit: 100`
  - `X-RateLimit-Remaining: 95`
  - `X-RateLimit-Reset: 1625097600`

## WebSocket (Future Real-time Updates)

```javascript
const ws = new WebSocket('ws://<vps-ip>:8080/ws');

ws.onmessage = (event) => {
  const update = JSON.parse(event.data);
  // Handle real-time updates
};
```

## SDK Example

```typescript
class MissionControlAPI {
  private baseUrl: string;
  private apiKey: string;

  constructor(baseUrl: string, apiKey: string) {
    this.baseUrl = baseUrl;
    this.apiKey = apiKey;
  }

  async getCronJobs(): Promise<CronJob[]> {
    const response = await fetch(`${this.baseUrl}/cron-jobs`, {
      headers: { 'X-API-Key': this.apiKey }
    });
    const data = await response.json();
    return data.jobs;
  }

  async runJob(jobId: string): Promise<void> {
    await fetch(`${this.baseUrl}/cron-jobs/${jobId}/run`, {
      method: 'POST',
      headers: { 'X-API-Key': this.apiKey }
    });
  }
}
```
