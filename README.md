<h1>Overview</h1>

This SQL Server-based solution forms the foundation of the **Meta-Data Model**, designed to streamline deployment and data processing through automation. By handling the technical complexities behind the scenes, it enables Data Engineers to focus on delivering business value.

At its core, the solution provides:

- A clear and structured **Meta-Data Model** to describe datasets and register parameters for accessing external sources.
- SQL-based transformations using `SELECT` queries, making logic transparent and easy to maintain.
- Standardized historization for both **Ingestion** and **Transformation** processes.
- A **Model**-driven organization of datasets to maintain clarity and control.
- A clean separation between metadata, deployment, and processing logic, ensuring scalability and maintainability.

With minimal technology dependencies, this solution is easy to implement and works **out-of-the-box** on both **on-premises** and **cloud-based** SQL Server environments. Included Python scripts and procedures offer a solid starting point to get up and running quickly.

<!-- TOC END -->

---

### Table of Content

- [Getting Started](#getting-started)
  - [Pre-requirements](#pre-requirements)
  - [Installation](#installation)
    - [Installing the Meta-Data-Model](#installing-the-meta-data-model)
    - [Installing the Meta-Data-Definitions for Model](#installing-the-meta-data-definitions-for-model)
  - [Tutorial](#tutorial)

---

# Getting Started

Before diving into the process, it's essential to ensure that all necessary [pre-requirements](#pre-requirements) are fulfilled and the required development software is available. Once these steps are completed, you’ll be ready to proceed with the [installation](#installation). This guide will conclude with a concise [tutorial](3tutorial), where we will set up a dataset to ingest the *Euro-to-USD* exchange rates for the year and add a transformation that extracts the last exchange rate of each month.

It works in Conjunction with "***Meta-Data-Def***"-repository which should hold the meta-data-definitions for model (project). This repository only holds "***Meta-Data-Model***".<br>
The repository for the "***Meta-Data-Def***" can be found [here on git hub](https://github.com/Demo-Simple-Analytyic-Platform/meta-data-def).

## Pre-requirements

As state before the framework has strived to limit the required technologies, we can`t do completely without them. The following software should be installed.
1. Git ([git for window](https://gitforwindows.org/))
2. Visual Studio Code ([Download Visual Studio Code](https://code.visualstudio.com/Download))
3. Visual Studio (Community, Professional or Enterprise) ([Download Visual Studion](https://visualstudio.microsoft.com/downloads/), ensure "SQL Server Data Tools" is installed!)
4. Python ([Download Python](https://www.python.org/getit/))
5. SQL Server Management Studio ([Installeer SQL Server Management Studio](https://www.microsoft.com/sql-server/sql-server-downloads))
6. Microsoft Office, in particular Access ([Runtime Only](https://support.microsoft.com/en-us/office/download-and-install-microsoft-365-access-runtime-185c5a32-8ba9-491e-ac76-91cbe3ea09c9))

Now all these are installed or were already installed, the *Installation* of the Frameword can start.

## Installation

The Installation consists of number of steps most can be automated with PowerShell, clarity and understandig the are listed below. At the start it was mentioned that the scalability is maintain be separation to *deployment and processing logic* from the *metadata* of the *Datasets*. Thus the *Installation* also containts two parts. The first part is the *deployment and processing logic* this is containt in the repository [meta-data-model](https://github.com/Demo-Simple-Analytyic-Platform/meta-data-model) and the *metadata* of the *Datasets* in the second part this is found in the repository [meta-data-def]() and serves as template.
The Install

### Installing the Meta-Data-Model

To use this repository, new repositories must be created under you own control, surely for the model part. The `meta-data-model`-part can be used as is, however you will nog be in control of updates, better to make you own copy perhabs. The `meta-data-model`-part has all the database schemas, table, view, functions and procedures for `Deployment`- and internal data `Processing`- logic.

> ***Note:*** If you are content with the workings of the framework as is and have no intentions on modifying it, steps 3, 4, 5 and 6 can be skipped. The solution can be deployed from the *Visual Studio*-solution named "***meta-data-model.sln***" in the `\git\template\meta-data-model\`-folder after you have cloned it there.

<h3>PowerShell Script</h3.>

````PowerShell
# Setting (these must be provide by developer):
$drive       = "D:"               # Drive where you git-folder should go.
$own_mdm     = "https://github.com/Demo-Simple-Analytyic-Platform/meta-mdm-example.git" # replace with your own repo
$nm_server   = "localdb"
$nm_database = "demo"

# Extraction of "Own" meta-data-model repository name.
$own = $own_mdm.Split("/")[-1] -replace "\.git$", ""

# Other variables
$git = "$drive\git"           # path to git-folder
$tmp = "$git\template"         # path to template-folde
$mdm = "$tmp\meta-data-model"  # path to (template) meta-data-model
$lcl = "$git\$own"             # path to (local) meta-data-model

# Suppress warning
$WarningPreference = "SilentlyContinue"

echo "# 1. Check if the folders exists, if not create them."
if (-Not (Test-Path -Path $git)) { New-Item -Path $git -ItemType Directory -Force }
if (-Not (Test-Path -Path $tmp)) { New-Item -Path $tmp -ItemType Directory -Force }
if (-Not (Test-Path -Path $mdm)) { New-Item -Path $mdm -ItemType Directory -Force }
if (-Not (Test-Path -Path $lcl)) { New-Item -Path $lcl -ItemType Directory -Force }


echo "# 2. Clone this meta-data-model repository to the ""\git\template\""-folder. remember, this repo is publicly accessiable and ""readonly"" for all but the ""owners""."
git clone https://github.com/Demo-Simple-Analytyic-Platform/meta-data-model.git "$mdm" 2>$null

echo "# 3. Clone ""your"" repo for the ""Meta-Data-Model"" to ""\git\""-folder, to make if locally aviable, initially this should be completely empty."
git clone $own_mdm $lcl 2>$null

echo "# 4. Copy past everthing from the template to local version of your ""meta-data-model""-repository."
if (Test-Path $lcl) { # Delete everthing in target
    Get-ChildItem -Path $lcl -Recurse -Force | Remove-Item -Recurse -Force
} else {
    New-Item -Path $lcl -ItemType Directory -Force
} # Then copy and paste everthing
Get-ChildItem -Path $mdm -Force | Where-Object { $_.Name -ne ".git" } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $lcl -Recurse -Force
}

echo "# 5. Updating PublishProfiel for `LocalDB`."

$projectDir  = "$lcl\meta-data-model\9-Publish\2-Depolyment"
$profileName = "LocalDB-Demo.publish.xml"
$profilePath = Join-Path -Path $projectDir -ChildPath "\$profileName"

# Ensure the directory exists
$profileDir = Split-Path $profilePath
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Create the XML content
$xmlContent = @"
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
    <PropertyGroup>
    <TargetDatabaseName>$nm_database</TargetDatabaseName>
    <TargetConnectionString>Data Source=($nm_server)\MSSQLLocalDB;Initial Catalog=$nm_database;Integrated Security=True;</TargetConnectionString>
    <DeployScriptFileName>demo.sql</DeployScriptFileName>
    <ProfileVersionNumber>1</ProfileVersionNumber>
    </PropertyGroup>
</Project>
"@

# Save the file
$xmlContent | Out-File -FilePath $profilePath -Encoding utf8

echo "# 6. Build `Meta-Data-Model`."

# Search for SqlPackage.exe and store the first match in a variable
$msbuild = Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio" -Recurse -Filter MSBuild.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
$msbuild = $msbuild #-replace "msbuild.exe", ""
echo "$msbuild"

# cahnge directory
#Set-Location -Path "$msbuild"
& "$msbuild" "$lcl\meta-data-model\meta-data-model.sqlproj" `
    /p:Configuration=Release `
    /p:DeployOnBuild=true `
    /p:PublishProfile="$profilePath"

echo "# 7. Publish `Meta-Data-Model` to database."

# Search for SqlPackage.exe and store the first match in a variable
$sqlPackagePath = Get-ChildItem -Path "C:\" -Filter "SqlPackage.exe" -Recurse -ErrorAction SilentlyContinue -Force |
    Where-Object { $_.FullName -match "SqlPackage.exe" } |
    Select-Object -First 1 -ExpandProperty FullName

& "$sqlPackagePath" `
    /Action:Publish `
    /SourceFile:"$lcl\meta-data-model\bin\Release\meta-data-model.dacpac" `
    /Profile:"$profilePath"

echo "All done, the `Meta-Data-Model` is now deployed to the database `$nm_database` on server `$nm_server`."
# End of script
$WarningPreference = "Continue" # Reset warning preference  

````

### Installing the Meta-Data-Definitions for Model

In the previous section the *powershell& script installed the ***Meta-Data-Model***, which holds all de logic foor *deployment and processing* of ***datasets***. The *Template* in the git repostory of the ***Meta-Data-Def*** is used to register / design the ***Datasets*** and all related metadata information. As it is a template a empty git repository must be provided were the script below van initialized the repository to gettting started.

> ***Tip:*** To keep `Models` lean and easy deployable, it would be good practic to bundel related `datasets` per `model` the framework allows for referencing other `Models` and reusing the `datasets`.

<h3>PowerShell Script</h3.>

````PowerShell
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
# !!! Setting (these must be provide by developer):                                                              !!! #
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

$drive       = "D:"               # Drive where you git-folder should go.
$own_def     = "https://github.com/Demo-Simple-Analytyic-Platform/meta-def-example.git" # replace with your own repo
$nm_server   = "localdb"
$nm_database = "demo"

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

# Extraction of "Own" meta-data-model repository name.
$own = $own_def.Split("/")[-1] -replace "\.git$", ""

# Other variables
$git = "$drive\git"            # path to git-folder
$tmp = "$git\template"         # path to template-folde
$def = "$tmp\meta-data-def"    # path to (template) meta-data-model
$lcl = "$git\$own"             # path to (local) meta-data-model

# Suppress warning
$WarningPreference = "SilentlyContinue"


echo "# 1. Check if the folders exists, if not create them."
if (-Not (Test-Path -Path $git)) { New-Item -Path $git -ItemType Directory -Force }
if (-Not (Test-Path -Path $tmp)) { New-Item -Path $tmp -ItemType Directory -Force }
if (-Not (Test-Path -Path $def)) { New-Item -Path $def -ItemType Directory -Force }
if (-Not (Test-Path -Path $lcl)) { New-Item -Path $lcl -ItemType Directory -Force }


echo "# 2. Clone this meta-data-def repository to the ""\git\template\""-folder. remember, this repo is publicly accessiable and ""readonly"" for all but the ""owners""."
git clone https://github.com/Demo-Simple-Analytyic-Platform/meta-data-def.git "$def" 2>$null


echo "# 3. Clone ""your"" repo for the ""Your Model"" to ""\git\""-folder, to make if locally aviable, initially this should be completely empty."
git clone $own_def $lcl 2>$null


echo "# 4. Copy past everthing from the template to local version of your ""meta-data-model""-repository."
if (Test-Path $lcl) { Get-ChildItem -Path $lcl -Recurse -Force | Remove-Item -Recurse -Force } 
else { New-Item -Path $lcl -ItemType Directory -Force} 
Get-ChildItem -Path $def -Force | Where-Object { $_.Name -ne ".git" } | ForEach-Object { Copy-Item -Path $_.FullName -Destination $lcl -Recurse -Force }


echo "# 5. Open Microsoft Office Access Application named `ms-access-frontend.accdb` and initialize repository."
$msa = "$lcl\2-meta-data-definitions\1-Frontend"
$wfl = "$msa\PowerShellStart.txt"
Set-Content -Path "$msa\PowerShellStart.txt" -Value "Started From Powershell"
$accessApp = New-Object -ComObject Access.Application
$dbPath    = "$msa\ms-access-frontend.accdb"
$accessApp.OpenCurrentDatabase($dbPath)
$timeout = 100
$elapsed = 0
while ((Test-Path $wfl) -and ($elapsed -lt $timeout)) { 
    Start-Sleep -Seconds 1 
    $elapsed++ 
}
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($accessApp) | Out-Null
Remove-Variable accessApp

echo "All Done git repository `$own` is initialized."
echo "The meta data editor tooling will be restated now."
$accessApp = New-Object -ComObject Access.Application
$dbPath    = "$msa\ms-access-frontend.accdb"
$accessApp.OpenCurrentDatabase($dbPath)

````

## Tutorial

some text