#!/bin/bash
set -e

# relative path of directory to build
APP_SUBDIR=${APP_SUBDIR:=.}

export IMPORT_PATH=/github/workspace/${APP_SUBDIR}
/bin/herokuish buildpack test
