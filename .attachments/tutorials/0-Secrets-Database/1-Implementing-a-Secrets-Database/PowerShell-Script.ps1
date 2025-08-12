# powershell -ExecutionPolicy Bypass -File "copy-paste-the-full-path-to-this-script.ps1"
# powershell -ExecutionPolicy Bypass -File "D:\git\Demo-Simple-Analytic-Platform\meta-data-model\.attachments\tutorials\0-Secrets-Database\1-Implementing-a-Secrets-Database.ps1"

# Suppress warning
$WarningPreference = "SilentlyContinue"

  function ConvertTo-PlainText($secure) {
    # Convert a SecureString to plain text
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)   
}

# newline variable for better readability
$emp = "";
$nwl = "`n";

if ($true) { Write-Output "# 0. Setting local user specific variables.";

  # determine the name of the parent folder, which is the name of the repository.
  $fp_secrets = $PSScriptRoot.Substring(0, ($PSScriptRoot.IndexOf(".attachments")-1))
  $fp_secrets = Join-Path -Path $fp_secrets -ChildPath "\secrets-database"
  Write-Output "fp_secrets: $fp_secrets"

}


if ($true) { Write-Output "# 5. Updating PublishProfiel for `Database`.";

  # When de project will be deployed (build/published) it will require access to the database, therefor server, databaser, username and password is needed, these will be stored in save mammer.
  $secure_nm_sql_server   = Read-Host "SQL Server"   -AsSecureString # Example: "localhost\sqlexpress" or "your-server.database.windows.net"
  $secure_nm_sql_database = Read-Host "SQL Database" -AsSecureString # Example: "your_database_name"
  $secure_nm_sql_username = Read-Host "SQL Username" -AsSecureString # Example: "your_username" (if you use SQL Authentication)
  $secure_nm_sql_password = Read-Host "SQL Password" -AsSecureString # Example: "your_password" (if you use SQL Authentication)
  # if you don`t want to type all of these credentials every time you run the script, you can replace the above lines with the following:
  # $secure_nm_sql_server   = ConvertTo-SecureString "localhost\sqlexpress" -AsPlainText -Force
  # $secure_nm_sql_database = ConvertTo-SecureString "your_database_name" -AsPlainText -Force
  # $secure_nm_sql_username = ConvertTo-SecureString "your_username" -AsPlainText -Force
  
  # Setting local variables
  $fp_project = "$fp_secrets\9-Publish\2-Depolyment"
  $nm_profile = "secrets-database.publish.xml"
  $fp_profile = Join-Path -Path $fp_project -ChildPath "\$nm_profile"

  # Database related paramters (update if needed)
  $Encrypt                = "False"  # Adjust to your requirements
  $Integrated_Security    = "False"  # Adjust to your requirements
  $TrustServerCertificate = "False"  # Adjust to your requirements

  # Ensure the directory exists
  $fp_project = Split-Path $fp_profile 
  if (-not (Test-Path $fp_profile)) { New-Item -ItemType Directory -Path $fp_profile -Force | Out-Null }

  # Create the XML content
  $tx_xml  = $emp + '<?xml version="1.0" encoding="utf-8"?>'
  $tx_xml += $nwl + '<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">'
  $tx_xml += $nwl + '  <PropertyGroup>'
  $tx_xml += $nwl + "  <TargetDatabaseName>$(ConvertTo-PlainText($secure_nm_sql_database))</TargetDatabaseName>"
  $tx_xml += $nwl + '  <TargetConnectionString>'
  $tx_xml += $nwl + "    Data Source=($(ConvertTo-PlainText($secure_nm_sql_server)));"
  $tx_xml += $nwl + "    Initial Catalog=($(ConvertTo-PlainText($secure_nm_sql_database)));"
  $tx_xml += $nwl + '    Integrated Security=True;'
  $tx_xml += $nwl + "    Encrypt=$Encrypt;"
  $tx_xml += $nwl + "    TrustServerCertificate=$TrustServerCertificate;"
  $tx_xml += $nwl + '  </TargetConnectionString>'
  $tx_xml += $nwl + "  <DeployScriptFileName>$nm_your_mdm.sql</DeployScriptFileName>"
  $tx_xml += $nwl + '  <ProfileVersionNumber>1</ProfileVersionNumber>'
  $tx_xml += $nwl + '  </PropertyGroup>'
  $tx_xml += $nwl + '</Project>'

  # Removce the file if it exists, so we can create a new one.
  if ((Test-Path $fp_profile)) {Remove-Item $fp_profile -Force } 

  # Write the XML content to the file
  $tx_xml | Out-File -FilePath $fp_profile -Encoding utf8 

}

if ($true) { Write-Output "# 6. Update `Project` with utilized Database version.";

    # Read the current version from the DSP file
    $fp_project = "$fp_secrets\Secrets-Database.sqlproj"

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

if ($true) { Write-Output "# 7. Build your `Secrets-Database` (dacpac).";

  # Search for SqlPackage.exe and store the first match in a variable
  $msbuild = Get-ChildItem -Path "C:\Program Files\Microsoft Visual Studio" -Recurse -Filter MSBuild.exe -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName

  # Build the SQL Database Project
  & "$msbuild" "$fp_secrets\Secrets-Database.sqlproj" `
      /p:Configuration=Debug `
      /p:DeployOnBuild=true `
      /p:PublishProfile="$fp_profile"

}

if ($true) { Write-Output "# 8. Publish `Secrets-Database` to database.";

  # Search for SqlPackage.exe and store the first match in a variable
  $sqlPackagePath = Get-ChildItem -Path "C:\" -Filter "SqlPackage.exe" -Recurse -ErrorAction SilentlyContinue -Force |
      Where-Object { $_.FullName -match "SqlPackage.exe" } |
      Select-Object -First 1 -ExpandProperty FullName

  # Run SqlPackage.exe to publish
  & "$sqlPackagePath" /Action:Publish `
      /SourceFile:"$fp_secrets\bin\Debug\Secrets-Database.dacpac" `
      /Profile:"$fp_profile" `
      /TargetServerName:"$(ConvertTo-PlainText($secure_nm_sql_server))" `
      /TargetDatabaseName:"$(ConvertTo-PlainText($secure_nm_sql_database))" `
      /TargetUser:"$(ConvertTo-PlainText($secure_nm_sql_username))" `
      /TargetPassword:"$(ConvertTo-PlainText($secure_nm_sql_password))"

}

Write-Output "All done, the `Secrets-Database` is now deployed to the database `$nm_database` on server `$nm_server`."

# Reset warning preference
$WarningPreference = "Continue" 
