<#
.SYNOPSIS
    Setup PSPerl

.DESCRIPTION
    Ensure the config directory is there. Ensure we have PSPerl setup in our $Profile.

#>
function Setup {
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $psperl_path
    )
    # check to ensure the $Profile exists
    if(![System.IO.File]::Exists($Profile)) {
        Write-Output "You don't yet have a profile at $Profile. We'll set that up now.";
        # this is like touch filename in linux
        New-Item -ItemType file $Profile
    }
    $init_content = "# PSPerl Initialize`r`n& $psperl_path\psperl.ps1 -Init"
    $found =  Select-String -Quiet -Pattern "^# PSPerl Init" -Path $Profile
    if (-not $found) {
        Add-Content -Path $Profile -Value "`r`n$init_content"
    }

    # check to ensure the config directory exists
    if(![System.IO.Directory]::Exists("$psperl_path\_config")) {
        Write-Output "You don't yet have a configuration directory.";
        # this is like touch filename in linux
        New-Item -ItemType directory "$psperl_path\_config"
    }

    Write-Output "Your profile is located at:  $Profile"
    Write-Output "Your config directory is at: $psperl_path\_config"
    Init $psperl_path;
}
