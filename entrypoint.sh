#!/bin/bash
set -e

export IMPORT_PATH=/github/workspace
/bin/herokuish buildpack build
