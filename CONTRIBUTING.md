
Contributing to the Manual (manual is unmaintained in `tabularray-dev`)
--------------------------

- You need to compile the manual files with LuaLaTeX,
  because it is rather slow to compile them with XeLaTeX or PDFLaTeX.

- The manual `tabularray.tex` is split into subfiles and put in manual folder.
  You can compile each subfile and see the output.

- Now you can create a pull request for your contribution.


Contributing to the Code
------------------------

- Preparation
  - Install [`l3build`](https://ctan.org/pkg/l3build) LaTeX package.
  - Install `pdftoppm` program. 
    - Windows: `tlmgr install wintools.windows`
    - Ubuntu: `apt-get install poppler-utils`
    - macOS: `brew install poppler`
  - Install `magick` program.
    - Windows: see https://imagemagick.org/script/download.php#windows
    - Ubuntu: `apt-get install imagemagick`
    - macOS: `brew install imagemagick`

- Run tests
  - Run `l3build check` to compile test files.
  - Run `texlua buildend.lua` to compare MD5 checksums for test outputs of `pdftex` engine.
    - The `buildend.lua` calls `ppmcheckpdf.lua` (both are contained in this repository), which then uses `pdftoppm` program to convert PDF to PNG and makes MD5 checksums.
    - On non-Windows systems, when ImageMagick CLI program `magick` is available, `ppmcheckpdf.lua` also creates `.diff.md5` diff images for failed tests.

- Update test results
    - Run `l3build save <name>...` to update corresponding `testfiles/<name>.tlg` files.
    - Run `l3build save -cconfig-old <name>...` to update corresponding `testfiles-old/<name>.tlg` files.
    - Run `l3build save -e<engine> [-cconfig-old] <name>...` to create or update corresponding `<name>.<engine>.tlg` files.
    - After `l3build check -cconfig-old` passes, run `texlua buildend.lua save` to update all `testfiles/*.{png,md5}` files which failed the ppm check.
