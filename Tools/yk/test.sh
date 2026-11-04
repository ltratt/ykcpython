#! /bin/sh

set -eu

unset YK_JITC
exec build-yk/python -m test -j 8 \
    --ignorefile Tools/yk/tests_ignore.txt "$@"
