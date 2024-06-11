#!/usr/bin/env bash
die() { echo "${1:-argh}"; exit ${2:-1}; }

hash aws || die "aws not found."
hash ./bin/parse-yaml.sh || die "parse-yaml.sh not found."

profile=$1
[[ -z $profile ]] && die "Usage: $0 <profile>"

STACK_NAME="network"
params=$(./bin/parse-yaml.sh ./params/params.yml)
tags=$(./bin/parse-yaml.sh ./params/tags.yml)

aws cloudformation deploy \
    --capabilities "CAPABILITY_NAMED_IAM" "CAPABILITY_AUTO_EXPAND" \
    --s3-bucket "cfn-templates-3903---4367" \
    --s3-prefix "$STACK_NAME" \
    --stack-name "$STACK_NAME" \
    --template-file "./cf/net.yml" \
    --parameter-overrides "$params" \
    --tags "$tags" \
    --profile "$profile" || die "failed to deploy stack "$STACK_NAME""