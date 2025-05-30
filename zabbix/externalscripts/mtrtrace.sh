#!/usr/bin/env bash
mtr -4 -r -c1 -w -b --no-dns $1 | grep "|"
