# NAME

PSPerl - Manage Strawberry Perl (Portable) installations in your $env:HOMEPATH

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

# SWITCH TO PERL VERSION

This part is not yet complete. It would, however, behave fairly simply.

To switch to one of your installed versions, you'd do something akin to:

```PowerShell
# select perl version 5.28.0.1 and a local::lib called "normal"
PS C:\Users\genio> psperl -Switch perl-5.28.0.1@normal
```

And that would, for the most part, just setup your environment:

```PowerShell
# which perl will we be using?
$path="$psperl_path\_perls\5.28.0.1";
$lib_path="$psperl_path\_perls\libs\5.28.0.1_normal"
$lib_path = $lib_path.Replace("\", "/")

$env:PATH="$($lib_path)/bin;$($path)\perl\site\bin;$($path)\perl\bin;$($path)\c\bin;$($env:PATH)"

perl -Mlocal::lib="$($lib_path)" *>$null

$env:PERL5LIB="$($lib_path)/lib/perl5";
$env:PERL_LOCAL_LIB_ROOT= "$($lib_path)";
$env:PERL_MB_OPT = $("--install_base `"$($lib_path)`"");
$env:PERL_MM_OPT = $("INSTALL_BASE=$($lib_path)");
```

# AUTHOR

Chase Whitener `<capoeirab@cpan.org>`

# COPYRIGHT & LICENSE

Copyright 2019, Chase Whitener, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.
