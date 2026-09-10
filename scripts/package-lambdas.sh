#!/bin/bash
set -e
cd "$(dirname "$0")/../lambda"
for d in */; do
  echo "Packaging $d..."
  cd "$d"
  zip -r ../${d%/}.zip .
  cd ..
done
