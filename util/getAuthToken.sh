#!/usr/bin/env bash


#
# WARNING!! this is a helper used by some of the init scripts. use it
# in that spirit, not as part of code that will be invoked in
# production
#


#
# prereq installations: wsk
# prereq: ./init.sh in the top-level to initialize the objectstore package
#

wsk action invoke objectstore/getAuthToken -b -r -p provider github | tr -d '\n'

