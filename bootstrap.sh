#!/usr/bin/env bash
#
# Bootstrap script for Vagrant testing image.

apt-get update
apt-get install -y python-pip
pip install PyYAML
