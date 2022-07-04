#!/bin/bash

echo "Content-type: text/html"
echo ""


version="v2.0.0"
ipAddress=$(hostname -i)

echo "version: ${version}, IP: ${ipAddress}, hostname: `hostname`"
