#!/usr/bin/env bash
die() { echo ${1:-argh} exit ${2:-1}; }

aws cloudformation deploy /
--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND /
--stack-name network /
--template-file cf/net.yml /
--parameter-overrides $(cat params/dev.yml) /