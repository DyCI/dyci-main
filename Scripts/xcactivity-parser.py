#!/usr/bin/env python
from __future__ import print_function

import optparse
import os, fnmatch, fileinput, subprocess, gzip, re, sys


def main():
    p = optparse.OptionParser()
    p.add_option('--xcactivity-files-dir', '-x', help="Directory where .xcactivity files are located")
    p.add_option('--file', '-f', help="File for which parameters are searching for")
    p.add_option('--arch', '-a', help="Architecture for which file was compiled")
    p.add_option("--working-dir", "-w", action="store_true", dest="show_working_dir", default=False, help="Add working dir before compilation line")

    options, arguments = p.parse_args()
    if not options.xcactivity_files_dir:
        p.error("xcode activity directory path required")

    if not options.file:
        p.error("searching file path is required")

    # Check that file starts from backslash
    if not options.file.startswith("/"):
        p.error("Provide full path to the file")

    # Check that directory exists
    if not os.path.exists(options.xcactivity_files_dir) or not os.path.isdir(options.xcactivity_files_dir):
        p.error("Specified directory doesn't exist")

    if not options.arch:
        p.error("Please specify architecture")

    search_copilation_string_for_file_in_directory(options.file, options.xcactivity_files_dir, options.arch, options.show_working_dir)


def search_file_in_activity_log(searching_file, activity_log_file, architecture, show_working_dir = False):
    f = gzip.open(activity_log_file, 'rUb')

    latest_working_dir = None
    latest_working_dir_regex = re.compile('\\s*cd\\ "?(.*?)"?$')

    for line in f.readlines():
        if searching_file in line and "/XcodeDefault.xctoolchain" in line:
            for rline in line.split("\r"):
                latest_working_dir_match = latest_working_dir_regex.match(rline.strip())
                if latest_working_dir_match:
                    latest_working_dir = latest_working_dir_match.group(1)
                    
                if searching_file in rline and "/XcodeDefault.xctoolchain" in rline and "-arch " + architecture in rline:
                    if rline.endswith(".o"):
                        if show_working_dir == True:
                            yield latest_working_dir
                        yield rline.strip()

    f.close()


def search_copilation_string_for_file_in_directory(searching_file, directory, architecture, show_working_dir = False):
    # out, err = subprocess.Popen(["ls","-t", directory + "/*.xcactivitylog"], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    out, err = subprocess.Popen(["ls", "-t", directory], stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
    for currentfile in out.splitlines():
        if currentfile.endswith(".xcactivitylog"):
            for compilation_params in search_file_in_activity_log(searching_file, os.path.join(directory, currentfile),
                                                                  architecture, show_working_dir):
                print(compilation_params)


if __name__ == '__main__':
    main()