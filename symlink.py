#!/usr/bin/env python

import yaml
import datetime

from os.path import exists, expanduser, islink, realpath, dirname
from os import rename, readlink, symlink

def info(msg):
    print "> \33[1;39m%s\33[0m" % msg

def linked(link, dest):
    return islink(link) and readlink(link) == dest

def file_exists(filename):
    return exists(expanduser(filename)) or islink(filename)

def make_backup(filename):
    timestamp = datetime.datetime.now().strftime("%Y-%m-%dT%H.%M.%S")
    backup_name = "%s.backup.%s" % (filename, timestamp)
    rename(filename, backup_name)
    return backup_name

def make_link(link, dest):
    symlink(dest, link)

def print_result(item):
    if "from" in item and "backup" in item:
        info("backed up %(from)s to %(backup)s" % item)
    if "from" in item and "to" in item:
        info("linked %(from)s -> %(to)s" % item)

def configure(item):
    item["from"] = expanduser(item["from"])
    item["to"] = dirname(realpath(__file__)) + "/" + item["to"]

    if linked(item["from"], item["to"]):
        return

    if file_exists(item["from"]):
        backup = make_backup(item["from"])
        item["backup"] = backup

    make_link(item["from"], item["to"])

    print_result(item)

if __name__ == '__main__':

    with open(dirname(realpath(__file__)) + "/config.yml", 'r') as stream:
        config = yaml.load(stream)

    for item in config:
        configure(item)
