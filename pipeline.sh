#!/usr/bin/env bash
deploy() {
  env=$1
  region=$2
  [[ -z "$region" ]] && region="ap-southeast-2"
  cat <<!

  - block: "Deploy $env network"

  - label: ':rocket: Deploy pricing-$env network'
    commands:
      - sfm -r "$region" mk -t cf/net.yml -pf params/$env.yml -tagsfile params/tags.yml -wait events pricing-net
    agents:
      queue: pricing-$env

  - block: "Deploy $env alb"

  - label: ':rocket: Deploy pricing-$env load balancer'
    commands:
      - sfm -r "$region" mk -t cf/alb.yml -pf params/$env.yml -tagsfile params/tags.yml -wait events pricing-alb
    agents:
      queue: pricing-$env
!
}
cat <<!
---
steps:
  - label: ':lint-roller::mag: cfn-lint'
    command: cfn-lint cf/*.yml
    agents:
      queue: pricing-dev

  - label: ':sonarcloud: sonar cloud'
    command: sonar.sh
    agents:
      queue: pricing-dev
!
deploy dev

deploy qa

ctrl now 2>/dev/null || exit 0

cat <<!

  - wait

  - label: ':cherry_blossom: Add CR annotation'
    command: ./cr-annotation.sh
    agents:
      queue: pricing-dev

  - block: Release to Production
    fields:
      - text: Approved CR
        key: cr-number
        hint: 'What is the approved CR for this deployment? :octagonal_sign:'
        required: true

  - label: ':cherry_blossom: Add CR approved annotation'
    command: ./cr-annotation.sh
    agents:
      queue: pricing-dev
!
deploy prod eu-west-1

cat <<!

  - wait

  - label: ':cactus: add ctrl release'
    command: ctrl release
    agents:
      queue: pricing-dev
!