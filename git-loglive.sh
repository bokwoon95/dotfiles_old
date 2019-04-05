#!/bin/bash
clear
find .git -type f |
  entr git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --reflog |
  grep "(HEAD" --context=10
