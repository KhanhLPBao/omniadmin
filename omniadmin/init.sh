#!/bin/bash

init(){
for file in "bash/*"
do
    IF [ -f $file ]
    bash $file &
done
}
