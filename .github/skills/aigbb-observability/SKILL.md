---
name: aigbb-observability
description: "OpenTelemetry and Application Insights observability patterns for Azure Container Apps. Cross-language instrumentation for Python (FastAPI, Gradio, Streamlit), TypeScript (Express, React), and .NET (ASP.NET Core). Covers tracing, structured logging, metrics, Azure Monitor exporter, health check endpoints, and telemetry configuration. Use when setting up monitoring, adding Application Insights, configuring OpenTelemetry, implementing health checks, or setting up structured logging. Triggers on OpenTelemetry, Application Insights, tracing, logging, metrics, health check, Azure Monitor, observability, telemetry, structured logging, log level, Winston, Serilog, Python logging."
---

# Observability & Telemetry Patterns

Production-ready observability for Azure Container Apps using OpenTelemetry and Application Insights. Every application in this template includes structured logging, distributed tracing, and health checks.

> **Community skills**: For additional monitoring skills, see the [microsoft/skills](https://github.com/microsoft/skills) community repository.

---

## Core Requirements

Every application MUST have:

1. **Structured logging** — JSON-formatted, never `print()` / `console.log()`
2. **Health check endpoint** — `GET /health` returning 200 OK
3. **OpenTelemetry tracing** — Distributed traces exported to Application Insights
4. **Configuration via environment** — `APPLICATION_INSIGHTS_CONNECTION_STRING` and `LOG_LEVEL`

---

## 1. Python — FastAPI / Gunicorn

### Dependencies (pyproject.toml)

```toml
dependencies = [
    "opentelemetry-api>=1.27.0,<2.0.0",
    "opentelemetry-sdk>=1.27.0,<2.0.0",
    "opentelemetry-instrumentation-fastapi>=0.48.0,<0.49.0",
    "opentelemetry-instrumentation-httpx>=0.48.0,<0.49.0",
    "azure-monitor-opentelemetry-exporter>=1.0.0,<2.0.0",
]
```

### Tracing Setup (utils/tracing.py)

```python
import logging
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.resources import Resource
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from azure.monitor.opentelemetry.exporter import AzureMonitorTraceExporter

logger = logging.getLogger(__name__)


def setup_tracing(
    service_name: str,
    service_version: str = "1.0.0",
    connection_string: str | None = None,
) -> None:
    """Initialize OpenTelemetry tracing with Azure Monitor export."""
    resource = Resource.create({
        "service.name": service_name,
        "service.version": service_version,
    })

    provider = TracerProvider(resource=resource)

    if connection_string:
        exporter = AzureMonitorTraceExporter(
            connection_string=connection_string
        )
        provider.add_span_processor(BatchSpanProcessor(exporter))
        logger.info("Azure Monitor tracing enabled")
    else:
        logger.warning("No APPLICATION_INSIGHTS_CONNECTION_STRING — tracing to console only")

    trace.set_tracer_provider(provider)

    # Auto-instrument frameworks
    FastAPIInstrumentor.instrument()
    HTTPXClientInstrumentor.instrument()
```

### Structured Logging (utils/logging_config.py)

```python
import logging
import json
import sys
from datetime import datetime, timezone


class JsonFormatter(logging.Formatter):
    """JSON-formatted log output for production environments."""

    def format(self, record: logging.LogRecord) -> str:
        log_data = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        if record.exc_info and record.exc_info[0] is not None:
            log_data["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_data)


def setup_logging(log_level: str = "INFO") -> None:
    """Configure structured logging for the application."""
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter())

    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, log_level.upper(), logging.INFO))
    root_logger.handlers = [handler]

    # Quiet noisy libraries
    logging.getLogger("azure").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
```

### Health Check (main.py)

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
async def health_check():
    """Health check endpoint for container orchestration."""
    return {"status": "healthy", "service": "my-app"}
```

### Application Startup (main.py)

```python
import logging
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from utils.tracing import setup_tracing
from utils.logging_config import setup_logging

@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging(os.getenv("LOG_LEVEL", "INFO"))
    setup_tracing(
        service_name="my-app",
        connection_string=os.getenv("APPLICATION_INSIGHTS_CONNECTION_STRING"),
    )
    logger = logging.getLogger(__name__)
    logger.info("Application started")
    yield
    logger.info("Application shutting down")

app = FastAPI(lifespan=lifespan)
```

---

## 2. Python — Gradio

Gradio applications use the same tracing/logging modules. Key difference: Gradio has its own server, so instrument with a custom middleware.

```python
import gradio as gr
import logging
from utils.logging_config import setup_logging
from utils.tracing import setup_tracing

setup_logging(os.getenv("LOG_LEVEL", "INFO"))
setup_tracing(
    service_name="my-gradio-app",
    connection_string=os.getenv("APPLICATION_INSIGHTS_CONNECTION_STRING"),
)

logger = logging.getLogger(__name__)

demo = gr.Blocks()
with demo:
    gr.Markdown("# My App")
    # ... components ...

if __name__ == "__main__":
    logger.info("Starting Gradio application")
    demo.launch(
        server_name="0.0.0.0",
        server_port=int(os.getenv("GRADIO_SERVER_PORT", "80")),
    )
```

---

## 3. Python — Streamlit

Streamlit runs its own web server. Configure logging early in the entry point.

```python
# streamlit_app.py
import streamlit as st
import logging
import os
from utils.logging_config import setup_logging

setup_logging(os.getenv("LOG_LEVEL", "INFO"))
logger = logging.getLogger(__name__)

st.set_page_config(page_title="My App", layout="wide")

# Health check: Streamlit exposes /_stcore/health automatically
logger.info("Streamlit application loaded")
```

**Streamlit health check**: Built-in at `/_stcore/health`. No custom endpoint needed.

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/_stcore/health || exit 1
```

---

## 4. TypeScript — Express / Node.js

### Dependencies (package.json)

```json
{
  "dependencies": {
    "@azure/monitor-opentelemetry": "^1.7.0",
    "@opentelemetry/api": "^1.9.0",
    "@opentelemetry/sdk-node": "^0.54.0",
    "@opentelemetry/instrumentation-express": "^0.42.0",
    "winston": "^3.14.0"
  }
}
```

### Tracing Setup (utils/tracing.ts)

```typescript
import { useAzureMonitor, AzureMonitorOpenTelemetryOptions } from "@azure/monitor-opentelemetry";

export function setupTracing(connectionString?: string): void {
  if (!connectionString) {
    console.warn("No APPLICATION_INSIGHTS_CONNECTION_STRING — tracing disabled");
    return;
  }

  const options: AzureMonitorOpenTelemetryOptions = {
    azureMonitorExporterOptions: { connectionString },
    instrumentationOptions: {
      http: { enabled: true },
    },
  };

  useAzureMonitor(options);
}
```

### Structured Logging (utils/logger.ts)

```typescript
import winston from "winston";

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL?.toLowerCase() || "info",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json(),
  ),
  transports: [new winston.transports.Console()],
});

// Suppress verbose library logs
logger.on("error", () => {});

export default logger;
```

### Health Check (routes/health.ts)

```typescript
import { Router, Request, Response } from "express";

const router = Router();

router.get("/health", (_req: Request, res: Response) => {
  res.json({ status: "healthy", service: "my-node-app" });
});

export default router;
```

---

## 5. TypeScript — React (Client-side)

### Dependencies (package.json)

```json
{
  "dependencies": {
    "@microsoft/applicationinsights-react-js": "^17.3.0",
    "@microsoft/applicationinsights-web": "^3.3.0"
  }
}
```

### Telemetry Service (services/telemetry.ts)

```typescript
import { ApplicationInsights } from "@microsoft/applicationinsights-web";
import { ReactPlugin } from "@microsoft/applicationinsights-react-js";

const reactPlugin = new ReactPlugin();
let appInsights: ApplicationInsights | null = null;

export function initializeTelemetry(connectionString: string): void {
  if (!connectionString || appInsights) return;

  appInsights = new ApplicationInsights({
    config: {
      connectionString,
      extensions: [reactPlugin],
      enableAutoRouteTracking: true,
      enableCorsCorrelation: true,
    },
  });

  appInsights.loadAppInsights();
}

export function trackEvent(name: string, properties?: Record<string, string>): void {
  appInsights?.trackEvent({ name }, properties);
}

export function trackException(error: Error): void {
  appInsights?.trackException({ exception: error });
}

export { reactPlugin };
```

### Structured Logger (utils/logger.ts)

```typescript
type LogLevel = "debug" | "info" | "warn" | "error";

const LOG_LEVELS: Record<LogLevel, number> = { debug: 0, info: 1, warn: 2, error: 3 };
const currentLevel = (import.meta.env.VITE_LOG_LEVEL?.toLowerCase() || "info") as LogLevel;

function shouldLog(level: LogLevel): boolean {
  return LOG_LEVELS[level] >= LOG_LEVELS[currentLevel];
}

export const logger = {
  debug: (msg: string, data?: unknown) => shouldLog("debug") && console.debug(JSON.stringify({ level: "DEBUG", msg, data, ts: new Date().toISOString() })),
  info:  (msg: string, data?: unknown) => shouldLog("info")  && console.info(JSON.stringify({ level: "INFO", msg, data, ts: new Date().toISOString() })),
  warn:  (msg: string, data?: unknown) => shouldLog("warn")  && console.warn(JSON.stringify({ level: "WARN", msg, data, ts: new Date().toISOString() })),
  error: (msg: string, data?: unknown) => shouldLog("error") && console.error(JSON.stringify({ level: "ERROR", msg, data, ts: new Date().toISOString() })),
};
```

---

## 6. .NET — ASP.NET Core

### Dependencies (.csproj)

```xml
<PackageReference Include="Azure.Monitor.OpenTelemetry.AspNetCore" Version="1.2.0" />
<PackageReference Include="Serilog.AspNetCore" Version="8.0.0" />
<PackageReference Include="Serilog.Sinks.Console" Version="6.0.0" />
```

### Program.cs Setup

```csharp
using Serilog;
using Azure.Monitor.OpenTelemetry.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Structured logging with Serilog
builder.Host.UseSerilog((context, configuration) =>
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .WriteTo.Console(outputTemplate:
            "{Timestamp:yyyy-MM-ddTHH:mm:ss.fffZ} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
);

// OpenTelemetry with Azure Monitor
builder.Services.AddOpenTelemetry()
    .UseAzureMonitor();

// Health checks
builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapHealthChecks("/health");
app.MapControllers();
app.Run();
```

---

## 7. Bicep — Application Insights Resource

```bicep
module monitoring 'core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    name: '${abbrs.insightsComponents}${environmentName}'
    location: location
    tags: tags
    logAnalyticsWorkspaceName: '${abbrs.operationalInsightsWorkspaces}${environmentName}'
  }
}

// Output for application consumption
output APPLICATION_INSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
```

### Container App Environment Variables

```bicep
environmentVariables: [
  {
    name: 'APPLICATION_INSIGHTS_CONNECTION_STRING'
    value: monitoring.outputs.applicationInsightsConnectionString
  }
  {
    name: 'LOG_LEVEL'
    value: 'INFO'
  }
]
```

---

## 8. Dockerfile Health Checks

### Python (FastAPI)

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import httpx; httpx.get('http://localhost:80/health').raise_for_status()"
```

### Node.js

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node -e "fetch('http://localhost:80/health').then(r => r.ok ? process.exit(0) : process.exit(1))"
```

### .NET

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1
```

### Streamlit

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/_stcore/health || exit 1
```

---

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| `print("Debug: value =", x)` | `logger.debug("value=%s", x)` |
| `console.log("error", err)` | `logger.error("message", { error: err })` |
| Hard-coded connection string | `os.getenv("APPLICATION_INSIGHTS_CONNECTION_STRING")` |
| No health endpoint | `GET /health` returning JSON status |
| Verbose framework logs in prod | Set library loggers to `WARNING` |

---

## References

- [Azure Monitor OpenTelemetry](https://learn.microsoft.com/azure/azure-monitor/app/opentelemetry-enable)
- [Application Insights for Python](https://learn.microsoft.com/azure/azure-monitor/app/opentelemetry-configuration?tabs=python)
- [Application Insights for Node.js](https://learn.microsoft.com/azure/azure-monitor/app/nodejs)
- [Application Insights for .NET](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
