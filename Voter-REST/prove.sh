#!/usr/bin/env bash
source ../env_vars.sh
prove -l -I../Voter::DB/lib t
