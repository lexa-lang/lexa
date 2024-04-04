module dequeue_test

import std/os/env
import std/core/debug
import dequeue

pub fun main()
    var q: dequeue<int> := emptyQueue()
    q := q.pushFront(1)
    q := q.pushFront(2)
    val x = match q.popBack() 
                (y, q0) -> 
                    q := q0
                    y
    assert("", int/(==)(x, 1))
    val x = match q.popBack() 
                (y, q0) -> 
                    q := q0
                    y
    assert("", int/(==)(x, 2))