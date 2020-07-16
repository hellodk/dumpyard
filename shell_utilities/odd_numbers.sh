#!/bin/bash
for n in {1..99}
do
   out=$(( $n % 2 ))
   if [ $out -ne 0 ]
   then
    echo "$n"
   fi
done