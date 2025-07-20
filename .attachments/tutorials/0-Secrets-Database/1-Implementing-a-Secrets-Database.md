Back to [Readme](../../../README.md#tutorials-secrets-database)

# 1. Implementing Secrets Database

When Implementing a Data Platform, you will likely encounter all sorts of credentials infromation that is needed to access the desired datasets. To combine this with the idea to use as few technologies/tools as possible, we can us a SQL Database to stored the `secrets`. However, if you are building a large dataplatform and in the cloud, one to the native secret manager should be used. Deppening on the platform these are some options [Azure Key Vault](https://azure.microsoft.com/nl-nl/products/key-vault), [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), [Keeper](https://www.keepersecurity.com/) or [HashiCorp Vault](https://www.hashicorp.com/en/products/vault).

For now or `Demo` / `Tutorial` we use our simple `secrets`-database.

<h4>Languages:</h4>

![T-SQL](https://img.shields.io/badge/TSQL-purple?style=for-the-badge&labelColor=black&logo=TSQL&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-darkgreen?style=for-the-badge&labelColor=black&logo=powershell&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&labelColor=black&logo=python&logoColor=white)

<h4>Technologies:</h4>

![SQL-Server](https://img.shields.io/badge/SQL_Server-blue?style=for-the-badge&labelColor=black&logo=T-SQL&logoColor=white)

<h4>Tooling:</h4>

![SSMS](https://img.shields.io/badge/SSMS-SQL%20Tools-darkblue?style=for-the-badge&labelColor=black&logo=microsoftsqlserver&logoColor=white)
![VS Code](https://img.shields.io/badge/VS%20Code-Editor-007ACC?style=for-the-badge&labelColor=black&logo=visualstudiocode&logoColor=white)

<h4>Assumtions:</h4>

1. You have used the ***powershell***-scripts to clone the templates
2. Copied to solution/projects/code to (your) `meta-data-model`
3. Copied to solution/projects/code to (your) `meta-data-defintions` your first `model`. 
4. Deployed both the `meta-data-model` and `meta-data-defintions`.
5. otherwise execute the 2 ***powershell***-scripts form the [README](../../../README.md)

<!-- TOC END -->

---

### Table of Content

- [Getting Started](#getting-started)
  - [Pre-requirements](#pre-requirements)
  - [Installation](#installation)

- [Adding, Reading and Removing Secrets](#adding-reading-and-removing-secrets)
  - [Adding a Secret](#adding-a-secret)
  - [Reading a Secret](#reading-a-secret)
  - [Remove a Secret](#remove-a-secret)

---

## Getting Started

### Pre-requirements

1. Access to SQL server to create a database with the SQL Authentication Access, If you have right to create a database, create a database named `secrets` (if you don\`t have the rights, have them created).
    1. add non-personal-account with rights to insert, update, select and delete records in from dbo.secrets.
    2. add non-personal-account with right to create tables in dbo-schema.

2. make sure you can execute python on you machine.
3. make sure you have access to the secrets database. (server, database, username and password)

### Installation

The `meta-data-model`-repository has a `visual studio`-solution with a `project` named `Secrets-Database` stored in the `..\meta-data-model\meta-data-model\0-secrets`-folder. This a relative simple project and contrains only 1 table named `Secrets` win the `dbo`-schema. To deploy this database the following script should be executed, otherwise you could start up `Visual Studio` and publish the project manually.

#### PowerShell-script

Step 1 is to copy the full path to [1-Implementing-a-Secrets-Database.ps1](1-Implementing-a-Secrets-Database.ps1) on **`your` local** repository.<br>
Step 2 open command prompt.<br>
Step 3 execute the command below.<br>
````cmd
powershell -ExecutionPolicy Bypass -File "<copy-paste-the-full-path-to-this-script.ps1>"
````

The script will prompt the user for database access credentials.

#### Validate in SSMS

To validate if the `Secrets`-database has been deploy lets open SSMS (SQL Server Management Studio or some simular tooling). Connect to the databasek (using the same credentials or some personal account). You should seen something like the image below.

![validation-check](../../images/secrets-database/validation-check.png)
##### image: *Validation check if `secrets`-database was deployed.*


## Adding, Reading and Removing Secrets

Now that we have a `secrets`-database we would like to place some `secrets` in it. This can be done with the python code from the `meta-data-definitions`-repository, the code is also copied into `your`-model and could be found in the local path of `..\<the-name-of-your-model>\4-processing-python\modules\secrets.py`, in the markdown file `secrets.md` functional docuementation can be found. However for this tutorial the function `add_secret`, `read_secret` and `del_secret` are of relavants. The `read_secret` is used in de `data_pipeline`- and `export_documentation`-procedures.

### Adding a Secret

This function we will use to store the `AccessKey` for the `Azure Storage Account` where we will "host" our static web service to make documentation accessible.

##### Example: Adding AccessKey for Azure Storage Account
````python

# Add the directory containing the file to sys.path
import getpass
import sys
fp_git_folder = input(f"Git-Folderpath  : ")
nm_your_repo  = input(f"Repository Name : ")
fp_modules    = f"{fp_git_folder}}/{nm_your_repo}/4-processing-python/modules"
sys.path.insert(0, fp_modules) 

# Import the module
from secrets import add_secret, read_secret, get_current_file_folder

# Use the module
nm_secrets = "Your-Secret"
ds_secrets = getpass.getpass(f"Please enter your Secret: ") # enter secret
add_secret(nm_secrets, ds_secrets)

````

To validate the if the `Secret` was inserted into the SQL Server Database, please logon and execute the SQL statement below.

````SQL
SELECT * 
FROM dbo.secrets 
WHERE nm_secret = 'Your-Secret'
````

The result should be something like this
| nm_secret |	ds_secret |
|---|---|
| Your-Secret | gAAAAABoe9p_0N7WnD7BH-8eIOxb8BlgmeggBaNZXn8Pf2VRBy949E5Lpq82Zru_UlpK65X0Kzg3Y7CzGH2qNMWVGhStelm34A== | 

> Note the `ds_secret`-value is hashed, and can be cracked with suffient processing power or the password stored in the encryption_key-file. The encryption_key is also hashed and only accessible bij de user how created the file. By removing the file the python secret-function will prompt the user to provide the password, so make it available for other users.

### Reading a Secret

Storing a secret somewhere is usefull, however there must be away te extract the secret again so it can be used to gain access to a resource. In the same python module `secrets` the function  `read_secret` performance this task. In the exampl code below .

````python

# Add the directory containing the file to sys.path
import getpass
import sys
fp_git_folder = input(f"Git-Folderpath  : ")
nm_your_repo  = input(f"Repository Name : ")
fp_modules    = f"{fp_git_folder}}/{nm_your_repo}/4-processing-python/modules"
sys.path.insert(0, fp_modules) 

# Import the module
from secrets import add_secret, read_secret, get_current_file_folder

# Validate add `Accesskey`
nm_secrets = "Your-Secret"
tx_secrets_extract = read_secret(nm_secrets)
ds_secrets = getpass.getpass(f"Please enter your Secret: ")
if (tx_secrets_extract == ds_secrets):
    print(f"Stored Accesskey is Valid!")
else:
    print(f"Stored Accesskey is Invalid!")  

````

### Remove a Secret

It would be good practice to clean up secret that are nolonger in use, there for the function `remove_secret` was created. with the code below the previous `secret` can be removed.
