module dequeue

import std/core/list

pub struct dequeue<a>( front: list<a>, frontSize: int, rear: list<a>, rearSize: int );

fun listHeadExn<a>( xs: list<a> ): <exn> a
    match xs
        Cons( x, _ ) -> x
        Nil -> throw("Empty list")
        

pub fun emptyQueue<a>(): dequeue<a>
    Dequeue( Nil, 0, Nil, 0 )

pub fun isEmptyQueue<a>( q: dequeue<a> ): bool
    q.frontSize == 0 && q.rearSize == 0

pub fun size<a>( q: dequeue<a> ): int
    q.frontSize + q.rearSize

pub fun first<a>( q: dequeue<a> ): <exn> a
    if ( q.frontSize == 0 && q.rearSize == 1) then
        listHeadExn( q.rear )
    else
        listHeadExn( q.front )

pub fun last<a>( Dequeue(f, fs, r, rs): dequeue<a> ): <exn> a
    if ( fs == 1 && rs == 0) then
        listHeadExn( f )
    else
        listHeadExn( r )

pub fun check<a>( q : dequeue<a> ): dequeue<a>
    match q
        Dequeue(f, fs, r, rs) ->
            val c = 4
            val size1 = (fs + rs) / 2
            val size2 = (fs + rs) - size1
            if ( fs > c * rs + 1 ) then
                val front = f.take( size1 )
                val rear = r ++ f.drop( size1 ).reverse()
                Dequeue( front, size1, rear, size2 )
            else if ( rs > c * fs + 1 ) then
                val front = f ++ r.drop( size1 ).reverse()
                val rear = r.take( size1 )
                Dequeue( front, size2, rear, size1 )
            else
                q

pub fun pushFront<a>( q: dequeue<a>, el : a ): dequeue<a>
    match q
        Dequeue(f, fs, r, rs) ->
            Dequeue( Cons( el, f ), fs + 1, r, rs ).check()

pub fun popFront<a>( q: dequeue<a> ): <exn> (a, dequeue<a>)
    match q
        Dequeue( Nil, _, Cons(x, Nil), _ ) ->
            (x, emptyQueue())
        Dequeue( Nil, _, _, _ ) ->
            throw("Empty queue")
        Dequeue( Cons(x, rest), fs, r, rs ) ->
            (x, Dequeue( rest, fs - 1, r, rs ).check())

pub fun pushBack<a>( q: dequeue<a>, el : a ): dequeue<a>
    match q
        Dequeue(f, fs, r, rs) ->
            Dequeue( f, fs, Cons( el, r ), rs + 1 ).check()

pub fun popBack<a>( q: dequeue<a> ): <exn> (a, dequeue<a>)
    match q
        Dequeue( Cons(x, Nil), _, Nil, _ ) ->
            (x, emptyQueue())
        Dequeue( _, _, Nil, _ ) ->
            throw("Empty queue")
        Dequeue( f, fs, Cons(x, rest), rs ) ->
            (x, Dequeue( f, fs, rest, rs - 1 ).check())