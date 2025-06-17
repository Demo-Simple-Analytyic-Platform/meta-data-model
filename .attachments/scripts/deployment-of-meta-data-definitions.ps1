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
