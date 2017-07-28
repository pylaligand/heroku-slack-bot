#!/bin/sh
# Copyright (c) 2017 P.Y. Laligand

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$CURRENT_DIR/.."

pub get

export DIRECTIVE=nothing

dart bin/background.dart
