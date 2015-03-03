#!/usr/bin/env python
import hashlib
import os
import time
import shutil
import re

import random
from subprocess import Popen
import subprocess
from sys import stderr, stdout
from clangParams import parseClangCompileParams
from os.path import normpath, basename, dirname
import sys

#----------------------------------------------------------------------------------
#Some contstants

DYCI_ROOT_DIR = os.path.expanduser('~/.dyci')
ARGS = sys.argv

FILENAME = ''
try:
    FILENAME = ARGS[1]
except:
    stderr.write("Incorrect usage. Path to .m,.h file or resource should be used as the parameter")
    exit(1)

# loading it's params from the file
XCACTIVITYPARSER_LOCATION = DYCI_ROOT_DIR + "/scripts/xcactivity-parser.py" 
# XCACTIVITYPARSER_LOCATION = "/Volumes/data/Educate/xcactiviy-parser/src/xcactivity-parser.py"
DERIVED_DATA_DIR = os.path.expanduser("~/Library/Developer/Xcode/DerivedData")
#ARCH = "x86_64"

#-----------------------------------------------------------------------------
def dyciLOG(value, init=False):
    with open("/tmp/dyci.log", "w+" if init else "a+") as f:
        f.write(value + os.linesep)

def dyciLOGStep(value, message = ""):
    dyciLOG("\n>> Step #" + value + " " + message + " http://bit.ly/1KjK81p ")

#----------------------------------------------------------------------------------
# Running process
def runAndFailOnError(stringToRun, shell=True):
    dyciLOG("Running\n %s" % stringToRun)
    process = Popen(stringToRun,
                shell=shell,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
                )
    output, err = process.communicate()

    # emulating output / err
    stdout.write(output)
    stderr.write(err)
    if process.returncode != 0:
        sys.exit(1)

    return output.rstrip(os.linesep)    

