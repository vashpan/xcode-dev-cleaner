#!/usr/bin/python

# This script copies a tree of files from one location, but without contents.
# This is useful for creating a duplicate tree of Xcode cache files, for testing purpuses.
# It won't consume so much storage as the real ones since sizes will be artificial.

import sys, os

# utilities
def error(msg):
    print 'Error: ' + msg
    exit(1)

def usage():
    print 'Usage: ' + sys.argv[0] + ' <source> <destination>'
    exit(0)

def is_path_hidden(path):
    if path.startswith('.'):
        return True
    else:
        return False

def make_file(path, bytes_to_write = 8):
    with open(path, 'w') as f:
        data_to_write = 'A' * bytes_to_write
        f.write(data_to_write)

def prepare_destination_path(source, current, destination):
    result = ''
    for i in range(0, len(current)):
        if i < len(source) and current[i] == source[i]:
            continue
        else:
             result += current[i]
    
    return os.path.join(destination, result)

if len(sys.argv) != 3:
    usage()

source = sys.argv[1]
destination = sys.argv[2]

for root, dirs, files in os.walk(source):
    # ignore hidden files
    files = [f for f in files if not is_path_hidden(f)]
    dirs[:] = [d for d in dirs if not is_path_hidden(d)] # replacing elements in place so os.walk won't process hidden dirs

    # create dirs 
    for d in dirs:
        destination_root_path = prepare_destination_path(source, os.path.join(root, d), destination)
        print destination_root_path
        os.mkdir(destination_root_path)

    # add files
    for f in files:
        destination_root_path = prepare_destination_path(source, os.path.join(root, f), destination)
        print destination_root_path
        make_file(destination_root_path)
