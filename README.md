[![Build Status](https://travis-ci.com/genio/psperl.svg?branch=master)](https://travis-ci.com/genio/psperl)

# NAME

PSPerl - Manage Strawberry Perl (Portable) installations in your $env:HOMEPATH

# SYNOPSIS

A typical install, selection, and use case would look something like this:

```PowerShell
PS C:\Users\genio> git clone https://github.com/genio/psperl.git _psperl
PS C:\Users\genio> cd _psperl
PS C:\Users\genio\_psperl> .\psperl.ps1 -Setup
PS C:\Users\genio\_psperl> .\psperl.ps1 -Init
PS C:\Users\genio\_psperl> cd ..
PS C:\Users\genio> psperl -Available
...
PS C:\Users\genio> psperl -Install perl64-5.30.0.1
PS C:\Users\genio> psperl -Switch perl64-5.30.0.1
PS C:\Users\genio> perl -v

This is perl 5, version 30, subversion 0 (v5.30.0) built for MSWin32-x86-multi-thread-64int

Copyright 1987-2019, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.

PS C:\Users\genio>
```

Then, every subsequent time you load up PowerShell, you can forego the installation, etc.

```PowerShell
PS C:\Users\genio> perl -v

This is perl 5, version 30, subversion 0 (v5.30.0) built for MSWin32-x86-multi-thread-64int

Copyright 1987-2019, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.

PS C:\Users\genio>
```

# INSTALLATION

```PowerShell
git clone https://github.com/genio/psperl.git
cd psperl
.\psperl.ps1 -Setup
```

Setting things up couldn't be easier. Basically, all you need to do is check out this repository or download it as a .zip file and extract it somewhere. Once you have it sitting in some folder, navigate to that folder in PowerShell and run the setup command: `.\psperl.ps1 -Setup`.

That will open your `$Profile` and add the following lines:
```PowerShell
# PSPerl Initialize
& C:\Users\genio\_psperl\psperl.ps1 -Init
```

That addition to your profile will handle ensuring that PSPerl is always in your PowerShell's `$env:Path` environment variable. From that point, you could just run `psperl -available` to get a list of available Portable [Strawberry Perls](http://strawberryperl.com) to install.

# DESCRIPTION

[Strawberry Perl](http://strawberryperl.com) is a Perl built to run on Windows. It's a vanilla Perl install that the Perl community has put together so that you don't have to go through the hassle of trying to get all of the prerequisites and other things necessary to build Perl yourself done.

Thank you, Strawberry Perl!

# COMMANDS

PSPerl has a few commands to help you through the process of getting a working version of Perl installed.

## Available

```PowerShell
psperl -Available # Shows you a list of all available installations
psperl -Available -major 10 # shows you a list of all Perls available on v5.10
```

The `Available` command will grab the list of releases from [Strawberry Perl's JSON file](http://strawberryperl.com/releases.json) and parse out which releases are available in Portable form -release types found [here](http://strawberryperl.com/releases.html). The information coming from Strawberry Perl's site will be cached locally on your hard drive as a JSON file that we will use from that point on so we don't hit their servers too often and to speed up your experience. This local cache will time out after an hour and a half, at which time we'll grab another copy from Strawberry's site.

It will spit out a list of all of the Perl versions you can install for use on your installation combination of Windows and PowerShell. This part is a bit different from other brew-style installers because we try to account for your `64-bit` vs `32-bit` vs `32-bit with USE_64_BIT_INT`.

### 64-bit Windows, 64-bit PowerShell

This is what you could expect to see on this platform:

```PowerShell
PS C:\Users\genio> psperl -Available
We're using a 64-bit PowerShell on a 64-bit Windows OS.
On 64-bit Windows:
    32-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT Perls without problem.
                       You _can_ use 64-bit Perls, but may run into trouble. RISK
    64-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT, or 64-bit Perls.
On 32-bit Windows:
    You can only use 32-bit or 32-bit with USE_64_BIT_INT Perls

The current release for each major Perl:

64-bit Perls:
   - perl64-5.30.0.1
   - perl64-5.28.2.1
   - perl64-5.26.3.1
   - perl64-5.24.4.1
   - perl64-5.22.3.1
   - perl64-5.20.3.3
   - perl64-5.18.4.1
   - perl64-5.16.3.1
   - perl64-5.14.4.1

32-bit with USE_64_BIT_INT Perls:
   - perl32w64int-5.30.0.1
   - perl32w64int-5.28.2.1
   - perl32w64int-5.26.3.1
   - perl32w64int-5.24.4.1
   - perl32w64int-5.22.3.1
   - perl32w64int-5.20.3.3
   - perl32w64int-5.18.4.1

32-bit Perls:
   - perl32-5.30.0.1
   - perl32-5.28.2.1
   - perl32-5.26.3.1
   - perl32-5.24.4.1
   - perl32-5.22.3.1
   - perl32-5.20.3.3
   - perl32-5.18.4.1
   - perl32-5.16.3.1
   - perl32-5.14.4.1
   - perl32-5.12.3.0
   - perl32-5.10.1.2

PS C:\Users\genio>
```

### 64-bit Windows, 32-bit PowerShell

This is what you could expect to see on this platform:

```PowerShell
PS C:\Windows\SysWOW64\WindowsPowerShell\v1.0> psperl -Available
We're using a 32-bit PowerShell on a 64-bit Windows OS.
On 64-bit Windows:
    32-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT Perls without problem.
                       You _can_ use 64-bit Perls, but may run into trouble. RISK
    64-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT, or 64-bit Perls.
On 32-bit Windows:
    You can only use 32-bit or 32-bit with USE_64_BIT_INT Perls

The current release for each major Perl:

64-bit Perls (RISKY on a 32-bit PS):
   - perl64-5.30.0.1
   - perl64-5.28.2.1
   - perl64-5.26.3.1
   - perl64-5.24.4.1
   - perl64-5.22.3.1
   - perl64-5.20.3.3
   - perl64-5.18.4.1
   - perl64-5.16.3.1
   - perl64-5.14.4.1

32-bit with USE_64_BIT_INT Perls:
   - perl32w64int-5.30.0.1
   - perl32w64int-5.28.2.1
   - perl32w64int-5.26.3.1
   - perl32w64int-5.24.4.1
   - perl32w64int-5.22.3.1
   - perl32w64int-5.20.3.3
   - perl32w64int-5.18.4.1

32-bit Perls:
   - perl32-5.30.0.1
   - perl32-5.28.2.1
   - perl32-5.26.3.1
   - perl32-5.24.4.1
   - perl32-5.22.3.1
   - perl32-5.20.3.3
   - perl32-5.18.4.1
   - perl32-5.16.3.1
   - perl32-5.14.4.1
   - perl32-5.12.3.0
   - perl32-5.10.1.2

PS C:\Windows\SysWOW64\WindowsPowerShell\v1.0>
```

### 32-bit Windows
And, finally, on this platform, you'd see:

```PowerShell
PS C:\Users\genio> psperl -Available
We're using a 32-bit PowerShell on a 32-bit Windows OS.
On 64-bit Windows:
    32-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT Perls without problem.
                       You _can_ use 64-bit Perls, but may run into trouble. RISK
    64-bit PowerShell: You can use 32-bit, 32-bit USE_64_BIT_INT, or 64-bit Perls.
On 32-bit Windows:
    You can only use 32-bit or 32-bit with USE_64_BIT_INT Perls

The current release for each major Perl:

32-bit with USE_64_BIT_INT Perls:
   - perl32w64int-5.30.0.1
   - perl32w64int-5.28.2.1
   - perl32w64int-5.26.3.1
   - perl32w64int-5.24.4.1
   - perl32w64int-5.22.3.1
   - perl32w64int-5.20.3.3
   - perl32w64int-5.18.4.1

32-bit Perls:
   - perl32-5.30.0.1
   - perl32-5.28.2.1
   - perl32-5.26.3.1
   - perl32-5.24.4.1
   - perl32-5.22.3.1
   - perl32-5.20.3.3
   - perl32-5.18.4.1
   - perl32-5.16.3.1
   - perl32-5.14.4.1
   - perl32-5.12.3.0
   - perl32-5.10.1.2

PS C:\Users\genio>
```





## Install

```PowerShell
PS C:\Users\genio> psperl -Install perl64-5.30.0.1
PS C:\Users\genio> psperl -Install perl32w64int-5.30.0.1
PS C:\Users\genio> psperl -Install perl32-5.30.0.1
```

Once you've selected which version of Perl you'd like to use from the list supplied in the `Available` command, you'd just need to install it.

This command will download the Portable Perl zip file from Strawberry Perl's site and store it locally in the `_zips` directory. It will then check that we got the expected file size and SHA1 checksum match. If it's not the right size or checksum, we'll remove the zip file and fail.

Given that we have the right file, we'll extract the zip file into your `_perls` directory. If we're installing `perl32w64int-5.30.0.1` then the path to that Perl would be `psperl_home_dir\_perls\perl32w64int-5.30.0.1`. So, if you installed PSPerl in `C:\Users\genio\_psperl`, the full path to that directory would be `C:\Users\genio\_psperl\_perls\perl32w64int-5.30.0.1`.

Just installing the version of Perl does _not_ make it ready for you to use immediately. This is simply because you may not yet want to work on that version. If you're using v5.30 and wanted to install another version, say v5.28, to test with, you can install that new version but you'd still be on v5.30 until you decide to change it with the `Use` or `Switch` commands.

### Switch

```PowerShell
PS C:\Users\genio> psperl -Switch perl64-5.30.0.1
PS C:\Users\genio> psperl -Switch perl32w64int-5.30.0.1
PS C:\Users\genio> psperl -Switch perl32-5.30.0.1
```

The `Switch` command can be used to change your current environment setup to use any version of Perl we've already installed. This will be made persistent as we'll store the current version in our local config directory and every time you start a PowerShell session, we'll setup your environment for the selected version of Perl.

You can change which Perl you're using as many times as you'd like during a session, though you can only use one Perl at a time.

### Use

```PowerShell
PS C:\Users\genio> psperl -Use perl64-5.30.0.1
PS C:\Users\genio> psperl -Use perl32w64int-5.30.0.1
PS C:\Users\genio> psperl -Use perl32-5.30.0.1
```

The `Use` command works almost exactly as the `Switch` command does, but it isn't persistent. With this command, we just start using a different version of Perl, but we haven't switched our preference to that one. If my current preference is Perl v5.28 and it's what I have setup to start on my PowerShell sessions, I could temporarily use Perl v5.30 with this command. If I close my session and re-open it, I'll be back on Perl v5.28.

You can change which Perl you're using as many times as you'd like during a session, though you can only use one Perl at a time.

# AUTHOR

Chase Whitener `<capoeirab@cpan.org>`

# COPYRIGHT & LICENSE

Copyright 2019, Chase Whitener, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.
