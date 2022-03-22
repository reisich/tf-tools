function tf-init {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$env  
    )
    
    # remove state files
    if (Test-Path .\.terraform\) { Remove-Item .\.terraform -Force }

    # set env config file
    if (Test-Path ("$(Get-Location)\config\$($env)_backend.tfvars")) {
        terraform init -backend-config="$(Get-Location)\config\$($env)_backend.tfvars"
    }
    
}

function tf-plan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$env  
    )

    # set env config file
    if (Test-Path ("$(Get-Location)\config\$($env)_backend.tfvars")) {
        terraform plan -var-file="$(Get-Location)\config\$($env).tfvars"
    }

}

function tf-apply {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$env  
    )

    # set env config file
    if (Test-Path ("$(Get-Location)\config\$($env)_backend.tfvars")) {
        terraform apply -var-file="$(Get-Location)\config\$($env).tfvars"
    }

}


function tf-version {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$version = 'latest'
    )

    #config 
    If (Test-Path 'D:\apps\terraform\') { $binaryPath = 'D:\apps\terraform\' } else { $binaryPath = 'C:\data\apps\terraform\' }
    


    # set latest version of terraform
    if ($version -eq 'latest') {
        $version = (Invoke-RestMethod -Uri "https://checkpoint-api.hashicorp.com/v1/check/terraform" -ErrorAction Stop).current_version
        Write-host "latest version: $version"
    }

    # create working folders
    if (!(Test-Path $binaryPath\tmp)) { New-Item -ItemType Directory -Path $binaryPath\tmp | out-null }
    if (!(Test-Path $binaryPath\versions)) { New-Item -ItemType Directory -Path $binaryPath\versions | out-null }

    # download if requested file is not present
    if (!(Test-Path "$binaryPath\versions\terraform_$($version).exe")) {
        try {
            Invoke-WebRequest "https://releases.hashicorp.com/terraform/$($version)/terraform_$($version)_windows_amd64.zip" -OutFile "$binaryPath\tmp\dl.zip" -Erroraction Stop
        }
        catch {
            throw "Could not find version: $version" 
            Remove-Item $binaryPath\tmp\dl.zip -Force
        }
        
        Expand-Archive -LiteralPath "$binaryPath\tmp\dl.zip" -DestinationPath "$binaryPath\tmp" -Force
        Remove-Item $binaryPath\tmp\dl.zip -Force
        Copy-Item "$binaryPath\tmp\terraform.exe" -Destination "$binaryPath\versions\terraform_$($version).exe"
        Copy-Item "$binaryPath\versions\terraform_$($version).exe" -Destination "$binaryPath\terraform.exe" -Force

    }
    else {
        Copy-Item "$binaryPath\versions\terraform_$($version).exe" -Destination "$binaryPath\terraform.exe" -Force
    }

}