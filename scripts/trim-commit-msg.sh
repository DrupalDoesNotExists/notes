#!/bin/bash
# Trim commit message and get new post meta

# get commit message from argv
commit_msg=$1
meta=$(echo ${commit_msg} | sed 's/post: /post:/g' | sed 's/; /;/g' | awk -F'post:' '{print $2}')
echo ${meta}

# split meta by ; (bash-compatible ONLY!)
values=(${meta//;/ })

# put github output
echo "slug=${values[0]}" >> $GITHUB_OUTPUT
echo "title=${values[@]:1}" >> $GITHUB_OUTPUT
