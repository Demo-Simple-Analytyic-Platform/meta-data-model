# Add the directory containing the file to sys.path
import sys
# if you don't want type in the folder/file path on runtime.
fp_git_folder = "path/to/your/git/folder"
nm_your_repo  = "name_of_your_repo"

# Set the path to the modules directory
fp_modules    = f"{fp_git_folder}/{nm_your_repo}/4-processing-python"
sys.path.insert(0, fp_modules) 

# Import Custom Modules
import modules.credentials as crd # type: ignore
import modules.run         as run # type: ignore
import modules.sql         as sql # type: ignore

# Set Debugging to "1" => true
is_debugging = "1"

# Assumtions: stuff a overarching procedure shoudl extract, but for our example we will hardcode it
id_model          = "<id_model>" # was id_model was updated by the initialization
nm_target_scehme  = '<nm_target_schema>'
nm_target_table   = '<nm_target_table>'    

# Extraction of metadata for the desired model + dataset
run.data_pipeline(id_model, nm_target_scehme, nm_target_table, is_debugging)

# Extract dataset from SQL database and display the first 10 rows in markdown format for table
df = sql.query(crd.target_db(), f"SELECT TOP 10 * FROM {nm_target_scehme}.{nm_target_table}")
df.to_csv('test-asnd-validate.csv', index=False)
print(df.head().to_markdown())
