# command line arguments
param (
    [switch]$available = $false,
    [switch]$init = $false,
    [switch]$setup = $false,
    [switch]$list = $false,
    [int]$major = 0
)

# Make sure we only attempt to work for PowerShell v5 and greater
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell v5.0+ is required for psperl. https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-6";
    exit
}
$psperl_path = (Split-Path -parent $MyInvocation.MyCommand.Definition);

# Import some Chocolatey goodness
# Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1" -Force;
Import-Module "$psperl_path\helpers\functions.psm1" -Force;

$global:DebugPreference = 'Continue'
if ($setup) {
    Setup $psperl_path;
}
elseif ($init) {
    Init $psperl_path;
}
elseif ($available) {
    $type = Get-Bits
    Write-Output "We're using PowerShell $($type) and will only display Perl versions of"
    Write-Output "that architecture type."
    Write-Output ""
    $data = Get-AvailablePerls | Where-Object {$_.archname -clike "*$($type)*"};
    if ($major -gt 0) {
        Write-Output "Perls available where major version is: $($major)"
        # Write-Output $versions;
        ForEach($row in ($data | Where-Object {$_.major -eq $major})) {
            Write-Output "   - perl-$($row.version)"
        }
    }
    else {
        Write-Output "The current release for each major Perl:"
        ForEach($row in ($data | Group-Object -Property major | Sort-Object -Descending -Property Name)) {
            # Write-Output $perls[$key];
            # Write-Output $row;
            Write-Output "   - perl-$($row | %{$_.Group[0].version})"
        }
    }
    Write-Output ""
}
# To turn on Debugging, $global:DebugPreference = 'Continue'
# To turn off Debugging, $global:DebugPreference = 'SilentlyContinue'

exit;
