# Add the directory containing the file to sys.path
import getpass
import sys
fp_git_folder = input(f"Git-Folderpath  : ")
nm_your_repo  = input(f"Repository Name : ")
fp_modules    = f"{fp_git_folder}/{nm_your_repo}/4-processing-python/modules"
sys.path.insert(0, fp_modules) 

# Import the module
from secrets import add_secret, read_secret, get_current_file_folder

# Use the module
nm_secrets = "Your-Secret"
ds_secrets = getpass.getpass(f"Please enter your Secret: ") # enter secret
add_secret(nm_secrets, ds_secrets)