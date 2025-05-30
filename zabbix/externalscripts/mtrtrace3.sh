#!/usr/bin/env bash
mtr -4 -r -c3 -w -b --no-dns $1 | grep "|"
