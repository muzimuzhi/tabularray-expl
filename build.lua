
module = "tabularray"

sourcefiles  = { "tabularray.sty" }

checkengines = { "pdftex", "xetex", "luatex" }
stdengine    = "pdftex"
checkruns    = 2
checksuppfiles = { "regression-test.cfg" }

lvtext = ".tex"

checkconfigs = { "build", "config-old" }
