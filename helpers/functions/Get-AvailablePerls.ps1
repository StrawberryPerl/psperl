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
function Get-AvailablePerls {
    $url = 'http://strawberryperl.com/releases.json'
    $is64bit = If ($env:Processor_Architecture -eq "x86") {$true} Else {$false}
    # Ensures that Invoke-WebRequest uses TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $res = Invoke-RestMethod -Uri $url -Method Get -Headers @{'Accept'='Application/json'}
    $all_portables = @();
    foreach ($row in $res) {
        if ([bool]($row.PSobject.Properties.Name -contains 'edition') -And [bool]($row.edition.PSObject.Properties.Name -contains 'portable')) {
            $row | Add-Member -Name "sha1" -Type NoteProperty -Value $row.edition.portable.sha1;
            $row | Add-Member -Name "sha256" -Type NoteProperty -Value $row.edition.portable.sha256;
            $row | Add-Member -Name "size" -Type NoteProperty -Value $row.edition.portable.size;
            $row | Add-Member -Name "url" -Type NoteProperty -Value $row.edition.portable.url;
            $row.PSObject.Properties.Remove('edition');
            $perl, $major, $minor, $rel = $row.version.split('.');
            $row | Add-Member -Name "Perl" -Type NoteProperty -Value $perl;
            $row | Add-Member -Name "major" -Type NoteProperty -Value $major;
            $row | Add-Member -Name "minor" -Type NoteProperty -Value $minor;
            $row | Add-Member -Name "rel" -Type NoteProperty -Value $rel;

            $all_portables += , $row;
        }
    }
    $all_portables
}
