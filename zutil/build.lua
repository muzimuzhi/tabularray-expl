module = "zutil"


maindir         = ".."

sourcefiles     =
  {
    "zutil.sty"
  , "zutil-debug.code.tex"
  }

checkengines    = { "pdftex", "xetex", "luatex" }
stdengine       = "pdftex"
checksuppfiles  = { "regression-test.cfg" }
