#!/usr/bin/env python
import hashlib
import os
import time
import shutil

import random
from subprocess import Popen
import subprocess
from sys import stderr, stdout
from clangParams import parseClangCompileParams
from os.path import normpath, basename, dirname
import sys

# Running process
def runAndFailOnError(stringToRun):
    process = Popen(stringToRun,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
    output, err = process.communicate()

    # emulating output / err
    stdout.write(output)
    stderr.write(err)
    if process.returncode != 0:
        sys.exit(1)

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


DYCI_ROOT_DIR = os.path.expanduser('~/.dyci')

#removing old library and resources
removeDynamicLibsFromDirectory(DYCI_ROOT_DIR)

args = sys.argv

filename = ''
try:
    filename = args[1]
except:
    stderr.write("Incorrect usage. Path to .m,.h file or resource should be used as the parameter")
    exit(1)

# In case of resources..
if filename.endswith((".png", ".jpg", ".jpeg", ".strings", ".plist", ".json", ".html", ".css", ".js")): 
    resultCode = copyResource(filename, DYCI_ROOT_DIR)
    exit(resultCode)

#In case of xibs
if filename[-4:] == ".xib":
    xibFilename = os.path.splitext(filename)[0] + ".nib"
    runAndFailOnError(["ibtool", "--compile", xibFilename, filename])
    resultCode = copyResource(xibFilename, DYCI_ROOT_DIR)
    os.system("rm -Rf %s" % xibFilename)
    exit(resultCode)

#Storyboards also welcome
if filename[-11:] == ".storyboard":
    storyboardFileName = os.path.splitext(filename)[0] + ".storyboardc"
    runAndFailOnError(["ibtool", "--compile", storyboardFileName, filename])
    resultCode = copyResource(storyboardFileName, DYCI_ROOT_DIR)
    shutil.rmtree(storyboardFileName)
    exit(resultCode)


# In case of header files
# In some cases you need be able to recompile M file, when you are in header
if filename[-2:] == ".h": filename = os.path.splitext(filename)[0] + ".m"

# loading it's params from the file
indexFileLocation = DYCI_ROOT_DIR + '/index/' + hashlib.md5(os.path.normpath(filename)).hexdigest()


params = []
try:
    params = [line.strip() for line in open(indexFileLocation)]
except:
    stderr.write("Couldn't load index file '%s' (%s). Use default compilation instead" % (indexFileLocation, filename))
    exit(1)

# searching params by filename

if not params:
    stderr.write("Could not find saved params for file %s. File need to be compiled first " % filename)
    exit(1)


# Switching to the specified working directory
workingDir = params[len(params)-1]
os.chdir(workingDir)
params = params[:-1]


# Searching where is Xcode with it's Clang located
process = Popen(["xcode-select","-print-path"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
xcodeLocation, err = process.communicate()
xcodeLocation = xcodeLocation.rstrip(os.linesep)

compileString = [xcodeLocation + '/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang-real'] \
                + params

#Compiling file again
runAndFailOnError(compileString)

#Compilation was successful... performing linking
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

#Running linker, that will create dynamic library for us
linkArgs = \
[xcodeLocation + "/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang-real"] \
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
+ [DYCI_ROOT_DIR + "/tmp/" + libraryName]\
#       + ['-v']

# print "Linker args \n%s" % ' '.join(linkArgs)
runAndFailOnError(linkArgs)
print "Linked\n"

#sign
signArgs = ["/usr/bin/codesign"] + ["-s"] + ["-"] + ["-vvvv"] + ["-f"] + [DYCI_ROOT_DIR + "/tmp/" + libraryName]
runAndFailOnError(signArgs)
print "Signed " + libraryName + "\n"

moveArgs = ["mv", DYCI_ROOT_DIR + "/tmp/" + libraryName, DYCI_ROOT_DIR + "/" + libraryName]
runAndFailOnError(moveArgs)
