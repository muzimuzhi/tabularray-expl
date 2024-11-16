local module_name = "tabularray"
local config_name = "config-old"

kpse.set_program_name("kpsewhich")

dofile("build.lua")
if module ~= module_name then
  print("ERROR: module is not \"%s\". Wrong \"build.lua\" loaded.", module_name)
  os.exit(1)
end

dofile(config_name .. ".lua")
dofile(kpse.lookup("l3build-variables.lua"))

-- pity, for non-"build.lua" check config, testdir is not set automatically
testdir = builddir .. "/test-" .. config_name

-- what "ppmcheckpdf.lua" really cares about:
print("Running PPM checks with")
print("  testdir     = " .. testdir)
print("  testfiledir = " .. testfiledir)
print("")

dofile(supportdir .. "/ppmcheckpdf.lua")
