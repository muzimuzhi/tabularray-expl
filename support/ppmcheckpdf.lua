#!/usr/bin/env texlua

-- Description: Convert PDF to PNG and compare PNG files after l3build
-- Copyright: 2024 (c)  Jianrui Lyu <tolvjr@163.com>
--            2024 (c)  Yukai Chou <muzimuzhi@gmail.com>
-- Repository: https://github.com/lvjr/ppmcheckpdf
-- License: The LaTeX Project Public License 1.3c

ppmcheckpdf_version = "0.5"
ppmcheckpdf_date = "2024-12-05"

--------------------------------------------
---- source code from l3build.lua
--------------------------------------------

local lfs = require("lfs")

local assert           = assert
local ipairs           = ipairs
local insert           = table.insert
local lookup           = kpse.lookup
local match            = string.match
local gsub             = string.gsub

kpse.set_program_name("kpsewhich")
build_kpse_path = match(lookup("l3build.lua"),"(.*[/])")
local function build_require(s)
  require(lookup("l3build-"..s..".lua", { path = build_kpse_path } ) )
end

-----------------------------------------

build_require("file-functions")

local imgext = imgext or ".png"
local imgdiffext = imgdiffext or ".diff.png"
-- was "-compose src" in ppmcheckpdf CTAN package
local _imgdiffopt = " -highlight-color blue"
local imgdiffexe
if os.type ~= "windows" then
  -- Unlike that in Lua 5.3, texlua's `os.execute` still returns a single
  -- value, representing the exit code.
  -- https://github.com/latex3/l3build/pull/333
  local errorlevel = os.execute("command -v magick 2>&1 >/dev/null")
  -- "0" is not a falsy value in Lua; "nil" is the only one
  if errorlevel == 0 then
    -- "magick" needs imagemagick v7 or newer
    -- https://askubuntu.com/a/1315605
    imgdiffexe = "magick compare" .. _imgdiffopt
  else
    errorlevel = os.execute("command -v compare 2>&1 >/dev/null")
    if errorlevel == 0 then
      imgdiffexe = "compare" .. _imgdiffopt
    end
  end
end
imgdiffexe = os.getenv("imgdiffexe") or imgdiffexe

local failed = {}

local md5 = require("md5")

local function md5sum(str)
  if str then return md5.sumhexa(str) end
end

local function filesum(name)
  local f = assert(io.open(name, "rb"))
  local s = f:read("*all")
  f:close()
  return md5sum(s)
end

local function readfile(name)
  local f = assert(io.open(name, "rb"))
  local s = f:read("*all")
  f:close()
  return s
end

local function writefile(name, sum)
  local f = assert(io.open(name, "w"))
  f:write(sum)
  f:close()
end

local function getfiles(path, pattern)
  local files = { }
  for entry in lfs.dir(path) do
    if match(entry, pattern) then
     insert(files, entry)
    end
  end
  table.sort(files)
  return files
end

local function getimgopt(imgext)
  local imgopt = ""
  if imgext == ".png" then
    imgopt = " -png "
  elseif imgext == ".ppm" then
    imgopt = " "
  elseif imgext == ".pgm" then
    imgopt = " -gray "
  elseif imgext == ".pbm" then
    imgopt = " -mono "
  else
    error("unsupported image extension" .. imgext)
  end
  return imgopt
end

local function pdftoimg(path, pdf)
  cmd = "pdftoppm " .. getimgopt(imgext) .. pdf .. " " .. jobname(pdf)
  run(path, cmd)
end

local function saveimgmd5(imgname, md5file, newmd5)
  print("Saving MD5 and image files for " .. imgname)
  cp(imgname, testdir, testfiledir)
  writefile(md5file, newmd5)
end

local function ppmcheckpdf(job)
  -- "job" is already in one of "<test-name>" and "<test-name>-<page>" forms
  rm(testdir, job .. imgdiffext)
  local errorlevel
  local imgname = job .. imgext
  local md5file = testfiledir .. "/" .. job .. ".md5"
  local newmd5 = filesum(testdir .. "/" .. imgname)
  if fileexists(md5file) then
    local oldmd5 = readfile(md5file)
    if newmd5 == oldmd5 then
      errorlevel = 0
      print("  " .. imgname)
    else
      errorlevel = 1
      print("  " .. imgname .. "          --> failed")
      failed[#failed + 1] = imgname
      if arg[1] == "save" then
        saveimgmd5(imgname, md5file, newmd5)
      elseif imgdiffexe then
        local oldimg = abspath(testfiledir) .. "/" .. imgname
        local newimg = abspath(testdir) .. "/" .. imgname
        local diffname = job .. imgdiffext
        local cmd = imgdiffexe .. " " ..
                      oldimg .. " " .. newimg .. " " .. diffname
        print("Creating image diff file " .. diffname)
        run(testdir, cmd)
      end
    end
  else
    errorlevel = 0
    saveimgmd5(imgname, md5file, newmd5)
  end
  return errorlevel
end

local function main()
  local errorlevel = 0
  local pattern = "%" .. pdfext .. "$"
  local files = getfiles(testdir, pattern)
  print("Running PPM checks on\n")
  for _, v in ipairs(files) do
    pdftoimg(testdir, v)
    pattern = "^" .. jobname(v):gsub("%-", "%%-") .. "%-%d+%" .. imgext .. "$"
    local imgfiles = getfiles(testdir, pattern)
    if #imgfiles == 1 then
      local imgname = jobname(v) .. imgext
      if fileexists(testdir .. "/" .. imgname) then
        rm(testdir, imgname)
      end
      ren(testdir, imgfiles[1], imgname)
      local e = ppmcheckpdf(jobname(v)) or 0
      errorlevel = errorlevel + e
    else
      for _, i in ipairs(imgfiles) do
        local e = ppmcheckpdf(jobname(i)) or 0
        errorlevel = errorlevel + e
      end
    end
  end
  return errorlevel
end

local errorlevel = main()
if errorlevel ~= 0 then
  if arg[1] == "save" then
    errorlevel = 0
    print("\n  PPM check files saved for\n")
  else
    print("\n  PPM checks failed with images\n")
  end
  for _, i in ipairs(failed) do
    print("  - " .. i)
  end
else
  print("\n  All PPM checks passed\n")
end
os.exit(errorlevel)
