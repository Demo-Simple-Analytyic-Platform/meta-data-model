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
df = src.abs_sas_url_csv (
    # Input Parameters
    abs_1_csv_nm_account         = "demoasawedev",
    abs_2_csv_nm_secret          = "Yahoo-Blob-SAS-Token",
    abs_3_csv_nm_container       = "yahoo",
    abs_4_csv_ds_folderpath      = "statis_data",
    abs_5_csv_ds_filename        = "stocks.csv",
    abs_6_csv_nm_decode          = "UTF-8",
    abs_7_csv_is_1st_header      = "1",
    abs_8_csv_cd_delimiter_value = ",",
    abs_9_csv_cd_delimter_text   = "\"",
    is_debugging                 = "1"
)