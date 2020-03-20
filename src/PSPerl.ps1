class PSPerl {
    hidden [String] $URL;
    hidden [String] $rootPath;
    hidden [String] $profilePath;
    hidden [System.Object] $settings;

    # Constructor
    PSPerl([string]$rootPath, [string]$profilePath) {
        if(![System.IO.Directory]::Exists($rootPath)) {
            throw "Invalid root path provided";
        }
        $this.URL = 'http://strawberryperl.com/releases.json';
        $this.rootPath = $rootPath;
        $this.profilePath = $profilePath;
        $this.LoadSettings();
        $this.SaveSettings();
    }

    # Return the operating system's bitness. will be 64 or 32
    [int] ArchOS() {
        $the_bits = (Get-CimInstance Win32_OperatingSystem).OSArchitecture;
        if ($the_bits -match '64') { return 64; }
        elseif ($the_bits -match '32') { return 32; }
        throw "Invalid OS Architecture? We don't know what to do with a `"$($the_bits)`" architecture";
    }

    # return the current PowerShell's bitness. will be 64 or 32. might not be the same as the OS
    [int] ArchPS() {
        $the_bits = [System.Runtime.InterOpServices.Marshal]::SizeOf([System.IntPtr]::Zero)*8;
        if ($the_bits -eq '64') { return 64; }
        elseif ($the_bits -eq '32') { return 32; }
        throw "Invalid PowerShell Architecture? We don't know what to do with a $($the_bits)-bit PowerShell";
    }

    # get an array of available Portable Perl versions
    [Array] AvailablePerls() {
        [String]$cache_file = "$($this.rootPath)\_config\_release_cache.json";
        [Array]$all_portables = @();
        # check to see if we have a cached copy of the data first
        if (Test-Path $cache_file -NewerThan (Get-Date).AddHours(-1).AddMinutes(-30)) {
            $all_portables = (Get-Content -Raw -Path $cache_file | ConvertFrom-Json)
            return $all_portables;
        }

        # Ensures that Invoke-WebRequest uses TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $res = Invoke-RestMethod -Uri $this.URL -Method Get -Headers @{'Accept'='Application/json'}

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
                [int]$perl, [int]$major, [int]$minor, [int]$rel = $row.version.split('.');
                $row | Add-Member -Name "Perl" -Type NoteProperty -Value $perl;
                $row | Add-Member -Name "major" -Type NoteProperty -Value $major;
                $row | Add-Member -Name "minor" -Type NoteProperty -Value $minor;
                $row | Add-Member -Name "rel" -Type NoteProperty -Value $rel;
                # add an x64 and a 'USE_64_BIT_INT' field that's true/false
                $row | Add-Member -Name "x64" -Type NoteProperty -Value $false;
                $row | Add-Member -Name "USE_64_BIT_INT" -Type NoteProperty -Value $false;
                $row | Add-Member -Name "install_name" -Type NoteProperty -Value "perl32-$($row.version)";
                if ($row.archname -clike "*x64*") {
                    $row.x64 = $true;
                    $row.install_name = "perl64-$($row.version)";
                }
                else {
                    if ($row.archname -clike "*-64int") {
                        $row.USE_64_BIT_INT = $true;
                        $row.install_name = "perl32w64int-$($row.version)";
                    }
                }
                $all_portables += , $row;
            }
        }
        # on a 64-bit OS, we can use either 32- or 64-bit Portables
        if ($this.ArchOS() -eq 32) {
            # on a 32-bit OS, filter out all 64-bit Portables
            $all_portables = @(,($all_portables | Where-Object {-Not $_.x64}))
        }
        # save our data to the cache file
        $all_portables | ConvertTo-Json -depth 100 -Compress | Out-File $cache_file
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
        if ($this.settings.current) { $this.Use($this.settings.current, $false); }
        return;
    }

    [void] Install([System.Object]$perl_obj) {
        Write-Host("Attempting to install $($perl_obj.install_name)");
        [String]$pathDir = "$($this.rootPath)\_perls\$($perl_obj.install_name)";
        if ([System.IO.Directory]::Exists($pathDir)) {
            Write-Host("");
            Write-Host("Perl $($perl_obj.install_name) is already installed. Try using it with:");
            Write-Host("");
            Write-Host("    psperl -use $($perl_obj.install_name)     # temporary. this session");
            Write-Host("    psperl -switch $($perl_obj.install_name)  # permanent. this and every subsequent session");
            Write-Host("");
            return;
        }

        [String]$pathZip = "$($this.rootPath)\_zips\$($perl_obj.install_name).zip";
        if (![System.IO.File]::Exists($pathZip)) {
            # 150743342
            Write-Host("Downloading $($perl_obj.url). This may take some time as it's $($perl_obj.size) bytes.");
            Invoke-WebRequest -Uri $perl_obj.url -OutFile $pathZip
        }

        # we SHOULD now have the file
        if ([System.IO.File]::Exists($pathZip)) {
            # check to make sure we got the right size file
            [int]$size = (Get-Item $pathZip).length;
            if ($size -ne $perl_obj.size) {
                Remove-Item -Path $pathZip -Force;
                throw "The file we have is $($size) bytes but we expected $($perl_obj.size). Deleting the file.";
            }
            # check the SHA1 checksums
            [String]$checksum = (Get-FileHash -Path $pathZip -Algorithm SHA1).hash;
            if ($checksum -ne $perl_obj.sha1) {
                Remove-Item -Path $pathZip -Force;
                throw "The file's SHA1 checksum is off. Deleting the file.";
            }
        }
        else {
            throw "We tried to download the file, but we didn't get it.";
        }

        # extract the zip into the directory
        Write-Host("Found $($pathZip) with the correct size and SHA1 checksum. Extracting.");
        Expand-Archive $pathZip -DestinationPath $pathDir;
        Write-Host("");
        Write-Host("Installed $($perl_obj.install_name) in $($pathDir). Try using it with:");
        Write-Host("");
        Write-Host("    psperl -use $($perl_obj.install_name)     # temporary. this session");
        Write-Host("    psperl -switch $($perl_obj.install_name)  # permanent. this and every subsequent session");
        Write-Host("");
    }

    [array] InstalledPerls() {
        return [Array]((Get-ChildItem -dir "$($this.rootPath)\_perls").Name);
    }

    # Load in some info about what it is we're doing here.
    [void] LoadSettings() {
        # start out here
        $this.settings = New-Object -TypeName PSCustomObject -Property @{
            current = ''
            is_on = $true
        };
        # we could be attempting to read settings prior to setup
        if (![System.IO.Directory]::Exists("$($this.rootPath)\_config")) {
            return;
        }

        [String]$settingsPath = "$($this.rootPath)\_config\settings.json";
        if (Test-Path $settingsPath) {
            [System.Object]$temp = (Get-Content -Raw -Path $settingsPath | ConvertFrom-Json);
            if ($temp.PSobject.Properties.Name -contains 'current') { $this.settings.current = [string]$temp.current; }
            if ($temp.PSobject.Properties.Name -contains 'is_on') { $this.settings.is_on = [bool]$temp.is_on; }
        }
        if (($this.settings.current) -And (-Not $this.InstalledPerls().Contains($this.settings.current))) {
            $this.settings.current = '';
        }
        return;
    }

    # Load in some info about what it is we're doing here.
    [void] SaveSettings() {
        # we could be attempting to save settings prior to setup
        if (![System.IO.Directory]::Exists("$($this.rootPath)\_config")) {
            return;
        }
        [String]$settingsPath = "$($this.rootPath)\_config\settings.json";
        $this.settings | ConvertTo-Json -depth 100 | Out-File $settingsPath
        return;
    }

    [void] Setup() {
        # check to ensure the $this.profilePath exists
        if(![System.IO.File]::Exists($this.profilePath)) {
            Write-Host("You don't yet have a profile at $($this.profilePath). We'll set that up now.");
            # this is like touch filename in linux
            New-Item -ItemType file $this.profilePath
        }
        $init_content = "# PSPerl Initialize`r`n& $($this.rootPath)\psperl.ps1 -Init"
        $found = Select-String -Quiet -Pattern "^# PSPerl Init" -Path $this.profilePath
        if (-not $found) {
            Add-Content -Path $this.profilePath -Value "`r`n$init_content"
        }

        # check to ensure the config directory exists
        if(![System.IO.Directory]::Exists("$($this.rootPath)\_config")) {
            Write-Host("You don't yet have a configuration directory.");
            # this is like touch filename in linux
            New-Item -ItemType directory "$($this.rootPath)\_config"
        }
        # check to ensure the \_zips directory exists
        if(![System.IO.Directory]::Exists("$($this.rootPath)\_zips")) {
            # this is like touch filename in linux
            New-Item -ItemType directory "$($this.rootPath)\_zips"
        }
        # check to ensure the config\perls directory exists
        if(![System.IO.Directory]::Exists("$($this.rootPath)\_perls")) {
            # this is like touch filename in linux
            New-Item -ItemType directory "$($this.rootPath)\_perls"
        }

        Write-Host("Your profile is located at:  $($this.profilePath)");
        Write-Host("Your config directory is at: $($this.rootPath)\_config");
        return;
    }

    [void] Use([string]$perl_install, [bool]$persistent = $false) {
        if (-Not $this.InstalledPerls().Contains($perl_install)) {
            throw "$($perl_install) isn't yet installed. Try installing it.";
        }
        $this.ClearEnvironment();
        $env:PATH = "$($this.rootPath);$($env:PATH)";
        # which perl will we be using?
        [string]$path = "$($this.rootPath)\_perls\$($perl_install)";

        $env:PATH = "$($path)\perl\site\bin;$($path)\perl\bin;$($path)\c\bin;$($env:PATH)";

        # setup local::lib stuff
        # [String]$lib_path = "$($this.rootPath)\_libs\$($perl_install)\$($lib_name)";
        # $lib_path = $lib_path.Replace("\", "/");
        # $env:PATH = "$($lib_path)/bin;$($env:PATH)";
        # perl -Mlocal::lib="$($lib_path)" *>$null;
        # $env:PERL5LIB = "$($lib_path)/lib/perl5";
        # $env:PERL_LOCAL_LIB_ROOT= "$($lib_path)";
        # $env:PERL_MB_OPT = $("--install_base `"$($lib_path)`"");
        # $env:PERL_MM_OPT = $("INSTALL_BASE=$($lib_path)");
        if ($persistent) {
            $this.settings.current = $perl_install;
            $this.SaveSettings();
        }
    }
}
