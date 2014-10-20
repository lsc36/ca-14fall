#!/bin/bash

student_id=b01902010

testcase() {
    echo "=== Test $1"
    echo $1 > in.txt
    spim -file hw3_${student_id}.s > /dev/null 2>&1
    [ "$?" == "0" ] && echo "Result: `cat ${student_id}_out.txt`" || echo "Exited ($?)"
}

testcase '01,20'
testcase '02,01'
testcase '04,02'
testcase '08,06'
testcase '16,17'
testcase '32,14'
testcase '64,20'
testcase '04,03'
