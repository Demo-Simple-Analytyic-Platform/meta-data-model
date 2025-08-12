import sys
# if you don't want type in the folder/file path on runtime.
fp_git_folder = "path-to-your-git-folder"
nm_your_repo  = "name-of-your-repository"

# Set the path to the modules directory
fp_modules    = f"{fp_git_folder}/{nm_your_repo}/4-processing-python"
sys.path.insert(0, fp_modules) 

# Import Modules
from modules import source as src  # type: ignore

# Extract web table
df = src.abs_sas_url_xls (
    # Input Parameters
    abs_1_xls_nm_account           = "demoasawedev",
    abs_2_xls_nm_secret            = "Yahoo-Blob-SAS-Token",
    abs_3_xls_nm_container         = "yahoo",
    abs_4_xls_ds_folderpath        = "transactions",
    abs_5_xls_ds_filename          = "transactions.xlsx",
    abs_6_xls_nm_sheet             = "Transactions",
    abs_7_xls_is_first_header      = "1",
    abs_8_xls_cd_top_left_cell     = "",
    abs_9_xls_cd_bottom_right_cell = "",
    is_debugging                   = "1"
)