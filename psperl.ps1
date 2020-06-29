# command line arguments
param (
    [switch]$available = $false,
    [switch]$init = $false,
    [switch]$setup = $false,
    [switch]$list = $false,
    [switch]$version = $false,
    [switch]$v = $false,
    [string]$install = '',
    [string]$switch = '',
    [string]$use = '',
    [int]$major = 0
)

# Make sure we only attempt to work for PowerShell v5 and greater
# this allows the use of classes.
if ($PSVersionTable.PSVersion.Major -lt 5) {
    throw "PowerShell v5.0+ is required for psperl. https://docs.microsoft.com/en-us/powershell/scripting/setup/installing-windows-powershell?view=powershell-6";
}
$psperl_path = (Split-Path -parent $MyInvocation.MyCommand.Definition);
$env:PSPERL_ROOT = $psperl_path;
$env:PSPERL_VERSION = '0.1.0';

# Import our classes
. "$($psperl_path)\src\PSPerl.ps1";
$psperl = [PSPerl]::new($psperl_path, $Profile);

$global:DebugPreference = 'Continue'
if ($setup) { $psperl.Setup(); }
elseif ($init) { $psperl.Init(); }
elseif ($available) {
    [int]$ps_bits = $psperl.ArchPS();
    [int]$os_bits = $psperl.ArchOS();
    Write-Host("We're using a $($ps_bits)-bit PowerShell on a $($os_bits)-bit Windows OS.");
    Write-Host("On 64-bit Windows:");
    Write-Host("    32-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT Perls without problem.");
    Write-Host("                       You _can_ use 64-bit Perls, but may run into trouble. RISK");
    Write-Host("    64-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT, or 64-bit Perls.");
    Write-Host("On 32-bit Windows:");
    Write-Host("    You can only use 32-bit or 32-bit with USE_64_BIT_INT Perls");
    Write-Host("");
    [array]$data = $psperl.AvailablePerls();
    if ($major -gt 0) {
        Write-Host("Perls available where major version is: $($major)");
        Write-Host("");
        if ($os_bits -eq 64) {
            [String]$message = '64-bit Perls';
            if ($ps_bits -ne 64) { $message = "$($message) (RISKY on a 32-bit PS)"}
            Write-Host("$($message):");
            ForEach($row in ($data | Where-Object {($_.x64) -And ($_.major -eq $major)})) {
                Write-Host("   - $($row.install_name)");
            }
        }
        Write-Host("");
        Write-Host("32-bit with USE_64_BIT_INT Perls:")
        ForEach($row in ($data | Where-Object {(-Not $_.x64) -And ($_.USE_64_BIT_INT) -And ($_.major -eq $major)})) {
            Write-Host("   - $($row.install_name)");
        }
        Write-Host("");
        Write-Host("32-bit Perls:")
        ForEach($row in ($data | Where-Object {(-Not $_.x64) -And (-Not $_.USE_64_BIT_INT) -And ($_.major -eq $major)})) {
            Write-Host("   - $($row.install_name)");
        }
    }
    else {
        Write-Host("The current release for each major Perl:");
        Write-Host("");
        if ($os_bits -eq 64) {
            [String]$message = '64-bit Perls';
            if ($ps_bits -ne 64) { $message = "$($message) (RISKY on a 32-bit PS)"}
            Write-Host("$($message):");
            ForEach($row in ($data | Where-Object {($_.x64)} | Group-Object -Property major | Sort-Object -Descending -Property Name)) {
                Write-Host("   - $($row | ForEach-Object {$_.Group[0].install_name})");
            }
        }
        Write-Host("");
        Write-Host("32-bit with USE_64_BIT_INT Perls:")
        ForEach($row in ($data | Where-Object {(-Not $_.x64) -And ($_.USE_64_BIT_INT)} | Group-Object -Property major | Sort-Object -Descending -Property Name)) {
            Write-Host("   - $($row | ForEach-Object {$_.Group[0].install_name})");
        }
        Write-Host("");
        Write-Host("32-bit Perls:")
        ForEach($row in ($data | Where-Object {(-Not $_.x64) -And (-Not $_.USE_64_BIT_INT)} | Group-Object -Property major | Sort-Object -Descending -Property Name)) {
            Write-Host("   - $($row | ForEach-Object {$_.Group[0].install_name})");
        }
    }
    Write-Host("");
}
elseif ($install) {
    Write-Host("You'd like to install version $($install). Let's see what we can do.");
    [array]$data = $psperl.AvailablePerls();

    # grep through our available perls for the one specified by name.
    # this "grep" (Where-Object) is insane. If only one thing is found, it doesn't
    # return a list with one item. It just returns the item. If more than one are
    # found, then you get a list of items. -sigh
    # List form: $found.GetType() = 'System.Object[]'
    # Single Object form: $found.GetType() = 'System.Management.Automation.PSCustomObject'
    $found = $data | Where-Object {$_.install_name -eq $install};

    # if nothing is found, a null thingy is returned. This can be tested with a simple truthiness test
    if (-Not $found) {
        throw "No installable version of Perl found by the name $($install). Try `"psperl -available`" to get a list of available perl installations.";
    }
    # check to see if we got just one.
    if ($found -is 'System.Object') {
        $psperl.Install($found);
    }
    else {
        throw "Unexpected results `"$($found.GetType())`" searching for `"$($install)`". Try `"psperl -available`" to get a list of available perl installations.";
    }
}
elseif ($switch) { $psperl.Use($switch, $true); }
elseif ($use) { $psperl.Use($use, $false); }
elseif ($list) {
    Write-Host("Perls installed on your system: ");
    Write-Host("");
    ForEach ($dir in (Get-ChildItem -Path "$($env:PSPERL_ROOT)\_perls" -Directory)) {
        Write-Host("    $($dir.Name)");
    }
}
elseif ($version -or $v) {
    Write-Host("This is PSPerl v$($env:PSPERL_VERSION)");
    Write-Host("");
    Write-Host("Directories of note:")
    Write-Host("$($env:PSPERL_ROOT)\_config");
    Write-Host("$($env:PSPERL_ROOT)\_locals");
    Write-Host("$($env:PSPERL_ROOT)\_perls");
    Write-Host("$($env:PSPERL_ROOT)\_zips");
    Write-Host("");
    Write-Host("https://github.com/genio/psperl");
    Write-Host("");
}
# To turn on Debugging, $global:DebugPreference = 'Continue'
# To turn off Debugging, $global:DebugPreference = 'SilentlyContinue'

exit;
