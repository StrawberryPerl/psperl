# NAME

PSPerl - Manage Strawberry Perl (Portable) installations in your $env:HOMEPATH

# INSTALLATION

```ps1
git clone https://github.com/genio/psperl.git
cd psperl
.\psperl.ps1 -Setup
```

Setting things up couldn't be easier. Basically, all you need to do is check out this repository or download it as a .zip file and extract it somewhere. Once you have it sitting in some folder, navigate to that folder in PowerShell and run the setup command: `.\psperl.ps1 -Setup`.

That will open your `$Profile` and add the following lines:
```ps1
# PSPerl Initialize
& C:\Users\genio\_psperl\psperl.ps1 -Init
```

That addition to your profile will handle ensuring that PSPerl is always in your PowerShell's `$env:Path` environment variable. From that point, you could just run `psperl -available` to get a list of available Portable [Strawberry Perls](http://strawberryperl.com) to install.

# DESCRIPTION

[Strawberry Perl](http://strawberryperl.com) is a Perl built to run on Windows. It's a vanilla Perl install that the Perl community has put together so that you don't have to go through the hassle of trying to get all of the prerequisites and other things necessary to build Perl yourself done.

Thank you, Strawberry Perl!

# AUTHOR

Chase Whitener `<capoeirab@cpan.org>`

# COPYRIGHT & LICENSE

Copyright 2019, Chase Whitener, All Rights Reserved.

You may use, modify, and distribute this package under the
same terms as Perl itself.
