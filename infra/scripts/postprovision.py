#!/usr/bin/env python3
"""Post-provision hook script for Azure Developer CLI.

This script runs after Azure resources are provisioned.
Customize this script for your specific post-provision tasks.
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
    """Main post-provision logic."""
    logger.info("🔄 Starting post-provision hook...")
    
    try:
        # Get environment name
        env_name = os.getenv('AZURE_ENV_NAME', 'unknown')
        log_info(f"Environment: {env_name}")
        
        # Add your post-provision logic here
        # Examples:
        # - Configure newly created resources
        # - Set up RBAC permissions
        # - Initialize databases or storage
        # - Run database migrations
        # - Set up monitoring
        
        log_success("Post-provision hook completed successfully")
        
    except Exception as e:
        log_error(f"Post-provision hook failed: {e}")
        logger.exception("Full traceback:")
        sys.exit(1)


if __name__ == "__main__":
    main()
