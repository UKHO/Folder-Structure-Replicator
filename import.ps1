Param (
    [Parameter(Mandatory)]
    [string]$TargetPath,
    [string]$JsonFileLocation = "export.json"
)

if(!(Test-Path -Path $TargetPath )){
    Write-Host "Target path $targetPath does not exist"
    Exit
}

$origworkingdirectory = Get-Location

$importJson = (Get-Content $JsonFileLocation | ConvertFrom-Json)

Set-Location $TargetPath


$importJson | ForEach-Object {
    New-Item -Name $_.Path -ItemType Directory
}

$importJson | ForEach-Object {
    $folderAcl = $null
    $path = $_.Path
    $_.Access | ForEach-Object {
        if ($null -eq $folderAcl)
        {
            $folderAcl = Get-Acl $path
        }
        

        $identityReference = $_.AccessObject.IdentityReference.Value
        $fileSystemRights = [System.Security.AccessControl.FileSystemRights][int]$_.AccessObject.FileSystemRights
        $inheritanceFlags = [System.Security.AccessControl.InheritanceFlags][int]$_.AccessObject.InheritanceFlags
        $propagationFlags = [System.Security.AccessControl.PropagationFlags][int]$_.AccessObject.PropagationFlags 
        $accessControlType = [System.Security.AccessControl.AccessControlType][int]$_.AccessObject.AccessControlType
        

        $accessObject = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $identityReference, $fileSystemRights, $inheritanceFlags, $propagationFlags, $accessControlType
        if ($null -ne $folderAcl)
        {
        $folderAcl.SetAccessRule($accessObject)
        }
        
    }
    if ($null -ne $folderAcl)
    {
        $folderAcl | Set-Acl $path
    }
    Write-Host "Finsihed Setting ACL for folder $path"
}

Write-Host "Finsihed Script"
Set-Location $origworkingdirectory
