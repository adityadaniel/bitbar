#!/bin/bash

echo "A"
sleep 1
echo "~~~"
sleep 1
>&2 echo "ERROR"
echo "B"
echo "~~~"
sleep 100 # never ends
