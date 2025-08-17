# Meta-Data-Model

**Languages:**

![T-SQL](https://img.shields.io/badge/TSQL-purple?style=for-the-badge&labelColor=black&logo=TSQL&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-darkgreen?style=for-the-badge&labelColor=black&logo=powershell&logoColor=white)
![VBA](https://img.shields.io/badge/Microsoft%20VBA-lightgreen?style=for-the-badge&labelColor=black&logo=microsoftaccess&logoColor=white)
![Python](https://img.shields.io/badge/Python-Programming-3776AB?style=for-the-badge&labelColor=black&logo=python&logoColor=white)
![Markdown](https://img.shields.io/badge/Markdown-000000?style=for-the-badge&labelColor=black&logo=markdown&logoColor=white)
![HTML](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&labelColor=black&logo=html5&logoColor=white)

**Technologies**

![SQL-Server](https://img.shields.io/badge/SQL_Server-blue?style=for-the-badge&labelColor=black&logo=T-SQL&logoColor=white)
![Access](https://img.shields.io/badge/Microsoft%20Access-red?style=for-the-badge&labelColor=black&logo=microsoftaccess&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&labelColor=black&logo=git&logoColor=white)

**Useful Tooling**

![SSMS](https://img.shields.io/badge/SSMS-SQL%20Tools-darkblue?style=for-the-badge&labelColor=black&logo=microsoftsqlserver&logoColor=white)
![VS Code](https://img.shields.io/badge/VS%20Code-Editor-007ACC?style=for-the-badge&labelColor=black&logo=visualstudiocode&logoColor=white)
![Github Desktop](https://img.shields.io/badge/GitHub%20Desktop-Git%20Client-24292E?style=for-the-badge&labelColor=black&logo=github&logoColor=white)
![Visual Studio](https://img.shields.io/badge/Visual%20Studio-IDE-5C2D91?style=for-the-badge&labelColor=black&281001logo=visualstudio&logoColor=white)

***Table of Content***

- [Meta-Data-Model](#meta-data-model)
  - [Overview](#overview)
  - [Getting Started](#getting-started)
    - [Pre-requirements](#pre-requirements)
    - [Installation](#installation)
      - [Installing the ***Meta-Data-Model*** (deployment and processing logic)](#installing-the-meta-data-model-deployment-and-processing-logic)
      - [Installing the ***Meta-Data-Definitions*** for Model](#installing-the-meta-data-definitions-for-model)
        - [1. Step-by-Step Instructions](#1-step-by-step-instructions)
        - [2. Initialize the Repository](#2-initialize-the-repository)
        - [3. Provide User Input](#3-provide-user-input)
          - [PowerShell Script](#powershell-script)
  - [Tutorials](#tutorials)
    - [Assumtions (no need to have jedi-master skills)](#assumtions-no-need-to-have-jedi-master-skills)
    - [Tutorials: Secrets Database](#tutorials-secrets-database)
      - [1. Implementing Secrets Database](#1-implementing-secrets-database)
    - [Tutorials: Ingestions](#tutorials-ingestions)
      - [1. Ingestion of ***Stock Trade Infromation*** (webtable from Yahoo)](#1-ingestion-of-stock-trade-infromation-webtable-from-yahoo)
      - [2. Ingestion of ***Currency Exchange Rares*** (webtable from Yahoo)](#2-ingestion-of-currency-exchange-rares-webtable-from-yahoo)
      - [3. Ingestion of ***List of Currencies*** (Webtable from Wikipedia)](#3-ingestion-of-list-of-currencies-webtable-from-wikipedia)
      - [4. Ingestion of ***Transactions of Trade Account*** (Azure Blob Storage - Excel)](#4-ingestion-of-transactions-of-trade-account-azure-blob-storage---excel)
      - [5. Ingestion of **List of Shares (Stocks)** (Azure Blob Storage - CSV)](#5-ingestion-of-list-of-shares-stocks-azure-blob-storage---csv)
    - [Tutorials: Transformations](#tutorials-transformations)
      - [1. Transformation ***Union of Stock Trade Information***](#1-transformation-union-of-stock-trade-information)
      - [2. Transformation ***Exchange Rates on EOM***](#2-transformation-exchange-rates-on-eom)
      - [3. Transformation ***Amounts Traded on EOM (Converted to EUR)***](#3-transformation-amounts-traded-on-eom-converted-to-eur)
      - [4. Transformation ***Recieved Devidends on EOM (Converted to EUR)***](#4-transformation-recieved-devidends-on-eom-converted-to-eur)
      - [5. Transformation ***Performance of Shares in EUR***](#5-transformation-performance-of-shares-in-eur)
    - [Tutorials: Updating Software](#tutorials-updating-software)
      - [1. Updating the Meta-Data-Model](#1-updating-the-meta-data-model)
      - [2. Updating the Frontend Tooling](#2-updating-the-frontend-tooling)

---

## Overview

This SQL Server-based solution forms the foundation of the **Meta-Data-Model**, designed to streamline deployment and data processing through automation. By handling the technical complexities behind the scenes, it enables Data Engineers to focus on delivering value with and for the business. 

> ***Note:*** currently it only works on Window OS, for most of the solution is based on Microsoft technology. However the idea is you can also build simular logic / programming on any other SQL oriented database.

At its core, the solution provides:

- A clear and structured **Meta-Data Model** to describe datasets and register parameters for accessing external sources.
- The ability to reference other models
- SQL-based transformations using `SELECT` queries, making logic transparent and easy to maintain.
- Standardized historization for both **Ingestion** and **Transformation** processes.
- A **Model**-driven organization of datasets to maintain clarity and control.
- A clean separation between metadata, deployment, and processing logic, ensuring scalability and maintainability.
- Minimal use of seprated technologies, limiting the need for integration of verious tooling/technologies.
- example code for python data pipeline call.

With minimal technology dependencies, this solution is easy to implement and works **out-of-the-box** on both **on-premises** and **cloud-based** SQL Server environments. Included Python scripts and procedures offer a solid starting point to get up and running quickly.

## Getting Started

Before diving into the process, it's essential to ensure that all necessary [pre-requirements](#pre-requirements) are fulfilled and the required development software is available. Once these steps are completed, you’ll be ready to proceed with the [installation](#installation). This guide will conclude with a concise [tutorials](#tutorials), where we will set up a dataset to ingest the *Euro-to-USD* exchange rates for the year and add a transformation that extracts the last exchange rate of each month.

It works in Conjunction with "***Meta-Data-Def***"-repository which should hold the meta-data-definitions for model (project). This repository only holds "***Meta-Data-Model***".<br>
The repository for the "***Meta-Data-Def***" can be found [here on git hub](https://github.com/Demo-Simple-Analytyic-Platform/meta-data-def).

### Pre-requirements

As state before the framework has strived to limit the required technologies, we can`t do completely without them. The following software should be installed.

1. Git ([git for window](https://gitforwindows.org/))
2. Visual Studio Code ([Download Visual Studio Code](https://code.visualstudio.com/Download))
3. Visual Studio (Community, Professional or Enterprise) ([Download Visual Studion](https://visualstudio.microsoft.com/downloads/), ensure "SQL Server Data Tools" is installed!)
4. Python ([Download Python](https://www.python.org/getit/))
5. SQL Server Management Studio ([Installeer SQL Server Management Studio](https://www.microsoft.com/sql-server/sql-server-downloads))
6. Microsoft Office, in particular Access ([Runtime Only](https://support.microsoft.com/en-us/office/download-and-install-microsoft-365-access-runtime-185c5a32-8ba9-491e-ac76-91cbe3ea09c9))
7. PowerShell (should run on windows)
8. Database Access via SQL User (This PowerShell-script is based on this, but can be changed to other types of access)
9. `remote` git repository for ***your*** `meta-data-model` and `meta-data-definition` of ***your*** `model`. 
Now all these are installed or were already installed, the *Installation* of the Frameword can start.

### Installation

The Installation consists of number of steps most can be automated with PowerShell, for clarity and understandig they are listed below. 

> The folwing steps are performed for `Mete-Data-Model`-part:
> <br> 2. Create a folder structure: for example `C:\Git\` with subfolder `template`.
> <br> 3. Clone this meta-data-model repository to the `\git\template\`
> <br> 4. Clone `your` repo for the `Meta-Data-Model` to `\git\`-folder, to make if locally available, initially this should be completely empty.
> <br> 5. Copy past everything from the template to local version of your `meta-data-model`-repository.
> <br> 6. Updating PublishProfile for `Database`.
> <br> 7. Update `Project` with utilized Database version.
> <br> 8. Build your `Meta-Data-Model` (dacpac).
> <br> 9. Publish `Meta-Data-Model` to database.

> The folwing steps are performed for `Mete-Data-Def`-part:
> <br> 1. Create a folder structure: C:\Git\ with subfolder `template`.
> <br> 2. Clone this meta-data-model repository to the `\git\template\`-folder.
> <br> 3. Clone `your` repo for the `Meta-Data-Definitions` to `\git\`-folder.
> <br> 4. Copy past everything from the template to local version of your `meta-data-model`-repository.
> <br> 5. Open Microsoft Office Access Application named `ms-access-frontend.accdb` and initialize repository.
> <br> 6. Updating PublishProfiel for `Database`.
> <br> 7. Update `Project` with utilized Database version.
> <br> 8. Build your `Meta-Data-Definitions` (dacpac).
> <br> 9. Publish `Meta-Data-Model` to database.

At the start it was mentioned that the scalability is maintain be separation to *deployment and processing logic* from the *metadata* of the *Datasets*. Thus the *Installation* also containts two parts. The first part is the *deployment and processing logic* this is containt in the repository [meta-data-model](https://github.com/Demo-Simple-Analytyic-Platform/meta-data-model) and the *metadata* of the *Datasets* in the second part this is found in the repository [meta-data-def](https://github.com/Demo-Simple-Analytyic-Platform/meta-data-def) and serves as template.
The Install


#### Installing the ***Meta-Data-Model*** (deployment and processing logic)

To use this repository, it is beste you create new repositories under your own control.

Note that the `meta-data-model`-part can be used as-is. However, since you will not have control over future updates, it is recommended to create your own copy. You can then use the provided update script to apply updates at your convenience.

The `meta-data-model` contains all database schemas, tables, views, functions, and procedures required for both *Deployment* and *data Processing logic*.

<h4>PowerShell Script: </h4><br>

````PowerShell
#
# Save this script as "inital-setup-meta-data-model.ps1" in 
# local folder (not in any git-folder) # and execute with
# command `powershell -ExecutionPolicy Bypass -File "inital-setup-meta-data-model.ps1"`
# fron cmd-line window.
#

# Suppress warning
$WarningPreference = "SilentlyContinue"

function ConvertTo-PlainText($secure) {
    # Convert a SecureString to plain text
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)   
}

if ($true) { Write-Output "# 0. Setting local user specific variables.";

  # The script will need the local folder path to where the `Git`-repository are stored.
  $fp_fldr_git = Read-Host "Please provide folderpath to location of local git repositories (for example `c:\git`)"
  # if you don`t want to type this every time you run the script, you can replace the above line with the following:
  # $fp_fldr_git = "C:\Git"

  # The script will need the URL to your git repository for the `Meta-Data-Model` so if can be cloned to the local git-folder.
  $ur_your_mdm = Read-Host "Please provide the URL to `your` git repository so it can be cloned (for example `https://github.com/Demo-Simple-Analytyic-Platform/meta-mdm-example.git`)" 
  # if you don`t want to type this every time you run the script, you can replace the above line with the following:
  # $ur_your_mdm = "https://github.com/Demo-Simple-Analytyic-Platform/meta-mdm-example.git"
  $nm_your_mdm = $ur_your_mdm.Split("/")[-1] -replace "\.git$", "" # Extraction of "Own" meta-data-model repository name.
  $fp_your_mdm = "$fp_fldr_git\$nm_your_mdm"                       # path to (local) meta-data-model

  # Folderpaths for `Template` "meta-data-model".
  $fp_temp_fld = "$fp_fldr_git\template"         # path to template-folde
  $fp_temp_mdm = "$fp_temp_fld\meta-data-model"  # path to (template) meta-data-model
  $ur_temp_mdm = "https://github.com/Demo-Simple-Analytyic-Platform/meta-data-model.git"

  # Show the user what will be done, and how to use the script.
  Write-Output "fp_fldr_git: $fp_fldr_git"
  Write-Output "ur_your_mdm: $ur_your_mdm"
  Write-Output "nm_your_mdm: $nm_your_mdm"
  Write-Output "fp_your_mdm: $fp_your_mdm"
  Write-Output "fp_temp_fld: $fp_temp_fld"
  Write-Output "fp_temp_mdm: $fp_temp_mdm"
  Write-Output "ur_temp_mdm: $ur_temp_mdm"

  # Check in the `Model` (name of the Repository) is max. 16 characters long.
  if ($nm_your_mdm.Length -gt 16) {
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Write-Output "!!!                                           !!!"
    Write-Output "!!!  Maximum length of `Repository`-name is 16  !!!"
    Write-Output "!!!                                           !!!"
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
  }

}

if ($true) { Write-Output "# 1. Create a folder structure: for example `C:\Git\` with subfolder `template`."; 

  if (-Not (Test-Path -Path $fp_fldr_git)) { New-Item -Path $fp_fldr_git -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_your_mdm)) { New-Item -Path $fp_your_mdm -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_temp_fld)) { New-Item -Path $fp_temp_fld -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_temp_mdm)) { New-Item -Path $fp_temp_mdm -ItemType Directory -Force }


}

if ($true) { Write-Output "# 2. Clone this meta-data-model repository to the `\git\template\`-folder. remember, this repo is publicly accessiable and `readonly` for all but the `owners`.";

  git clone $ur_temp_mdm $fp_temp_mdm 2>$null


}

if ($true) { Write-Output "# 3. Clone `your` repo for the `Meta-Data-Model` to `\git\`-folder, to make if locally aviable, initially this should be completely empty.";
  
    git clone $ur_your_mdm $fp_your_mdm 2>$null

}

if ($true) { Write-Output "# 4. Copy past everthing from the template to local version of your `meta-data-model`-repository.";

  # Delete everything except .git-folder
  if (Test-Path $fp_your_mdm) {
      Get-ChildItem -Path $fp_your_mdm -Recurse -Force |
          Where-Object { $_.Name -notin @('.git') } |
          Remove-Item -Recurse -Force
  } else {
      New-Item -Path $fp_your_mdm -ItemType Directory -Force
  }

  # Then copy and paste everthing
  Get-ChildItem -Path $fp_temp_mdm -Force | 
    Where-Object { $_.Name -ne '.git' } | 
    ForEach-Object { 
      Copy-Item -Path $_.FullName -Destination $fp_your_mdm -Recurse -Force 
    }


}

if ($true) { Write-Output "# 5. Updating PublishProfiel for `Database`.";

  # When de project will be deployed (build/published) it will require access to the database, therefor server, databaser, username and password is needed, these will be stored in save mammer.
  $secure_nm_sql_server   = Read-Host "SQL Server   : " -AsSecureString # Example: "localhost\sqlexpress" or "your-server.database.windows.net"
  $secure_nm_sql_database = Read-Host "SQL Database : " -AsSecureString # Example: "your_database_name"
  $secure_nm_sql_username = Read-Host "SQL Username : " -AsSecureString # Example: "your_username" (if you use SQL Authentication)
  $secure_nm_sql_password = Read-Host "SQL Password : " -AsSecureString # Example: "your_password" (if you use SQL Authentication)
  # if you don`t want to type all of these credentials every time you run the script, you can replace the above lines with the following:
  # $secure_nm_sql_server   = ConvertTo-SecureString "localhost\sqlexpress" -AsPlainText -Force
  # $secure_nm_sql_database = ConvertTo-SecureString "your_database_name" -AsPlainText -Force
  # $secure_nm_sql_username = ConvertTo-SecureString "your_username" -AsPlainText -Force
  
  # Setting local variables
  $fp_project = "$fp_your_mdm\meta-data-model\9-Publish\2-Depolyment"
  $nm_profile = "$nm_your_mdm.publish.xml"
  $fp_profile = Join-Path -Path $fp_project -ChildPath "\$nm_profile"

  # Database related paramters (update if needed)
  $Encrypt                = "False"  # Adjust to your requirements
  $Integrated_Security    = "False"  # Adjust to your requirements
  $TrustServerCertificate = "False"  # Adjust to your requirements

  # Ensure the directory exists
  $fp_project = Split-Path $fp_profile 
  if (-not (Test-Path $fp_profile)) { New-Item -ItemType Directory -Path $fp_profile -Force | Out-Null }

  # Create the XML content
  $tx_xml = @"
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
    <TargetDatabaseName>$(ConvertTo-PlainText($secure_nm_sql_database))</TargetDatabaseName>
    <TargetConnectionString>
      Data Source=($(ConvertTo-PlainText($secure_nm_sql_server)));
      Initial Catalog=($(ConvertTo-PlainText($secure_nm_sql_database)));
      Integrated Security=True;
      Encrypt=$Encrypt;
      TrustServerCertificate=$TrustServerCertificate;
    </TargetConnectionString>
    <DeployScriptFileName>$nm_your_mdm.sql</DeployScriptFileName>
    <ProfileVersionNumber>1</ProfileVersionNumber>
    </PropertyGroup>
</Project>
"@

  # Removce the file if it exists, so we can create a new one.
  if ((Test-Path $fp_profile)) {Remove-Item $fp_profile -Force } 

  # Write the XML content to the file
  $tx_xml | Out-File -FilePath $fp_profile -Encoding utf8 

}

if ($true) { Write-Output "# 6. Update `Project` with utilized Database version.";

    # Read the current version from the DSP file
    $fp_project = "$fp_your_mdm\meta-data-model\meta-data-model.sqlproj"

    # If the project file exists, read and update the version
    [xml]$xml = Get-Content $fp_project
    
    if ($true) { # Build connection string for the database
        $strConnection = "Server=$(ConvertTo-PlainText($secure_nm_sql_server));" +
            "Database=$(ConvertTo-PlainText($secure_nm_sql_database));" +
            "User Id=$(ConvertTo-PlainText($secure_nm_sql_username));" +
            "Password=$(ConvertTo-PlainText($secure_nm_sql_password));" +
            "Integrated Security=$Integrated_Security;" +
            "Encrypt=$Encrypt;" + 
            "TrustServerCertificate=$TrustServerCertificate;"
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = $strConnection
        $sqlConnection.Open()
        $sqlCommand = $sqlConnection.CreateCommand(); $sqlCommand.CommandText = "SELECT @@VERSION AS ds_version"
        $sqlReader = $sqlCommand.ExecuteReader(); $ds_version = $null; if ($sqlReader.Read()) { $ds_version = $sqlReader["ds_version"] }; $sqlReader.Close()
        $sqlConnection.Close()
    }

    if ($true) { # Determine if version is 2022 or Azure SQL Managed Instance, 2019, 2017, or other versions
        $ni_version = $null
        if ($null -eq $ds_version) {  Write-Output "Error: Could not retrieve the database version.";  exit 1 }    
        elseif ($ds_version -match "2022") { $ni_version = 160 }
        elseif ($ds_version -match "2019") { $ni_version = 150 }
        elseif ($ds_version -match "2017") { $ni_version = 140 }
        elseif ($ds_version -match "2016") { $ni_version = 130 }
        elseif ($ds_version -match "2014") { $ni_version = 120 }
        elseif ($ds_version -match "2012") { $ni_version = 110 }
        elseif ($ds_version -match "2008") { $ni_version = 100 }
        elseif ($ds_version -match "2005") { $ni_version =  90 }
        else { Write-Output "Error: Unsupported database version: $ds_version"; exit 2 }
        $ds_dsp_version = "Microsoft.Data.Tools.Schema.Sql.Sql$($ni_version)DatabaseSchemaProvider"        
    }
    
    $new = '$(DacPacRootPath)\Extensions\Microsoft\SQLDB\Extensions\SqlServer\<ni_version>\SqlSchemas\master.dacpac'.Replace('<ni_version>', $ni_version)

    # Update the DSP in the project file
    $xml.Project.PropertyGroup               | Where-Object { $_.DSP }               | ForEach-Object { $_.DSP = $ds_dsp_version }
    $xml.Project.ItemGroup                   | Where-Object { $_.ArtifactReference } | ForEach-Object { $_.ArtifactReference.Include = $new }
    $xml.Project.ItemGroup.ArtifactReference | Where-Object { $_.HintPath }          | ForEach-Object { $_.HintPath = $new }

    # Save the updated file
    $xml.Save($fp_project)

}

if ($true) { Write-Output "# 7. Build your `Meta-Data-Model` (dacpac).";

  # Search for SqlPackage.exe and store the first match in a variable
  $msbuild = Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio" -Recurse -Filter MSBuild.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

  # Build the SQL Database Project
  & "$msbuild" "$fp_your_mdm\meta-data-model\meta-data-model.sqlproj" `
      /p:Configuration=Debug `
      /p:DeployOnBuild=true `
      /p:PublishProfile="$fp_profile"
}

if ($true) { Write-Output "# 8. Publish `Meta-Data-Model` to database.";

  # Search for SqlPackage.exe and store the first match in a variable
  $sqlPackagePath = Get-ChildItem -Path "C:\" -Filter "SqlPackage.exe" -Recurse -ErrorAction SilentlyContinue -Force |
      Where-Object { $_.FullName -match "SqlPackage.exe" } |
      Select-Object -First 1 -ExpandProperty FullName

  # Run SqlPackage.exe to publish
  & "$sqlPackagePath" /Action:Publish `
      /SourceFile:"$fp_your_mdm\meta-data-model\bin\Debug\meta-data-model.dacpac" `
      /Profile:"$fp_profile" `
      /TargetServerName:"$(ConvertTo-PlainText($secure_nm_sql_server))" `
      /TargetDatabaseName:"$(ConvertTo-PlainText($secure_nm_sql_database))" `
      /TargetUser:"$(ConvertTo-PlainText($secure_nm_sql_username))" `
      /TargetPassword:"$(ConvertTo-PlainText($secure_nm_sql_password))"
}

Write-Output "All done, the `Meta-Data-Model` is now deployed to the database `$nm_database` on server `$nm_server`."

# Reset warning preference
$WarningPreference = "Continue" 


````

#### Installing the ***Meta-Data-Definitions*** for Model

n the previous section, the PowerShell script installed the Meta-Data Model, which contains all the logic required for the deployment and processing of datasets.

To begin designing and registering your own datasets and associated metadata, you will use the template provided in the Git repository of the Meta-Data-Def. Since this is a template, you must first create an empty Git repository under your own control to serve as the foundation for your model.

##### 1. Step-by-Step Instructions

Prepare Your Repository
Create a new, empty Git repository where your model will reside. This repository will be initialized using the template.

##### 2. Initialize the Repository

Use the PowerShell script provided below to initialize your repository. This script sets up the necessary structure for your first model.

##### 3. Provide User Input

While much of the setup process is automated, the script will prompt you for some required inputs. Follow the prompts to complete the initialization.

> 💡 ***Tip:*** To keep your models clean and easy to deploy, it's recommended to group related datasets into a single model. The framework supports referencing other models and reusing datasets, so modular design is encouraged.

###### PowerShell Script

````PowerShell
#
# Save this script as "inital-setup-<name-of-your-model>.ps1" in 
# local folder (not in any git-folder) # and execute with
# command `powershell -ExecutionPolicy Bypass -File "inital-setup-<name-of-your-model>.ps1"`
# fron cmd-line window.
#

# Suppress warning
$WarningPreference = "SilentlyContinue"

function ConvertTo-PlainText($secure) {
    # Convert a SecureString to plain text
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)   
}

if ($true) { Write-Output "# 0. Setting local user specific variables.";

  # The script will need the local folder path to where the `Git`-repository are stored.
  $fp_fldr_git = Read-Host "Please provide folderpath to location of local git repositories (for example `c:\git`)"
  # if you don`t want to type this every time you run the script, you can replace the above line with the following:
  # $fp_fldr_git = "C:\Git"

  # The script will need the URL to your git repository for the `Meta-Data-Model` so if can be cloned to the local git-folder.
  $ur_your_mdd = Read-Host "Please provide the URL to `your` git repository so it can be cloned (for example `https://github.com/Demo-Simple-Analytyic-Platform/meta-def-example.git`)" 
  # if you don`t want to type this every time you run the script, you can replace the above line with the following:
  # $ur_your_mdD = "https://github.com/Demo-Simple-Analytyic-Platform/meta-def-example.git"
  $nm_your_mdd = $ur_your_mdd.Split("/")[-1] -replace "\.git$", "" # Extraction of "Own" meta-data-model repository name.
  $fp_your_mdd = "$fp_fldr_git\$nm_your_mdd"                       # path to (local) meta-data-model

  # Folderpaths for `Template` "meta-data-model".
  $fp_temp_fld = "$fp_fldr_git\template"         # path to template-folde
  $fp_temp_mdd = "$fp_temp_fld\meta-data-def"  # path to (template) meta-data-model
  $ur_temp_mdd = "https://github.com/Demo-Simple-Analytyic-Platform/meta-data-def.git"

  # Show the user what will be done, and how to use the script.
  Write-Output "fp_fldr_git: $fp_fldr_git"
  Write-Output "ur_your_mmd: $ur_your_mdd"
  Write-Output "nm_your_mmd: $nm_your_mdd"
  Write-Output "fp_your_mmd: $fp_your_mdd"
  Write-Output "fp_temp_fld: $fp_temp_fld"
  Write-Output "fp_temp_mdd: $fp_temp_mdd"
  Write-Output "ur_temp_mdd: $ur_temp_mdd"

  # Check in the `Model` (name of the Repository) is max. 16 characters long.
  if ($nm_your_mdd.Length -gt 16) {
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    Write-Output "!!!                                           !!!"
    Write-Output "!!!  Maximum length of `Repository`-name is 16  !!!"
    Write-Output "!!!                                           !!!"
    Write-Output "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    exit 1
  }
  
}

if ($true) { Write-Output "# 1. Create a folder structure: C:\Git\ with subfolder `template`."; 

  if (-Not (Test-Path -Path $fp_fldr_git)) { New-Item -Path $fp_fldr_git -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_your_mdd)) { New-Item -Path $fp_your_mdd -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_temp_fld)) { New-Item -Path $fp_temp_fld -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_temp_mdd)) { New-Item -Path $fp_temp_mdd -ItemType Directory -Force }

}

if ($true) { Write-Output "# 2. Clone this meta-data-model repository to the `\git\template\`-folder. remember, this repo is publicly accessiable and `readonly` for all but the `owners`.";

  git clone $ur_temp_mdd $fp_temp_mdd 2>$null

}

if ($true) { Write-Output "# 3. Clone `your` repo for the `Meta-Data-Definitions` to `\git\`-folder, to make if locally aviable, initially this should be completely empty.";
  
    git clone $ur_your_mdd $fp_your_mdd 2>$null

}

if ($true) { Write-Output "# 4. Copy past everthing from the template to local version of your `meta-data-model`-repository.";

  # Delete everything except .git-folder
  if (Test-Path $fp_your_mdd) {
      Get-ChildItem -Path $fp_your_mdd -Recurse -Force |
          Where-Object { $_.Name -notin @('.git') } |
          Remove-Item -Recurse -Force
  } else {
      New-Item -Path $fp_your_mdd -ItemType Directory -Force
  }

  # Then copy and paste everthing
  Get-ChildItem -Path $fp_temp_mdd -Force | 
    Where-Object { $_.Name -ne '.git' } | 
    ForEach-Object { 
      Copy-Item -Path $_.FullName -Destination $fp_your_mdd -Recurse -Force 
    }

}

if ($true) { Write-Output "# 5. Open Microsoft Office Access Application named `ms-access-frontend.accdb` and initialize repository."
    
    # Build Folderpath to `Frontend`-folder
    $fp_frontend = "$fp_your_mdd\2-meta-data-definitions\1-Frontend"

    # Create helper file for controlling the Access Application
    $fp_powershell_start = "$fp_frontend\PowerShellStart.txt"
    Set-Content -Path "$fp_powershell_start" -Value "Started From Powershell"

    # Build "Microsoft Access Application from `source`-files, by starting `start-meta-data-editor.ps1` and waiting on the result.
    # D:\git\Demo-Simple-Analytic-Platform\meta-data-def\2-meta-data-definitions\1-Frontend\start-meta-data-editor.ps1
    $fp_start_meta_data_editor_ps1 = "$fp_your_mdd\2-meta-data-definitions\1-Frontend\start-meta-data-editor.ps1"
    Write-Output "     - Waiting on building `Access`-application."
    Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File ""$fp_start_meta_data_editor_ps1""" -NoNewWindow -Wait

}

if ($true) { Write-Output "# 6. Updating PublishProfiel for `Database`.";

  # When de project will be deployed (build/published) it will require access to the database, therefor server, databaser, username and password is needed, these will be stored in save mammer.
  $secure_nm_sql_server   = Read-Host "SQL Server   : " -AsSecureString # Example: "localhost\sqlexpress" or "your-server.database.windows.net"
  $secure_nm_sql_database = Read-Host "SQL Database : " -AsSecureString # Example: "your_database_name"
  $secure_nm_sql_username = Read-Host "SQL Username : " -AsSecureString # Example: "your_username" (if you use SQL Authentication)
  $secure_nm_sql_password = Read-Host "SQL Password : " -AsSecureString # Example: "your_password" (if you use SQL Authentication)
  # if you don`t want to type all of these credentials every time you run the script, you can replace the above lines with the following:
  # $secure_nm_sql_server   = ConvertTo-SecureString "your-sql-server-path" -AsPlainText -Force
  # $secure_nm_sql_database = ConvertTo-SecureString "your-database-name" -AsPlainText -Force
  # $secure_nm_sql_username = ConvertTo-SecureString "your-username" -AsPlainText -Force
  
  # Setting local variables
  $fp_project = "$fp_your_mdd\2-meta-data-definitions\9-Publish\2-Depolyment"
  $nm_profile = "$nm_your_mdd.publish.xml"
  $fp_profile = Join-Path -Path $fp_project -ChildPath "\$nm_profile"

  # Database related paramters (update if needed)
  $Encrypt                = "False"  # Adjust to your requirements
  $Integrated_Security    = "False"  # Adjust to your requirements
  $TrustServerCertificate = "False"  # Adjust to your requirements

  # Ensure the directory exists
  $fp_project = Split-Path $fp_profile 
  if (-not (Test-Path $fp_profile)) { New-Item -ItemType Directory -Path $fp_profile -Force | Out-Null }

  # Create the XML content
  $tx_xml = @"
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
    <TargetDatabaseName>$(ConvertTo-PlainText($secure_nm_sql_database))</TargetDatabaseName>
    <TargetConnectionString>
      Data Source=($(ConvertTo-PlainText($secure_nm_sql_server)));
      Initial Catalog=($(ConvertTo-PlainText($secure_nm_sql_database)));
      Integrated Security=True;
      Encrypt=$Encrypt;
      TrustServerCertificate=$TrustServerCertificate;
    </TargetConnectionString>
    <DeployScriptFileName>$nm_your_mdm.sql</DeployScriptFileName>
    <ProfileVersionNumber>1</ProfileVersionNumber>
    </PropertyGroup>
</Project>
"@

  # Removce the file if it exists, so we can create a new one.
  if ((Test-Path $fp_profile)) {Remove-Item $fp_profile -Force } 

  # Write the XML content to the file
  $tx_xml | Out-File -FilePath $fp_profile -Encoding utf8 

}

if ($true) { Write-Output "# 7. Update `Project` with utilized Database version.";

    # Read the current version from the DSP file
    $fp_project = "$fp_your_mdd\2-meta-data-definitions\2-meta-data-definitions.sqlproj"

    # If the project file exists, read and update the version
    [xml]$xml = Get-Content $fp_project
    Write-Output $xml
    
    if ($true) { # Build connection string for the database
        $strConnection = "Server=$(ConvertTo-PlainText($secure_nm_sql_server));" +
            "Database=$(ConvertTo-PlainText($secure_nm_sql_database));" +
            "User Id=$(ConvertTo-PlainText($secure_nm_sql_username));" +
            "Password=$(ConvertTo-PlainText($secure_nm_sql_password));" +
            "Integrated Security=$Integrated_Security;" +
            "Encrypt=$Encrypt;" + 
            "TrustServerCertificate=$TrustServerCertificate;"
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = $strConnection
        $sqlConnection.Open()
        $sqlCommand = $sqlConnection.CreateCommand(); $sqlCommand.CommandText = "SELECT @@VERSION AS ds_version"
        $sqlReader = $sqlCommand.ExecuteReader(); $ds_version = $null; if ($sqlReader.Read()) { $ds_version = $sqlReader["ds_version"] }; $sqlReader.Close()
        $sqlConnection.Close()

    }

    if ($true) { # Determine if version is 2022 or Azure SQL Managed Instance, 2019, 2017, or other versions
        $ni_version = $null
        if ($null -eq $ds_version) {  Write-Output "Error: Could not retrieve the database version.";  exit 1 }    
        elseif ($ds_version -match "2022") { $ni_version = 160 }
        elseif ($ds_version -match "2019") { $ni_version = 150 }
        elseif ($ds_version -match "2017") { $ni_version = 140 }
        elseif ($ds_version -match "2016") { $ni_version = 130 }
        elseif ($ds_version -match "2014") { $ni_version = 120 }
        elseif ($ds_version -match "2012") { $ni_version = 110 }
        elseif ($ds_version -match "2008") { $ni_version = 100 }
        elseif ($ds_version -match "2005") { $ni_version =  90 }
        else { Write-Output "Error: Unsupported database version: $ds_version"; exit 2 }
        $ds_dsp_version = "Microsoft.Data.Tools.Schema.Sql.Sql$($ni_version)DatabaseSchemaProvider"        
    }

    $new = '$(DacPacRootPath)\Extensions\Microsoft\SQLDB\Extensions\SqlServer\<ni_version>\SqlSchemas\master.dacpac'.Replace('<ni_version>', $ni_version)

    # Update the DSP in the project file
    $xml.Project.PropertyGroup | Where-Object { $_.DSP } | ForEach-Object { $_.DSP = $ds_dsp_version }

    # Update master.dacpac reference
    $xml.Project.ItemGroup | Where-Object { $_.ArtifactReference } | ForEach-Object { $_.ArtifactReference.Include = $new }
    $xml.Project.ItemGroup.ArtifactReference | Where-Object { $_.HintPath } | ForEach-Object { $_.HintPath = $new }

    # Save the updated file
    $xml.Save($fp_project)

}

if ($true) { Write-Output "# 8. Build your `Meta-Data-Definitions` (dacpac).";

  # Search for SqlPackage.exe and store the first match in a variable
  $msbuild = Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio" -Recurse -Filter MSBuild.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

  # Build the SQL Database Project
  & "$msbuild" "$fp_your_mdd\2-meta-data-definitions\2-meta-data-definitions.sqlproj" `
      /p:Configuration=Debug `
      /p:DeployOnBuild=true `
      /p:PublishProfile="$fp_profile"

}

if ($true) { Write-Output "# 9. Publish `Meta-Data-Model` to database.";

  # Search for SqlPackage.exe and store the first match in a variable
  $sqlPackagePath = Get-ChildItem -Path "C:\" -Filter "SqlPackage.exe" -Recurse -ErrorAction SilentlyContinue -Force |
      Where-Object { $_.FullName -match "SqlPackage.exe" } |
      Select-Object -First 1 -ExpandProperty FullName

  # Run SqlPackage.exe to publish
  & "$sqlPackagePath" /Action:Publish `
      /SourceFile:"$fp_your_mdd\2-meta-data-definitions\bin\Debug\2-meta-data-definitions.dacpac" `
      /Profile:"$fp_profile" `
      /TargetServerName:"$(ConvertTo-PlainText($secure_nm_sql_server))" `
      /TargetDatabaseName:"$(ConvertTo-PlainText($secure_nm_sql_database))" `
      /TargetUser:"$(ConvertTo-PlainText($secure_nm_sql_username))" `
      /TargetPassword:"$(ConvertTo-PlainText($secure_nm_sql_password))"

}

Write-Output "All done, the `Meta-Data-Definitions` for '$nm_your_mdd'-Model is now deployed to the database '$(ConvertTo-PlainText($secure_nm_sql_database))' on server '$(ConvertTo-PlainText($secure_nm_sql_server))."

# Reset warning preference
$WarningPreference = "Continue" 

````

## Tutorials

We have provide various Tutorials, see list below, where we will take you step by step throught the process of creating dataset for ingestion and transformations.

### Assumtions (no need to have jedi-master skills)

- Good understanding of `SQL` (master jedi skill, if you want to understand the coding, able to write solid queries if you only using the tooling)
- Some understanding of `Visual Studio` Solution, assumtion is that you can `publish` a project in visual studio.
- Some understanding of `Visual Studio Code`
- Some understanding of `SQL Server Management Studio`
- Some understanding of `PowerShell`
- Some understanding of `Command Prompt` (you should be able to execute bat-file)
- Some understanding of `Python`
- Some understanding of `Git`
- Some understanding of `Azure Storage Account`\`s

### Tutorials: Secrets Database

This solution is using as SQL Database to store `Secrets`, in combination with the python function to add, remove and read secrets which are stored in hashed string and password protected independent of the access to the database. The tutorial will walk you throught the various steps to implement the database and how to use the add, read and remove functions.

#### [1. Implementing Secrets Database](.attachments/tutorials/0-Secrets-Database/1-Implementing-a-Secrets-Database.md)
 
> NOTE: should you are planning a large scale data platform, better tools like [Azure Key Vault](https://azure.microsoft.com/nl-nl/products/key-vault), [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/), [Keeper](https://www.keepersecurity.com/) or [HashiCorp Valutr](https://www.hashicorp.com/en/products/vault).


### Tutorials: Ingestions

#### [1. Ingestion of ***Stock Trade Infromation*** (webtable from Yahoo)](.attachments/tutorials/1-Ingestions/1-Stock-Trade-Information.md)

#### [2. Ingestion of ***Currency Exchange Rares*** (webtable from Yahoo)](.attachments/tutorials/1-Ingestions/2-Currency-Exchange-Rates.md)

#### [3. Ingestion of ***List of Currencies*** (Webtable from Wikipedia)](.attachments/tutorials/1-Ingestions/3-List-of-Currency.md)

#### [4. Ingestion of ***Transactions of Trade Account*** (Azure Blob Storage - Excel)](.attachments/tutorials/1-Ingestions/4-Transactions-of-Trade-Account.md)

#### [5. Ingestion of **List of Shares (Stocks)** (Azure Blob Storage - CSV)](.attachments/tutorials/1-Ingestions/5-List-of-Shares.md)

### Tutorials: Transformations

#### [1. Transformation ***Union of Stock Trade Information***](.attachments/tutorials/2-Transformations/1-Union-of-Stock-Trade-Information.md)

#### [2. Transformation ***Exchange Rates on EOM***](.attachments/tutorials/2-Transformations/2-Exchange-Rates-EOM.md)

#### [3. Transformation ***Amounts Traded on EOM (Converted to EUR)***](.attachments/tutorials/2-Transformations/3-Amounts-Traded-on-EOM.md)

#### [4. Transformation ***Recieved Devidends on EOM (Converted to EUR)***](.attachments/tutorials/2-Transformations/4-Recieved-Devidends-on-EOM.md)

#### [5. Transformation ***Performance of Shares in EUR***](.attachments/tutorials/2-Transformations/5-Performance-of-Shares-in-EUR.md)

### Tutorials: Updating Software

#### [1. Updating the Meta-Data-Model](.attachments/tutorials/3-Software-Updates/1-Updating-Meta-Data-Model.md)

#### [2. Updating the Frontend Tooling](.attachments/tutorials/3-Software-Updates/2-Updating-Frontend-Tooling.md)