#----------------------------------------------------------------------------------
def locateCompileStringForFile(original_filename):
    currDir = os.getcwd()
    dyciLOGStep("3.1", "Locate latest build dir")
    os.chdir(DERIVED_DATA_DIR)    
    dyciLOG("DerivedData is %s" % DERIVED_DATA_DIR)

    lastBuildDir = DERIVED_DATA_DIR + "/" + runAndFailOnError("ls -td */Logs/Build | head -n 1")
    dyciLOG("Last build is %s" % lastBuildDir)

    dyciLOGStep("3.2", "Locate compilation parameters")
    filename = original_filename.replace(" ", "\\ ")
    dyciLOG("Filename prepared for injection %s" % filename)

    dyciLOGStep("3.4", "Resolving ARCH of file to search")
    ARCH_FILE = DYCI_ROOT_DIR + "/arch"
    ARCH = "x86_64"
    if os.path.exists(ARCH_FILE):
        with open(ARCH_FILE) as f: ARCH = f.read()
    else:
        dyciLOG("Falling back to deafult arch %s" % ARCH)
            
    dyciLOG("Usin ARCH for search %s" % ARCH)
    
    command = [XCACTIVITYPARSER_LOCATION,"-f",filename,"-x",lastBuildDir, "-a", ARCH, "-w"]
    dyciLOG("Running command\n%s" % " ".join(command))

    process = Popen(command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    compileString, err = process.communicate()
    dyciLOG("CompileString '%s'" % compileString)

    compileString = compileString.rstrip(os.linesep)
    stderr.write(err)
    
    if process.returncode != 0 or compileString is None or len(compileString) == 0:
        dyciLOG("Compile string is empty. This file wasn't compiled for speficified architecture %s, or build directory wasn't resolved correctly %s" % (ARCH, lastBuildDir) )
        stderr.write("Cannot find how this file was compiled. \nPlease, try to compile it first (see /tmp/dyci.log)")
        sys.exit(1)

    os.chdir(currDir)  
    return compileString  

#----------------------------------------------------------------------------------
def removeDynamicLibsFromDirectory(dir):
    if dir[-1] == os.sep: dir = dir[:-1]
    try:
        files = os.listdir(dir)
    except:
        print 'Directory %s does not exists' % dir
        return
    for file in files:
        if file.endswith(".dylib") or file.endswith("resource"): 
            path = dir + os.sep + file
            if os.path.isdir(path):
                continue
            else:
                os.unlink(path)

#----------------------------------------------------------------------------------
def copytree(src, dst, symlinks=False, ignore=None):
    if not os.path.exists(dst):
        os.makedirs(dst)
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            copytree(s, d, symlinks, ignore)
        else:
            if not os.path.exists(d) or os.stat(src).st_mtime - os.stat(dst).st_mtime > 1:
                shutil.copy2(s, d)

#----------------------------------------------------------------------------------
def copyResource(source, dyci):
    try:
       fileHandle = open( dyci + '/bundle', 'r' )
    except IOError as e:
       stderr.write("Error when tried to copy resource :( Cannot find file at " + dyci + '/bundle')
       return 1

    bundlePath = fileHandle.read()
    fileHandle.close()

    # Searching, if it is localizable resource or not
    resource_directory = basename(dirname(source))
    if (resource_directory[-5:] == "lproj"):

        # Localizable Resouerces..
        if not os.path.isdir(source):
            shutil.copy(source, bundlePath + "/" + resource_directory)
            stdout.write("LF : File " + source + " was successfully copied to application -> " + bundlePath + "/" + resource_directory)
        else:
            copytree(source, bundlePath + "/" + resource_directory + "/" + os.path.split(source)[1])
            stdout.write("LD : File " + source + " was successfully copied to application -> " +  bundlePath + "/" + resource_directory + "/" + os.path.split(source)[1])
    else:    

        # Non-Localizable Resouerces..
        if not os.path.isdir(source):
            shutil.copy(source, bundlePath)
            stdout.write("NF : File " + source + " was successfully copied to application -> " + bundlePath)
        else:
            copytree(source, bundlePath + "/" + os.path.split(source)[1])
            stdout.write("ND : File " + source + " was successfully copied to application -> " + bundlePath)

    try:
       fileHandle = open( dyci + '/resource', 'w' )
       fileHandle.write(source)
    except IOError as e:
       stderr.write("Error when tried to write to file " + dyci + '/resource')
       return 1

    fileHandle.close()

    return 0    

#----------------------------------------------------------------------------------
def filenameIsResource(filename):
    return filename[-4:] == ".png" or filename[-4:] == ".jpg" or filename[-5:] == ".jpeg" or filename[-8:] == ".strings"

def dyciHandleResounce(filename):
    dyciLOG("Handling resource %s" % filename)
    resultCode = copyResource(filename, DYCI_ROOT_DIR)
    exit(resultCode)

#----------------------------------------------------------------------------------

def filenameIsXIB(filename):
    return filename[-4:] == ".xib"

def dyciHandleXIB(filename):
    dyciLOG("Handling XIB %s" % filename)
    xibFilename = os.path.splitext(filename)[0] + ".nib"
    runAndFailOnError(["ibtool", "--compile", xibFilename, filename])
    resultCode = copyResource(xibFilename, DYCI_ROOT_DIR)
    os.system("rm -Rf %s" % xibFilename)
    exit(resultCode)

#----------------------------------------------------------------------------------
def filenameIsStoryboard(filename):
    return filename[-11:] == ".storyboard"

def dyciHandleStoryboard(filename):
    dyciLOG("Handling Storyboard %s" % filename)
    storyboardFileName = os.path.splitext(filename)[0] + ".storyboardc"
    runAndFailOnError(["ibtool", "--compile", storyboardFileName, filename])
    resultCode = copyResource(storyboardFileName, DYCI_ROOT_DIR)
    shutil.rmtree(storyboardFileName)
    exit(resultCode)

#----------------------------------------------------------------------------------
dyciLOG("--------------------------------------", True)
dyciLOGStep("3", "Locate previous compilation parameters")
dyciLOG("Injecting %s" % FILENAME)

# In case of resources..
if filenameIsResource(FILENAME): 
   dyciHandleResounce(FILENAME) 

#In case of xibs
if filenameIsXIB(FILENAME): 
   dyciHandleXIB(FILENAME) 

#Storyboards also welcome
if filenameIsStoryboard(FILENAME): 
    dyciHandleStoryboard(FILENAME)



# In case of header files
# In some cases you need be able to recompile M file, when you are in header
if FILENAME[-2:] == ".h": FILENAME = os.path.splitext(FILENAME)[0] + ".m"


# Searching where is Xcode with it's Clang located

WORKING_DIR, compileString = locateCompileStringForFile(FILENAME).splitlines()[0:2]

#Compiling file again
dyciLOGStep("3.3", "Locate previos working directory")
dyciLOG("Working dir %s" % WORKING_DIR)

os.chdir(WORKING_DIR)

dyciLOGStep("4", "Recompile file")
dyciLOGStep("4.1", "Recompile file itself")
runAndFailOnError(compileString)

dyciLOGStep("4.2", "Link compiled object file to dylib")
#Compilation was successful... performing linking
params = re.compile("(?<!\\\\) ").split(compileString)
clangParams = parseClangCompileParams(params)

#creating new random name wor the dynamic library
libraryName = "dyci%s.dylib" % random.randint(0, 10000000)

# {'class':className,
#        'object':objectCompilation,
#        'arch':arch,
#        'isysroot':isysroot,
#        'LParams':Lparams,
#        'FParams':Fparams,
#        'minOSParam':minOSParam
#}
# print "Compiler string was \n%s" % clangParams


# Searching where is Xcode with it's Clang located
process = Popen(["xcode-select","-print-path"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
XCODE_LOCATION, err = process.communicate()
XCODE_LOCATION = XCODE_LOCATION.rstrip(os.linesep)
dyciLOG("Xcode Location %s" % XCODE_LOCATION)

#Running linker, that will create dynamic library for us
LIBRARY_OUTPUT_LOCATION = DYCI_ROOT_DIR + "/" + libraryName
linkArgs = \
[XCODE_LOCATION + "/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"] \
+ ["-arch"] + [clangParams['arch']]\
+ ["-dynamiclib"]\
+ ["-isysroot"] + [clangParams['isysroot']]\
+ clangParams['LParams']\
+ clangParams['FParams']\
+ [clangParams['object']]\
+ ["-install_name"] + ["/usr/local/lib/" + libraryName]\
+ ['-Xlinker']\
+ ['-objc_abi_version']\
+ ['-Xlinker']\
+ ["2"]\
+ ["-ObjC"]\
+ ["-undefined"]\
+ ["dynamic_lookup"]\
+ ["-fobjc-arc"]\
+ ["-fobjc-link-runtime"]\
+ ["-Xlinker"]\
+ ["-no_implicit_dylibs"]\
+ [clangParams['minOSParam']]\
+ ["-single_module"]\
+ ["-compatibility_version"]\
+ ["5"]\
+ ["-current_version"]\
+ ["5"]\
+ ["-o"]\
+ [LIBRARY_OUTPUT_LOCATION]\
+ ["-v"]

dyciLOG("Creating .dylib")
runAndFailOnError(linkArgs, False)

dyciLOG(".dylib Compiled ")

