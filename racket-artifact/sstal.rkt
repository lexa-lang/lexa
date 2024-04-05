#lang racket
(require racket/exn)
(provide run-sstal!)
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

(define (reset-sp)
  (match-define `(! ,l ,j) sp)
  (define old-stack (stack-v (vector-ref M l)))
  (define new-stack (vector-take old-stack (* -1 j)))
  (vector-set! M l (stack new-stack)))

;; Helper functions from storing/loading
;; to/from a destination or source.
(define (store d v)
  (match d
    ;; Destinations can only be registers / memory addresses
    [`($ sp) (set! sp v)
             ;; Storing to SP cuts off the rest of the stack.
             (reset-sp)]
    [`($ ,n) (vector-set! R n v)]
    [`(! ,b ,o) (match (vector-ref M b)
                  ;; stacks count backwards
                  [(stack vec) (vector-set! vec (sub1 (* -1 o)) v)]
                  [(array vec) (vector-set! vec o v)])]))

(define (load s)
  (match s
    ;; Sources can be registers / constants
    [`($ sp) sp]
    [`($ ,n) (vector-ref R n)]
    [`(! ,b ,o) `(! ,b ,o)]
    [`(* ,b) `(* ,b)]
    [(? number? i) i]))

(define (load-memory s)
  (match s
    ;; Sources can be memory addresses
    [`(! ,b ,o) (match (vector-ref M b)
                  ;; stacks count backwards
                  [(stack vec) (vector-ref vec (sub1 (* -1 o)))]
                  [(array vec) (vector-ref vec o)])]))
;; add rd, o
(define (add rd o)
  (match-define `($ ,rdf) rd)
  (define v1 (load `($ ,rdf)))
  (define v2 (load o))

  (store `($ ,rdf) (match `(,v1 ,v2)
    [`((! ,b1 ,o1) ,(? number? i)) `(! ,b1 ,(+ o1 i))]
    [`(,(? number? i) (! ,(? number? b2) ,o2)) `(! ,b2 ,(+ o2 i))]
    [`(,(? number? i1) ,(? number? i2)) (+ i1 i2)])))

;; mkstk r
(define (mkstk rd)  
  (match-define `($ ,rdf) rd)
  (vector-set! M fm (stack (make-vector 0)))
  (define res `(! ,fm ,0))
  (set! fm (add1 fm))
  (store `($ ,rdf) res))


;; sfree i
(define (sfree i)
  (match-define `(! ,l ,j) sp)
  (define old-stack (stack-v (vector-ref M l)))
  (define new-stack (vector-drop-right old-stack i))
  (vector-set! M l (stack new-stack))
  (set! sp `(! ,l ,(+ j i))))

;; malloc rd, i
(define (malloc rd i)
  (match-define `($ ,rdf) rd)
  (define results (make-vector i))
  (vector-set! M fm (array results))
  (store `($ ,rdf) `(! ,fm 0))
  (set! fm (add1 fm)))

;; mov rd, o
(define (mov rd o)
  (match-define `($ ,rdf) rd)
  (store `($ ,rdf) (load o)))

;; load rd, [rs + i]
(define (iload rd rs i)
  (match-define `($ ,rdf) rd)
  (match-define `($ ,rsf) rs)
  (match-define `(! ,l ,b) (load `($ ,rsf)))
  (store `($ ,rdf) (load-memory `(! ,l ,(+ b i)))))

;; store rs, [rd + i]
(define (istore rs rd i)
  (match-define `($ ,rdf) rd)
  (match-define `($ ,rsf) rs)
  (match-define `(! ,l ,b) (load `($ ,rdf)))
  (store `(! ,l ,(+ b i)) (load `($ ,rsf))))

;; call
(define (call o)
  ;; push next IP on current stack
  (match-define `(! ,l ,b) sp)
  (match-define `(* ,lpc) pc)
  (push `(* ,lpc))
  ;; set PC to (read o)
  (set! pc (load o)))

;; jmp
(define (jmp o)
  (set! pc (load o)))

;; return
(define (return)
  ;; get next IP
  (define nip (load-memory sp))
  ;; advance the SP again
  (sfree 1)
  ;; set PC to nip
  (set! pc nip))

;; push o
(define (push o)
  (match-define `(! ,l ,j) sp)
  (define v (stack-v (vector-ref M l)))
  (vector-set! M l (stack (vector-append v `#(,(load o)))))
  (set! sp `(! ,l ,(- j 1))))

;; pop rd
(define (pop rd)
  (match-define `($ ,rdf) rd)
  (match-define `(! ,l ,j) sp)
  (define old-stack (stack-v (vector-ref M l)))
  (store `($ ,rdf) (vector-ref old-stack 0))
  (define new-stack (vector-drop-right old-stack 1))
  (vector-set! M l (stack new-stack))
  (set! sp `(! ,l ,(+ j 1))))

(define (dump)
  (eprintf "SP=~a PC=~a ~n" sp pc)
  (match-define `(! ,ls ,js) sp)
  (eprintf "Stack: ~a ~n" (vector-ref M ls))
  (for ([i 8])
    (eprintf "$~a=~a ~n" i (vector-ref R i)))
  (match-define `(* ,l) pc)
  (when (> l 0) (eprintf "Dumped instruction: ~a ~n" (vector-ref IM (sub1 l))))
  (void))
  
(define dispatch-table (hash 'add add 'mkstk mkstk 'sfree sfree 'malloc malloc 'mov mov 
                       'load iload 'store istore 'call call 'return return 'halt #f
                       'push push 'pop pop 'jmp jmp 'dump dump))

(define (fetch-execute-once)
  (match-define `(* ,lpc) pc)
  (match-define `(,i ,@args) (vector-ref IM lpc))
  (set! pc `(* ,(add1 lpc)))
  (if (equal? i 'halt)
      (set! halted? #t)
      (begin
        (apply (hash-ref dispatch-table i) args))))

(define (load-program! l)
  (set! IM (list->vector l)))

(define (run-sstal! l)
  (load-program! l)
  (set! R (make-vector 32))
  (set! M (make-vector 32 empty))
  (set! pc `(* 0))
  (set! sp `(! 0 0))
  (set! halted? #f)
  (set! fm 0)

  (mkstk `($ sp))

  (with-handlers 
    [(exn:fail? (lambda (e) (set! halted? #t) (display (exn->string e)) (newline)
      (eprintf "SP=~a PC=~a ~n" sp pc)
      (match-define `(! ,ls ,js) sp)
      (eprintf "Stack: ~a ~n" (vector-ref M ls))
      (for ([i 8])
        (eprintf "$~a=~a ~n" i (vector-ref R i)))
      (match-define `(* ,l) pc)
      (eprintf "Faulting instruction: ~a ~n" (vector-ref IM (sub1 l)))
    ))]
    (let loop ()
      (unless halted?
        (fetch-execute-once)
        (loop))))
        
    (dump))
      
