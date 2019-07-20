<#
.SYNOPSIS
    Determine if we're on 64-bit PS or 32-bit PS.

.DESCRIPTION
    Grab the size of an int pointer to determine if we're on the
    - 64-bit version of PS (system32)
    - 32-bit version of PS (SysWOW64)

    Note that we're not checking the system architecture because
    that would be pointless to check on a 64-bit system running
    the 32-bit PowerShell.
#>
function Get-Bits {
    $val = "x64"
    Switch ([System.Runtime.InterOpServices.Marshal]::SizeOf([System.IntPtr]::Zero)) {
        4 {$val = "x86"; break}
        8 {$val = "x64"; break}
        default {$val = "x64"; break}
    }
    $val
}
