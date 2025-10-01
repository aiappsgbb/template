#!/usr/bin/env python3
"""Post-deploy hook script for Azure Developer CLI.

This script runs after application deployment.
Customize this script for your specific post-deploy tasks.
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
    """Main post-deploy logic."""
    logger.info("🔄 Starting post-deploy hook...")
    
    try:
        # Get environment name
        env_name = os.getenv('AZURE_ENV_NAME', 'unknown')
        log_info(f"Environment: {env_name}")
        
        # Add your post-deploy logic here
        # Examples:
        # - Run smoke tests
        # - Warm up applications
        # - Send deployment notifications
        # - Update external monitoring
        # - Configure CDN or DNS
        
        log_success("Post-deploy hook completed successfully")
        
    except Exception as e:
        log_error(f"Post-deploy hook failed: {e}")
        logger.exception("Full traceback:")
        sys.exit(1)


if __name__ == "__main__":
    main()
