# Setting (these must be provide by developer):
$drive       = "D:"               # Drive where you git-folder should go.
$own_def     = "https://github.com/Demo-Simple-Analytyic-Platform/meta-def-example.git" # replace with your own repo
$nm_server   = "localdb"
$nm_database = "demo"


# Extraction of "Own" meta-data-model repository name.
$own = $own_def.Split("/")[-1] -replace "\.git$", ""

# Other variables
$git = "$drive\git"            # path to git-folder
$tmp = "$git\template"         # path to template-folde
$mdm = "$tmp\meta-data-def"    # path to (template) meta-data-model
$lcl = "$git\$own"             # path to (local) meta-data-model

# Suppress warning
$WarningPreference = "SilentlyContinue"


echo "# 1. Check if the folders exists, if not create them."
if (-Not (Test-Path -Path $git)) { New-Item -Path $git -ItemType Directory -Force }
if (-Not (Test-Path -Path $tmp)) { New-Item -Path $tmp -ItemType Directory -Force }
if (-Not (Test-Path -Path $mdm)) { New-Item -Path $mdm -ItemType Directory -Force }
if (-Not (Test-Path -Path $lcl)) { New-Item -Path $lcl -ItemType Directory -Force }


echo "# 2. Clone this meta-data-def repository to the ""\git\template\""-folder. remember, this repo is publicly accessiable and ""readonly"" for all but the ""owners""."
git clone https://github.com/Demo-Simple-Analytyic-Platform/meta-data-def.git "$mdm" 2>$null


echo "# 3. Clone ""your"" repo for the ""Meta-Data-Def"" to ""\git\""-folder, to make if locally aviable, initially this should be completely empty."
git clone $own_def $lcl 2>$null


echo "# 4. Copy past everthing from the template to local version of your ""meta-data-model""-repository."
if (Test-Path $lcl) { Get-ChildItem -Path $lcl -Recurse -Force | Remove-Item -Recurse -Force } 
else { New-Item -Path $lcl -ItemType Directory -Force} 
# Then copy and paste everthing
Get-ChildItem -Path $mdm -Force | Where-Object { $_.Name -ne ".git" } | ForEach-Object { Copy-Item -Path $_.FullName -Destination $lcl -Recurse -Force }

echo "# 5. Updating PublishProfiel for `LocalDB`."
$projectDir  = "$lcl\meta-data-model\9-Publish\2-Depolyment"
$profileName = "LocalDB-Demo.publish.xml"
$profilePath = Join-Path -Path $projectDir -ChildPath "\$profileName"
$profileDir  = Split-Path $profilePath
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null}

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
$xmlContent | Out-File -FilePath $profilePath -Encoding utf8


echo "# 5. Updating PublishProfiel for `LocalDB`."

$projectDir  = "$lcl\meta-data-model\9-Publish\2-Depolyment"
$profileName = "LocalDB-Demo.publish.xml"
$profilePath = Join-Path -Path $projectDir -ChildPath "\$profileName"
$profileDir  = Split-Path $profilePath
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null}

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