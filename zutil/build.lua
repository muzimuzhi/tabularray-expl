module = "zutil"


maindir         = ".."

sourcefiles     = { "*.sty", "*.code.tex" }
installfiles    = { "*.sty", "*.code.tex" }

checkengines    = { "pdftex", "xetex", "luatex" }
stdengine       = "pdftex"
checksuppfiles  = { "regression-test.cfg" }
