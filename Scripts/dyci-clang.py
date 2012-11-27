#!/usr/bin/env python
import hashlib

import subprocess
import sys
import os
from clangParams import parseClangCompileParams
from subprocess import Popen
from sys import stdout, stderr
#
#print('Input args is [' + ' '.join(sys.argv[1:]) + ']')

#loading old params
indexFileLocation = os.path.expanduser('~/.dyci/index/')
clangParams = parseClangCompileParams(sys.argv[1:])
className = clangParams['class']

filename = indexFileLocation + hashlib.md5(className).hexdigest()

try:
    with open(filename, "w") as text_file:
        workingDirectory = os.getcwd()
        text_file.write('\n'.join(sys.argv[1:] + [workingDirectory]))
        text_file.close()
except:
    #stderr.write("Couldn't write index file '%s' %s. This is bad:( But compilation will be continued" % (className, className.hash))
    pass

#faking compile string...
#... Since we are clang...
#... There's somewere clang-real near us..
clangReal   = os.path.dirname(os.path.realpath(__file__)) + os.sep + 'clang-real'
clangBackup = os.path.dirname(os.path.realpath(__file__)) + os.sep + 'clang.backup'


# We should check, if clangReal is still near us...
# In some cases, if user have updated Xcode, it can be really bad..
if (not os.path.exists(clangReal)) and (not os.path.exists(clangBackup)):
   stderr.write("Cannot locate original clang and it's backup.\n")
   stderr.write("This can be because of Xcode update without dyci uninstallation.\n")
   stderr.write("In case, if you see this, clang is little broken now, and you need to update it manually\n")
   stderr.write("By running next command in your terminal : \n")
   stderr.write("echo \"" + clangReal +"\" \"" + clangBackup + "\" | xargs -n 1 sudo cp /usr/bin/clang\n")
   exit(1)


compileString = [clangReal] \
                + sys.argv[1:]

#Compiling file again
process = Popen(compileString,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
output, err = process.communicate()

# emulating output / err
stdout.write(output)
stderr.write(err)

# if process returned error code, returning it
if process.returncode != 0:
    exit(process.returncode)