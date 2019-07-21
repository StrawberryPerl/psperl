# command line arguments
param (
    [switch]$available = $false,
    [switch]$init = $false,
    [switch]$setup = $false,
    [switch]$list = $false,
    [string]$install = '',
    [int]$major = 0
)

# Make sure we only attempt to work for PowerShell v5 and greater
# this allows the use of classes.
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell v5.0+ is required for psperl. https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-6";
    exit
}
$psperl_path = (Split-Path -parent $MyInvocation.MyCommand.Definition);
$env:PSPERL_ROOT = $psperl_path;

# Import our classes
. "$($psperl_path)\src\PSPerl.ps1";
$psperl = [PSPerl]::new($psperl_path, $Profile);

$global:DebugPreference = 'Continue'
if ($setup) { $psperl.Setup(); }
elseif ($init) { $psperl.Init(); }
Write-Debug($psperl.ArchOS());
Write-Debug($psperl.ArchPS());
Write-Output($psperl.AvailablePerls());
# elseif ($available) {
#     $type = Get-Bits
#     Write-Output "We're using PowerShell $($type) and will only display Perl versions of"
#     Write-Output "that architecture type."
#     Write-Output ""
#     $data = Get-AvailablePerls | Where-Object {$_.archname -clike "*$($type)*"};
#     if ($major -gt 0) {
#         Write-Output "Perls available where major version is: $($major)"
#         # Write-Output $versions;
#         ForEach($row in ($data | Where-Object {$_.major -eq $major})) {
#             Write-Output "   - perl-$($row.version)"
#         }
#     }
#     else {
#         Write-Output "The current release for each major Perl:"
#         ForEach($row in ($data | Group-Object -Property major | Sort-Object -Descending -Property Name)) {
#             # Write-Output $perls[$key];
#             # Write-Output $row;
#             Write-Output "   - perl-$($row | %{$_.Group[0].version})"
#         }
#     }
#     Write-Output ""
# }
# elseif ($install) {
#     $type = Get-Bits
#     Write-Output "You'd like to install version $($install)"
#     Write-Output "We're going to see if we have that version available for"
#     Write-Output "your PowerShell system type: $($type)"
#     Write-Output ""
#     $data = Get-AvailablePerls | Where-Object {$_.archname -clike "*$($type)*"};
#     $found = $data | Where-Object {$_.version -eq $install.Replace("perl-", "")};
#     if (-Not $found) {
#         Write-Error "No installable version of Perl found by the name $($install)";
#         exit(1);
#     }
#     # this "grep" (Where-Object) is insane. If only one thing is found, it doesn't
#     # return a list with one item. It just returns the item. If more than one are
#     # found, then you get a list of items. -sigh
#     # List form: $found.GetType() = 'System.Object[]'
#     # Single Object form: $found.GetType() = 'System.Management.Automation.PSCustomObject'
#     Write-Output $found
#     Write-Output "Type is: $($found.GetType())"
# }
# # To turn on Debugging, $global:DebugPreference = 'Continue'
# # To turn off Debugging, $global:DebugPreference = 'SilentlyContinue'

exit;
