#!/usr/bin/env python3
"""Pre-provision hook script for Azure Developer CLI.

This script runs before Azure resources are provisioned.
Customize this script for your specific pre-provision tasks.
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
    """Main pre-provision logic."""
    logger.info("🔄 Starting pre-provision hook...")
    
    try:
        # Get environment name
        env_name = os.getenv('AZURE_ENV_NAME', 'unknown')
        log_info(f"Environment: {env_name}")
        
        # Add your pre-provision logic here
        # Examples:
        # - Validate required environment variables
        # - Check prerequisites
        # - Prepare configuration files
        # - Set up external dependencies
        
        log_success("Pre-provision hook completed successfully")
        
    except Exception as e:
        log_error(f"Pre-provision hook failed: {e}")
        logger.exception("Full traceback:")
        sys.exit(1)


if __name__ == "__main__":
    main()
