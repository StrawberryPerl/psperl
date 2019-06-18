<#
.SYNOPSIS
    Get the available Portable Strawberry Perls

.DESCRIPTION
    Grabs a list of available Portable Perl installations
        - $env:http_proxy environment variable
        - IE proxy
        - Chocolatey config
        - Winhttp proxy
        - WebClient proxy

    Use Verbose parameter to see which of the above locations was used for the result, if any.
    The function currently doesn't handle the proxy username and password.

.OUTPUTS
    [Object] hash of available Perls at Major version level
#>
function Get-AvailablePerls(){
    $is64bit = If ($env:Processor_Architecture -eq "x86") {$true} Else {$false}

    # Ensures that Invoke-WebRequest uses TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $url = 'http://strawberryperl.com/releases.json'
    $opts = @{ Headers = @{ Accept = 'application/json' } }
    # Write-Debug "list: grabbing list of available Portable Perls";
    $res = Invoke-WebRequest $url | ConvertFrom-Json
    # Write-Debug $content
    # $res = Invoke-RestMethod -Uri $url #  | ConvertFrom-Json | select -expand *
    # {
    #     "28" = @{
    #        "0.1" = @{
    #             'x86_w64int' = 'http://foo',
    #             'x86' = 'http://foo',
    #             'x64' = 'http://foo',
    #             'x64_ld' = 'http://foo'
    #             }
    #         }
    #     )
    # }
    $perls = @{}
    $num_to_pretty = @{};
    # make sure all keys are stored as strings for later simplicity
    ForEach ($row in $res) {
        # if ($is64bit -And [bool]($row.PSobject.Properties))
        if ([bool]($row.PSobject.Properties.Name -contains 'edition') -And [bool]($row.edition.PSObject.Properties.Name -contains 'portable')) {
            $perl, $major, $minor, $rel = $row.version.split('.');
            if (-Not $perls.ContainsKey($major.toString())) {
                $perls.Add($major.toString(), @{});
            }
            if (-Not $perls[$major.toString()].ContainsKey($row.numver.toString())) {
                $perls[$major].Add($row.numver.toString(), @{});
                $num_to_pretty.Add($row.numver.toString(), $row.version)
            }
            $perls[$major][$row.numver.toString()].Add($row.archname.toString(), $row.edition.portable.url);
        }
    }
    # $data = ConvertFrom-Json -InputObject $content
    # Write-Debug $data
    @{'perls' = $perls; 'versions' = $num_to_pretty}
}
