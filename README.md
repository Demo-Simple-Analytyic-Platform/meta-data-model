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
  - [Tutorial](#tutorial)
  - [How to get Started](#how-to-get-started)
    - [Before starting](#before-starting)
    - [Meta-Data-Model (MDM)](#meta-data-model-mdm)
      - [To start using the framework the following step must be under taken](#to-start-using-the-framework-the-following-step-must-be-under-taken)
    - [Meta-Data-Definition (MDD) for a Model](#meta-data-definition-mdd-for-a-model)
      - [To start using the framework the following step must be under taken.](#to-start-using-the-framework-the-following-step-must-be-under-taken-1)

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

> ***Tip:*** To keep `Models` lean and easy deployable, it would be good practic to bundel related `datasets` per `model` the framework allows for referencing other `Models` and reusing the `datasets`.

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

````

1. Create a local folder on the root, name it `git` with a subfolder named `template`. This where you'll be storing/cloning the local versions of repositories.

2. Clone this [repo](https://github.com/mehmetmisset/linkedin-article-1-data-ingestion-transformation-requirements.git) to the `\git\template\`-folder. remember, this repo is publicly accessiable and `readonly` for all but the `owners`.

3. Create new git repository named `meta-data-model`, which under the `your` own control. pre-populate the git inore file with "*Visual Studio*"-stuff. If forgotten, not to worry, just copy-paste then `.gitinore`-file from the `template`.
On github it should look something like this:<br> ![new repo on github](.attachments/images/creating-repository-in-github-meta-def-example.png)<br>*Image: screenshot from github.com*
1. Clone `your` repo to `\git\`-folder, to make if locally aviable.
2. Copy the content including subfolder and all files of folder `\git\template\meta-data-model` to `\git\meta-data-model`-folder, `.vs`-folder can be ignored if avialable.
````cmd
xcopy "C:\git\template\meta-data-model" "\git\meta-data-model" /E /I /H /C /Y
````
1. Open the *Visual Studio*-solution named "***meta-data-model.sln***" from the `\git\meta-data-model\`-folder.
2. Commit the changes to the branch and push to the remote.<br>
It up to you as a developer to create "*initizaltion*"-branch or something like it or just update the "*main*"-branch directly.
1. Now you can "*publish*" the `Project` named `meta-data-model` to your target database. (If you are not provisiant in visual studio, educate you self first)<br> ![Screen of dropdown menu with publish highlighted](.attachments/images/publish-visual-studio-project.png)<br>*Image: Screen of dropdown menu with publish highlighted*


## Tutorial







## How to get Started

### Before starting

The below will assume you as a developer (Data Engineer) has experiance with
- Git (The step below will referecen github, but any other will do, if you have experiance with git you'll already know this)
- Visual Studio (big brother of Visual Studio Code)
- Visual Studio Code
- Microsoft SQL Server / Database
- Microsoft Office Access
- SQL (T-SQL, the transfromation queries need to be in T-SQL)
- Python (reading, executing and writting to some extrent)

### Meta-Data-Model (MDM)

To use this repository, new repositories must be created under you own control, surely for the model part. The `meta-data-model`-part can be used as is, however you will nog be in control of updates, better to make you own copy perhabs. The `meta-data-model`-part has all the database schemas, table, view, functions and procedures for `Deployment`- and internal data `Processing`- logic.

> ***Tip:*** To keep `Models` lean and easy deployable, it would be good practic to bundel related `datasets` per `model` the framework allows for referencing other `Models` and reusing the `datasets`.

> ***Note:*** If you are content with the workings of the framework as is and have no intentions on modifying it, steps 3, 4, 5 and 6 can be skipped. The solution can be deployed from the *Visual Studio*-solution named "***meta-data-model.sln***" in the `\git\template\meta-data-model\`-folder after you have cloned it there.

#### To start using the framework the following step must be under taken

1. Create a local folder on the root, name it `git` with a subfolder named `template`. This where you'll be storing/cloning the local versions of repositories.

2. Clone this [repo](https://github.com/mehmetmisset/linkedin-article-1-data-ingestion-transformation-requirements.git) to the `\git\template\`-folder. remember, this repo is publicly accessiable and `readonly` for all but the `owners`.

3. Create new git repository named `meta-data-model`, which under the `your` own control. pre-populate the git inore file with "*Visual Studio*"-stuff. If forgotten, not to worry, just copy-paste then `.gitinore`-file from the `template`.
On github it should look something like this:<br> ![new repo on github](.attachments/images/creating-repository-in-github-meta-def-example.png)<br>*Image: screenshot from github.com*
4. Clone `your` repo to `\git\`-folder, to make if locally aviable.
5. Copy the content including subfolder and all files of folder `\git\template\meta-data-model` to `\git\meta-data-model`-folder, `.vs`-folder can be ignored if avialable.
````cmd
xcopy "C:\git\template\meta-data-model" "\git\meta-data-model" /E /I /H /C /Y
````
6. Open the *Visual Studio*-solution named "***meta-data-model.sln***" from the `\git\meta-data-model\`-folder.
7. Commit the changes to the branch and push to the remote.<br>
It up to you as a developer to create "*initizaltion*"-branch or something like it or just update the "*main*"-branch directly.
8. Now you can "*publish*" the `Project` named `meta-data-model` to your target database. (If you are not provisiant in visual studio, educate you self first)<br> ![Screen of dropdown menu with publish highlighted](.attachments/images/publish-visual-studio-project.png)<br>*Image: Screen of dropdown menu with publish highlighted*

After the **build** completes successfull, the dialoog window below appears, provide the targat database credentials, if desirable *save* the profile.
Folderpath to presaved Publish-profiles.<br>![Publish Database dialog](.attachments/images/publish-database.png)<br>*Image: Publish Database dialog*

An example of a saved profile can be found in the folder `/9-Publish/2-Deployment/`.<br> ![Folderpath to presaved Publish-profiles](.attachments/images/folder-structure-of-mdm-project.png)<br>*Image: Folderpath to presaved Publish-profiles*

The deployment- processing- logic has now be installed.

### Meta-Data-Definition (MDD) for a Model

As the [meta-data-model (MDM)](#meta-data-model-mdm) contains the database logic for deployment and processing datasets, The ["***Meta-Data-Definition (MDD)***"-repository](https://github.com/Demo-Simple-Analytyic-Platform/meta-data-def) holds the definitions templates for the metadata of these "***Datasets***".

For the *maintainability* it would be good pratic to limit then "***Model***"-size in the scope and number of "***Datastes***". For this purpose one repository per model should be created under the control of you as a developer.

#### To start using the framework the following step must be under taken.

1. Create new git repository and give it the name of your `Model`, make sure the name of the repo has a maximum of 16 characters. So short, compact and functional will do the trick.
2. Clone this new repository to your local `\git\`-folder, make sure the folder-name is equal to the name of the repository.
3. Clone the "template"-repository of "meta-data-def" to the `\git\template\meta-data-def\`-folder.
4. navigate to the `\git\template\meta-data-def\2-meta-data-definitions\1-Frontend\`-folder and start the `Microsoft Office Access`-application named `ms-access-frontend`. The "StartUp"-form is loaded and the first message will appear that will give you the option to copy/paste the required file/folder structures to the *new* `model`.<br>![Would you like to set model/repostitory-folder?](.attachments/images/meta-data-def/mesage-this-is-template-repository.png)<br>*image: Would you like to set model/repostitory-folder?*
5. If `No` is chosen, the application will shuts down. However if you as a developer are lazy, you'll have chosen `Yes` a new form will load, see below. <br>![Set new model folder](.attachments/images/meta-data-def/form-set-new_model_folder.png)<br>*image: Set new model folder*
6. There you'll have another change to back out, by clicking on `Cancel`. But after copy-pasting the *new* `model`-folder into the input text-field, you can click on `Copy Meta-Data-Def File/Folder-Structure`. If all goes well the application will start in the *new* `model`-folder location.<br>![Start-Up from](.attachments/images/meta-data-def/form-start-up.png)<br>*image : Start-Up form*<br>If the `\git\`-folder with the subfolders was not declared `save` you'll need to close the form first and accept the warning or set the `\git\`-folder as save.<br>![](.attachments/images/meta-data-def/security-warning-save-folders.png)<br>*image : security waring for `active`-content*
7. A new message dialogbox will appear informing the this instance is the `running` in `initial setup`.<br>![Initial setup](.attachments/images/meta-data-def/message-initial-setup.png)<br>*Image : Initial Setup*<br>This will only appear directly after copy/past action from the `meta-data-def`-repository.
8. Navigate to the `Model`-tab and expand the `Model`-record to provide the database credentials for the various environments. (The `Secret` is **NOT** the **Password** for the provide *Username*, it should be the name of the ***Secret*** where the **Pasword** is stored.)
9. Open the *Visual Studio*-solution named "***meta-data-definitions.sln***" from the `\git\<name-of-your-model>\`-folder. Rename the *Visual Studio*-solution to the name of your model. (*With one `Model` this may seems over zellis, but with more `Models` with the same "Name" will make if very quickly, easy to get lost in the "Models" and "Solutions" with the same name*).
10. After the rename, do a `Build`, if succesfull you can commit the changes to the repository-remote (comment: "Intital setup" of something simular).
11. Now you can "*publish*" the `Model` to your target database.
12. Commit the changes to the branch and push to the remote.

The deployment of your data solution should be done in few seconds, depending on the connection and speed/power of hte target database. The deployment time will increase when more and more dataset are added to the `Model`.

> ***Note:*** Different `Models` can be deployed to the same target database. `Datasets` referenced from another `Model` which are deployed to the same dataset are NOT deployed double. If the referenced `Dataset` is deployed to a different target database, it will be treaded as if it were a "*Ingestion*"-dataset, the required paramateres will be extracted form de `Model`-information.

> ***Note:*** The `meta-data-def`-project also contains a solution for `Screts`-database, by deploying this database scretes can be stored in `relative` safety, acccess to this database should be very limited.
>> **Disclamer:** with a large scale (cloud) solution Azure Key Vault or simular should be implemented!

<!-- TOC END -->