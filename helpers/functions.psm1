# Import some of our own functions
# grab functions from files
$helpersPath = (Split-Path -parent $MyInvocation.MyCommand.Definition);

Get-Item $helpersPath\functions\*.ps1 |
  ? { -not ($_.Name.Contains(".Tests.")) } |
    % {
      . $_.FullName;
      #Export-ModuleMember -Function $_.BaseName
    }

# Export built-in functions prior to loading extensions so that
# extension-specific loading behavior can be used based on built-in
# functions. This allows those overrides to be much more deterministic
# This behavior was broken from v0.9.9.5 - v0.10.3.
Export-ModuleMember -Function * -Alias * -Cmdlet *
