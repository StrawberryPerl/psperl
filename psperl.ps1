# command line arguments
param (
    [switch]$available = $false,
    [switch]$init = $false,
    [switch]$setup = $false,
    [int]$major = 0
)

# Make sure we only attempt to work for PowerShell v5 and greater
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell v5.0+ is required for psperl. https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-6";
    exit
}
$psperl_path = (Split-Path -parent $MyInvocation.MyCommand.Definition);

# Import some Chocolatey goodness
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1" -Force;
Import-Module "$psperl_path\helpers\functions.psm1" -Force;

$global:DebugPreference = 'Continue'
if ($setup) {
    Setup $psperl_path;
}
elseif ($init) {
    Init $psperl_path;
}
elseif ($available) {
    $data = Get-AvailablePerls;
    $perls = $data['perls']
    $versions = $data['versions']
    Write-Output "Major contains $($major)"
    if ($major -gt 0) {
        Write-Output $versions;
        ForEach($key in $perls[$major.toString()].Keys.Clone()) {
            Write-Output ""
            Write-Output "   * perl-$($key)"
        }
    }
    else {
        # Write-Output $versions;
        # Write-Output $perls;
        ForEach($key in ($perls.Keys.Clone()) | Sort-Object -Descending) {
            Write-Output $key;
            # Write-Output $perls[$key];
            $max = (($perls[$key].Keys | Measure-Object -Maximum).Maximum).toString()
            $val = $versions.item($max)
            Write-Output "   * perl-$($val)"
        }
    }
}
# To turn on Debugging, $global:DebugPreference = 'Continue'
# To turn off Debugging, $global:DebugPreference = 'SilentlyContinue'

exit;
# call refreshenv from chocolatey
# Update-SessionEnvironment
