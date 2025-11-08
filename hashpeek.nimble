# Package

version       = "0.1.0"
author        = "Jonathan Owusu Botchway"
description   = "A hash identifier and a library that offers hash extraction and identification grouping (tally)."
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["hashpeek"]


# Dependencies
requires "nim >= 2.2.4", "spectra"
#requires "sysinfo >= version_unknown" #sysinfo will be used to check free, total, used ram.
