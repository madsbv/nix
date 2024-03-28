#!/usr/bin/env bash
set -euxo pipefail

scp -r . root@192.168.64.3:/root/nixos
