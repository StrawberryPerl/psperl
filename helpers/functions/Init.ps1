<#
.SYNOPSIS
    Initialize PSPerl

.DESCRIPTION
    Clear the environment variables of all Perl related items. Ensures the
    directory containing the psperl app is in the PATH.

#>
function Init {
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $psperl_path
    )
    Clear-Environment $psperl_path;
    $env:Path = "$psperl_path;$env:Path"
}
