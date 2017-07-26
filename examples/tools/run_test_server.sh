#!/bin/sh
# Copyright (c) 2017 P.Y. Laligand

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$CURRENT_DIR/.."

pub get

export USE_DELAYED_RESPONSES=false
export SLACK_VERIFICATION_TOKEN=abcdefgh
export SLACK_CLIENT_ID=12345678
export SLACK_CLIENT_SECRET=87654321

dart bin/server.dart
