Param (
    [Parameter(Mandatory)]
    [string]$TargetPath,
    [Parameter(Mandatory)]
    [string]$UserFilter
)

remove-item "export.json"

$origworkingdirectory = Get-Location

Set-Location $TargetPath

$export = @()

Get-ChildItem -path $TargetPath -Directory -Recurse | Select-Object -ExpandProperty "Fullname" | ForEach-Object {
    $path = $_
    $access = @();

    Write-Host $path

    Get-Acl $path | Select-Object -ExpandProperty "access" |  where-object {$_.IdentityReference -like "*$UserFilter*" -and $_.IsInherited -eq $false} | ForEach-Object {
        $access += @{
            AccessObject = ($_ | select-object -Property *);
            Readable = "Identity: $($_.IdentityReference); Rights:$($_.FileSystemRights); Type:$($_.AccessControlType)"
        }
    } 

    $export += @{
        FullPath = $path;
        Path = Resolve-Path $path -Relative
        Access = $access
    }
}

Set-Location $origworkingdirectory

$export | convertto-json -Depth 99 > "export.json"
