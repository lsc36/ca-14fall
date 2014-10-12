#!/bin/bash

student_id=b01902010

testcase() {
    echo "=== Test $1"
    echo $1 > in.txt
    spim -file hw2_${student_id}.s > /dev/null 2>&1
    [ "$?" == "0" ] && echo "Result: `cat ${student_id}_out.txt`" || echo "Exited ($?)"
}

testcase '71+22'
testcase '71-22'
testcase '71*22'
testcase '71/22'
testcase '71%22'
testcase '71/00'
