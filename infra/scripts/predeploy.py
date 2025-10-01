#!/usr/bin/env python3
"""Pre-deploy hook script for Azure Developer CLI.

This script runs before application deployment.
Customize this script for your specific pre-deploy tasks.
"""

import logging
import os
import sys
from utils import log_info, log_success, log_error

# Configure logging for this script
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def main():
    """Main pre-deploy logic."""
    logger.info("🔄 Starting pre-deploy hook...")
    
    try:
        # Get environment name
        env_name = os.getenv('AZURE_ENV_NAME', 'unknown')
        log_info(f"Environment: {env_name}")
        
        # Add your pre-deploy logic here
        # Examples:
        # - Build application assets
        # - Run unit tests
        # - Package application
        # - Validate deployment prerequisites
        # - Prepare container images
        
        log_success("Pre-deploy hook completed successfully")
        
    except Exception as e:
        log_error(f"Pre-deploy hook failed: {e}")
        logger.exception("Full traceback:")
        sys.exit(1)


if __name__ == "__main__":
    main()
