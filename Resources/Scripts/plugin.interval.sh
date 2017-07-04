#!/bin/bash

if [ -n "$1" ]; then
  echo $1
elif [ -n "$ENV1" ]; then
  echo $ENV1
else
  echo "A"
fi;
if [ -n "$2" ]; then
  echo $2
elif [ -n "$ENV2" ]; then
  echo $ENV2
else
  echo "B"
fi;
