#!/usr/bin/env sh

for dir in */; do
    stow $dir
done

