import subprocess
import re
from typing import List
from tqdm import tqdm

def get_available_versions() -> List[str]:
    """Get the list of all available Solidity versions."""
    try:
        # Run the command to get available versions
        result = subprocess.run(['solc-select', 'install'], 
                              capture_output=True, text=True, check=True)
        
        # Extract version numbers from the output
        versions = re.findall(r'\d+\.\d+\.\d+', result.stdout)
        return versions
    except subprocess.CalledProcessError as e:
        print(f"Failed to get available versions: {e.stderr}")
        return []
    except FileNotFoundError:
        print("Error: solc-select is not installed or not in PATH")
        return []

def install_version(version: str) -> bool:
    """Install a single Solidity version."""
    try:
        subprocess.run(['solc-select', 'install', version], 
                      check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except subprocess.CalledProcessError as e:
        print(f"\nFailed to install version {version}: {e.stderr.decode().strip()}")
        return False

def main():
    # Check whether solc-select is installed
    try:
        subprocess.run(['solc-select', 'versions'], 
                      check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("Please install solc-select first:")
        print("pip install solc-select")
        return
    
    # Get all available versions
    versions = get_available_versions()
    if not versions:
        print("No available versions to install")
        return
    
    print(f"Preparing to install {len(versions)} Solidity versions...")
    
    # Use tqdm to display a progress bar
    successful_installs = 0
    with tqdm(versions, desc="Installation progress", unit="version") as pbar:
        for version in pbar:
            pbar.set_postfix_str(f"Current: {version}")
            if install_version(version):
                successful_installs += 1
    
    print("\nInstallation complete!")
    print(f"Successfully installed {successful_installs}/{len(versions)} versions")
    print("\nUse the following command to switch versions:")
    print("solc-select use <version>")

if __name__ == "__main__":
    main()
