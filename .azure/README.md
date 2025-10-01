# Azure Developer CLI Configuration Directory

This directory contains environment-specific configuration files.

Each environment (dev, test, prod, etc.) will have its own subdirectory.

## Example structure

```text
.azure/
  dev/
    .env
    config.json
  prod/
    .env
    config.json
```

These files are automatically created when you run `azd env new` or `azd init` and contain environment-specific configuration and secrets.