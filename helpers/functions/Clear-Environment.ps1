<#
.SYNOPSIS
    Clear current ENV variables of anything PSPerl-related

.DESCRIPTION
    Clear the environment variables of all Perl related items.

#>
function Clear-Environment {
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string] $psperl_path
    )
    Write-Output "Cleaning your environment of any and all Perl variables";
    # remove any set Perl/local::lib variables
    if (Test-Path 'env:TERM') { Remove-Item env:\TERM }
    if (Test-Path 'env:PERL_JSON_BACKEND') { Remove-Item env:\PERL_JSON_BACKEND }
    if (Test-Path 'env:PERL_YAML_BACKEND') { Remove-Item env:\PERL_YAML_BACKEND }
    if (Test-Path 'env:PERL5LIB') { Remove-Item env:\PERL5LIB }
    if (Test-Path 'env:PERL5OPT') { Remove-Item env:\PERL5OPT }
    if (Test-Path 'env:PERL_MM_OPT') { Remove-Item env:\PERL_MM_OPT }
    if (Test-Path 'env:PERL_MB_OPT') { Remove-Item env:\PERL_MB_OPT }
    if (Test-Path 'env:PERL_LOCAL_LIB_ROOT') { Remove-Item env:\PERL_LOCAL_LIB_ROOT }

    # Write-Output "Path to PSPerl is: $psperl_path"
    # Go through the PATH and remove Perl-related items
    $good_array = @();
    $array = $env:Path.split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select -uniq
    Foreach ($item in $array) {
        if (-not $item.StartsWith($psperl_path)) {
            $good_array += ,$item;
        }
    }
    $env:Path = $good_array -join ';'
}
