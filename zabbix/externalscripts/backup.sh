#!/bin/bash
sshpass -p a9c24q92zx ssh -n -T -o "StrictHostKeyChecking=no" $1 -p $2 -l andre export

