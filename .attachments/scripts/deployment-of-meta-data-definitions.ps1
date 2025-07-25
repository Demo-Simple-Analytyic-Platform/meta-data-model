# This script is used to deploy the Meta-Data-Model to a SQL database.
# 0. Setting local user specific variables.
# 1. Create a folder structure: C:\Git\ with subfolder `template`.
# 2. Clone this meta-data-model repository to the `\git\template\`-folder.
# 3. Clone `your` repo for the `Meta-Data-Definitions` to `\git\`-folder.
# 4. Copy past everything from the template to local version of your `meta-data-model`-repository.
# 5. Open Microsoft Office Access Application named `ms-access-frontend.accdb` and initialize repository.
# 6. Updating PublishProfiel for `Database`.
# 7. Update `Project` with utilized Database version.
# 8. Build your `Meta-Data-Definitions` (dacpac).
# 9. Publish `Meta-Data-Model` to database.

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

  if (-Not (Test-Path -Path $fp_fldr_git | Out-Null)) { New-Item -Path $fp_fldr_git -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_your_mdd | Out-Null)) { New-Item -Path $fp_your_mdd -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_temp_fld | Out-Null)) { New-Item -Path $fp_temp_fld -ItemType Directory -Force }
  if (-Not (Test-Path -Path $fp_temp_mdd | Out-Null)) { New-Item -Path $fp_temp_mdd -ItemType Directory -Force }

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
  # $secure_nm_sql_server   = ConvertTo-SecureString "your-server-name" -AsPlainText -Force
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
