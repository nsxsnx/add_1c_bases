$BasePath = "$($env:AppData)\1C\1CEStart\"
$ConfTemplate = "CommonInfoBases="

# Get bases list from AD security groups:
$Bases = @()
$DN = (New-Object System.DirectoryServices.DirectorySearcher("(&(objectCategory=User)(samAccountName=$($env:username)))")).FindOne().GetDirectoryEntry().Properties["distinguishedName"]
$UserGroups = (New-Object System.DirectoryServices.DirectorySearcher("(&(member:1.2.840.113556.1.4.1941:=$($DN))(description=*.v8i))")).FindALL()
foreach($Group in $UserGroups)
{
    $Bases += $Group.Properties["description"]
}

if (!$Bases)
{ 
    exit
}

# Create 1CEStart folder:
If(!(Test-Path $BasePath))
{
    New-Item -ItemType Directory -Force -Path $BasePath | out-null
}

# Make backup copy of 1CEStart.cfg, ibases.v8i
foreach($item in "1CEStart.cfg", "ibases.v8i")
{
    $File = $BasePath + $item
    $File_copy =  $BasePath + "Copy_" + $item
    If(!(Test-Path $File_copy))
    {
        If(Test-Path $File)
        {
            Copy-Item -Path $File -Destination $File_copy
        }
    }
}

# Remove old config:
$ConfFile = "$($BasePath)1CEStart.cfg"
If(Test-Path $ConfFile)
{
    Remove-Item $ConfFile
}

# Create new config:
foreach($item in $Bases)
{
    $ConfStr = $ConfTemplate + $item
    $ConfStr | Out-File -Append $ConfFile
}
"UseHWLicenses=0"  | Out-File -Append $ConfFile