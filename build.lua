
module = "tabularray"

sourcefiles  = { "tabularray.sty" }

-- keep "pdftex" the last item in checkengines to please old ppmcheckpdf files
checkengines = { "xetex", "luatex", "pdftex" }
stdengine    = "pdftex"
checkruns    = 2

lvtext = ".tex"

kpse.set_program_name ("kpsewhich")
if not release_date then
 dofile ( kpse.lookup ("l3build.lua"))
end
