#!/bin/bash
a=2.3
b=3.4
function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | tail -n 1)" == "$1"; }
if version_gt $a $b; then
echo $a
else
echo $b
fi
