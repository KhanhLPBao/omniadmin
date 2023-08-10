#!/bin/bash

init(){
for file in "bash/*"
do
    bash $file &
done
}
