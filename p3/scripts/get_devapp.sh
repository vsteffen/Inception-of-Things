#!/bin/bash

export DEVAPP_IP="$(kubectl -n dev get ingress -o jsonpath="{.items[0].status.loadBalancer.ingress[0].ip}")"

set -x
curl -H "Host: devapp" "http://$DEVAPP_IP"