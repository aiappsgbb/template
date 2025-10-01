"""Basic utility functions for Azure Developer CLI hook scripts."""

import logging
import os
import subprocess
import sys
from typing import Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

logger = logging.getLogger(__name__)


def get_env_var(name: str, default: Optional[str] = None) -> Optional[str]:
    """Get environment variable with optional default.
    
    Args:
        name: Environment variable name.
        default: Default value if not found.
        
    Returns:
        Environment variable value or default.
    """
    return os.getenv(name, default)


def run_command(command: str, check: bool = True) -> subprocess.CompletedProcess:
    """Run a shell command and return the result.
    
    Args:
        command: Command to run.
        check: Whether to raise exception on non-zero exit code.
        
    Returns:
        CompletedProcess object with result.
    """
    logger.debug(f"Executing command: {command}")
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            check=check
        )
        logger.debug(f"Command completed with exit code: {result.returncode}")
        return result
    except subprocess.CalledProcessError as e:
        logger.error(f"Command failed with exit code {e.returncode}: {e}")
        if check:
            sys.exit(1)
        raise


def log_info(message: str) -> None:
    """Log an informational message.
    
    Args:
        message: Message to log.
    """
    logger.info(f"ℹ️  {message}")


def log_success(message: str) -> None:
    """Log a success message.
    
    Args:
        message: Message to log.
    """
    logger.info(f"✅ {message}")


def log_warning(message: str) -> None:
    """Log a warning message.
    
    Args:
        message: Message to log.
    """
    logger.warning(f"⚠️  {message}")


def log_error(message: str) -> None:
    """Log an error message.
    
    Args:
        message: Message to log.
    """
    logger.error(f"❌ {message}")
