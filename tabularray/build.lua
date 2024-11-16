module = "tabularray"


maindir         = ".."
checkdeps       = { maindir .. "/zutil"}

sourcefiles     = { "tabularray.sty" }

-- "checkengines" and "checksuppfiles" are overwritten in "config-old.lua"
checkengines    = { "pdftex", "xetex", "luatex" }
stdengine       = "pdftex"
checkruns       = 2
checksuppfiles  = { "regression-test.cfg" }

lvtext = ".tex"

checkconfigs    = { "build", "config-old" }
