#lang racket
;; simulator state

;; Register file R + PC + SP
(define R #f)
(define pc #f)
(define sp #f)

;; Memory + Instruction Memory
(define M #f)
(define IM #f)

;; Next free location in M
(define fm #f)

;; Has the simulator halted?
(define halted? #f)

;; simulator structures
(struct stack (v) #:transparent)
(struct array (v) #:transparent)

;; Helper functions from storing/loading
;; to/from a destination or source.
(define (store d v)
  (match d
    ;; Destinations can only be registers / memory addresses
    [`($ sp) (set! sp v)]
    [`sp (set! sp v)]
    [`($ ,n) (vector-set! R n v)]
    [`(! ,b ,o) (vector-set!
                (match (vector-ref M b)
                  [(stack v) v]
                 [(array v) v])
                o v)]))
(define (load s)
  (match s
    ;; Sources can be registers / constants
    [`($ sp) sp]
    [`sp sp]
    [`($ ,n) (vector-ref R n)]
    [`(! ,b ,o) `(! ,b ,o)]
    [(? number? i) i]))

(define (load-memory s)
  (match s
    ;; Sources can be memory addresses
    [`(! ,b ,o) (vector-ref
                (match (vector-ref M b)
                  [(stack v) v]
                  [(array v) v])
                o)]))
;; add rd, o
(define (add rd o)
  (define v1 (load `($ ,rd)))
  (define v2 (load o))

  (store `($ ,rd) (match `(,v1 ,v2)
    [`((! ,b1 ,o1) ,(? number? i)) `(! ,b1 ,(+ o1 i))]
    [`(,(? number? i) (! ,(? number? b2) ,o2)) `(! ,b2 ,(+ o2 i))]
    [`(,(? number? i1) ,(? number? i2)) (+ i1 i2)])))

;; mkstk r
(define (mkstk reg)
  (vector-set! M fm (stack (make-vector 0)))
  (define res `(! ,fm ,0))
  (set! fm (add1 fm))
  (store `($ ,reg) res))

;; salloc i
(define (salloc i)
  (match-define `(! ,l ,j) sp)
  (define v (stack-v (vector-ref M l)))
  (vector-set! M l (stack (vector-append (make-vector i empty) v)))
  (set! sp `(! ,l ,(+ j i))))

;; sfree i
(define (sfree i)
  (match-define `(! ,l ,j) sp)
  (define old-stack (stack-v (vector-ref M l)))
  (define new-stack (vector-drop old-stack i))
  (vector-set! M l (stack new-stack))
  (set! sp `(! ,l ,(- j i))))

;; malloc rd, i
(define (malloc reg i)
  (define results (make-vector i))
  (vector-set! M fm (array results))
  (store `($ ,reg) `(! ,fm 0))
  (set! fm (add1 fm)))

;; mov rd, o
(define (mov reg o)
  (store `($ ,reg) (load o)))

;; load rd, [rs + i]
(define (iload rd rs i)
  (match-define `(! ,l ,b) (load `($ ,rs)))
  (store `($ ,rd) (load-memory `(! ,l ,(+ b i)))))

;; store rs, [rd + i]
(define (istore rs rd i)
  (match-define `(! ,l ,b) (load `($ ,rd)))
  (store `(! ,l ,(+ b i)) (load `($ ,rs))))

;; call
(define (call o)
  ;; push next IP on current stack
  (match-define `(! ,l ,b) sp)
  (match-define `(! ,lpc _) pc)
  (set! sp `(! ,l ,(sub1 b)))
  (store `sp `(! ,(add1 lpc) 0))
  ;; set PC to (read o)
  (set! pc (load o)))

;; return
(define (return)
  ;; get next IP
  (define nip (load sp))
  ;; advance the SP again
  (match-define `(! ,l ,b) sp)
  (set! sp `(! ,l ,(add1 b)))
  ;; set PC to nip
  (set! pc nip))
  
(define dispatch-table (hash 'add add 'mkstk mkstk 'salloc salloc 'sfree sfree 'malloc malloc 'mov mov 'load iload 'store istore 'call call 'return return 'halt #f))

(define (fetch-execute-once)
  (match-define `(! ,lpc ,_) pc)
  (match-define `(,i ,@args) (vector-ref IM lpc))
  (if (equal? i 'halt)
      (set! halted? #t)
      (begin
        (set! pc `(! ,(add1 lpc) 0))
        (apply (hash-ref dispatch-table i) args))))

(define (load-program! l)
  (set! IM (list->vector l)))

(define (run-sstal! l)
  (load-program! l)
  (set! R (make-vector 32))
  (set! M (make-vector 32 empty))
  (set! pc `(! 0 0))
  (set! sp `(! 0 0))
  (set! halted? #f)
  (set! fm 0)

  (mkstk `sp)

  (let loop ()
    (unless halted?
      (fetch-execute-once)
      (loop))))
      
