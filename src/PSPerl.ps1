class PSPerl {
    hidden [String] $URL;
    hidden [String] $rootPath;
    hidden [String] $profilePath;

    # Constructor
    PSPerl([string]$rootPath, [string]$profilePath) {
        if(![System.IO.Directory]::Exists($rootPath)) {
            Write-Error "Invalid root path provided";
            exit(1);
        }
        $this.URL = 'http://strawberryperl.com/releases.json';
        $this.rootPath = $rootPath;
        $this.profilePath = $profilePath;
    }

    # Return the operating system's bitness. will be 64 or 32
    [int] ArchOS() {
        $the_bits = ((Get-WmiObject Win32_OperatingSystem).OSArchitecture).Replace('-bit', '');
        if ($the_bits -eq '64') { return 64; }
        elseif ($the_bits -eq '32') { return 32; }
        Write-Error("Invalid OS Architecture? We don't know what to do with a $($the_bits)-bit architecture");
        exit(1);
    }

    # return the current PowerShell's bitness. will be 64 or 32. might not be the same as the OS
    [int] ArchPS() {
        $the_bits = [System.Runtime.InterOpServices.Marshal]::SizeOf([System.IntPtr]::Zero)*8;
        if ($the_bits -eq '64') { return 64; }
        elseif ($the_bits -eq '32') { return 32; }
        Write-Error("Invalid PowerShell Architecture? We don't know what to do with a $($the_bits)-bit PowerShell");
        exit(1);
    }

    # get an array of available Portable Perl versions
    [Array] AvailablePerls() {
        # Ensures that Invoke-WebRequest uses TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Debug("About to lookup $($this.URL)");
        $res = Invoke-RestMethod -Uri $this.URL -Method Get -Headers @{'Accept'='Application/json'}
        $all_portables = @();
        foreach ($row in $res) {
            # only use the info for the ones with the portable edition
            if ([bool]($row.PSobject.Properties.Name -contains 'edition') -And [bool]($row.edition.PSObject.Properties.Name -contains 'portable')) {
                # move edition info into the base object
                $row | Add-Member -Name "sha1" -Type NoteProperty -Value $row.edition.portable.sha1;
                $row | Add-Member -Name "sha256" -Type NoteProperty -Value $row.edition.portable.sha256;
                $row | Add-Member -Name "size" -Type NoteProperty -Value $row.edition.portable.size;
                $row | Add-Member -Name "url" -Type NoteProperty -Value $row.edition.portable.url;
                $row.PSObject.Properties.Remove('edition');
                # add some extra object members for version lookup simplicity later
                $perl, $major, $minor, $rel = $row.version.split('.');
                $row | Add-Member -Name "Perl" -Type NoteProperty -Value $perl;
                $row | Add-Member -Name "major" -Type NoteProperty -Value $major;
                $row | Add-Member -Name "minor" -Type NoteProperty -Value $minor;
                $row | Add-Member -Name "rel" -Type NoteProperty -Value $rel;
                # add an x64 and a 'USE_64_BIT_INT' field that's true/false
                $row | Add-Member -Name "x64" -Type NoteProperty -Value $false;
                $row | Add-Member -Name "USE_64_BIT_INT" -Type NoteProperty -Value $false;
                if ($row.archname -clike "*x64*") { $row.x64 = $true; }
                if ($row.archname -clike "*-64int") { $row.USE_64_BIT_INT = $true; }
                $all_portables += , $row;
            }
        }
        if ($this.ArchOS() -eq 32) {
            return @(,($all_portables | Where-Object {!$_.x64}))
        }
        return $all_portables;
    }

    [void] ClearEnvironment() {
        # Write-Output "Cleaning your environment of any and all Perl variables";
        # remove any set Perl/local::lib variables
        if (Test-Path 'env:TERM') { Remove-Item env:\TERM }
        if (Test-Path 'env:PERL_JSON_BACKEND') { Remove-Item env:\PERL_JSON_BACKEND }
        if (Test-Path 'env:PERL_YAML_BACKEND') { Remove-Item env:\PERL_YAML_BACKEND }
        if (Test-Path 'env:PERL5LIB') { Remove-Item env:\PERL5LIB }
        if (Test-Path 'env:PERL5OPT') { Remove-Item env:\PERL5OPT }
        if (Test-Path 'env:PERL_MM_OPT') { Remove-Item env:\PERL_MM_OPT }
        if (Test-Path 'env:PERL_MB_OPT') { Remove-Item env:\PERL_MB_OPT }
        if (Test-Path 'env:PERL_LOCAL_LIB_ROOT') { Remove-Item env:\PERL_LOCAL_LIB_ROOT }

        # Write-Output "Path to PSPerl is: $($this.rootPath)"
        # Go through the PATH and remove Perl-related items
        $good_array = @();
        $array = $env:Path.split(";", [System.StringSplitOptions]::RemoveEmptyEntries) | Select-Object -uniq
        Foreach ($item in $array) {
            if (-not $item.StartsWith($($this.rootPath))) {
                $good_array += ,$item;
            }
        }
        $env:Path = $good_array -join ';'
        return;
    }

    [void] Init() {
        $this.ClearEnvironment();
        $env:Path = "$($this.rootPath);$env:Path";
        return;
    }

    [void] Setup() {
        # check to ensure the $this.profilePath exists
        if(![System.IO.File]::Exists($this.profilePath)) {
            Write-Host("You don't yet have a profile at $($this.profilePath). We'll set that up now.");
            # this is like touch filename in linux
            New-Item -ItemType file $this.profile
        }
        $init_content = "# PSPerl Initialize`r`n& $($this.rootPath)\psperl.ps1 -Init"
        $found = Select-String -Quiet -Pattern "^# PSPerl Init" -Path $this.profile
        if (-not $found) {
            Add-Content -Path $this.profilePath -Value "`r`n$init_content"
        }

        # check to ensure the config directory exists
        if(![System.IO.Directory]::Exists("$($this.rootPath)\_config")) {
            Write-Host("You don't yet have a configuration directory.");
            # this is like touch filename in linux
            New-Item -ItemType directory "$($this.rootPath)\_config"
        }

        Write-Host("Your profile is located at:  $($this.profilePath)");
        Write-Host("Your config directory is at: $($this.rootPath)\_config");
        return;
    }
}
