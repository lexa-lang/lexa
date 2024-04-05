#lang racket

(provide compile-program)

;; compile env program -> (values #let #pgrm)
(define (compile-value env value [result `($ 1)])
  (match value
    ;; variable
    [(? symbol? name)
     `((load ,result ($ sp) ,(index-of env name)))]
    ;; number
    [(? number? i)
     `((mov ,result ,i))]
    ;; symbol (function name)
    [(? symbol? i)
     `((mov ,result i))]))

(define (compile-handler-type type [result `($ 1)])
  (match type
    ['general
     `((mov ,result 0))]
    ['tail
     `((mov ,result 2))]
    ['abort
     `((mov ,result 1))])
)

;; compile env program -> (values #let #pgrm)
(define (compile-statement env program)
  (match program
    ;; + (arithmetic)
    [`(let ([,x (+ ,v1 ,v2)]) ,t)
     (define cv1 (compile-value env v1 `($ 1)))
     (define cv2 (compile-value env v2 `($ 2)))
     (define-values (nlet cb) (compile-statement (cons x env) t))
     (values (add1 nlet)
             `(,@cv1
               ,@cv2
               (add ($ 2) ($ 1))
               (push ($ 2))
               ,@cb))]
    ;; function call
    [`(let ([,x (call ,f ,args ...)]) ,t)
     (define fn (compile-value env f `($ 0)))
     (define argcs
       (for/list ([a args]
                  [i (in-range 1 (add1 (length args)))])
         (compile-value env a `($ ,i))))
     (define-values (nlet cb) (compile-statement (cons x env) t))
     (values (add1 nlet)
             `(,@fn
               ,@(apply append argcs)
               (call ($ 0))
               (push ($ 1))
               ,@cb))]
    ;; record allocation
    [`(let ([,x (newref ,vs ...)]) ,t)
     (define len (length vs))
     (define-values (nlet cb) (compile-statement (cons x env) t))
     (values (add1 nlet)
             `((malloc ($ 2) ,len)
               ,@(apply append
                        (for/list ([v vs]
                                   [i (length vs)])
                          `(,@(compile-value env v)
                            (store ($ 1) ($ 2) ,i))))
               (push ($ 2))
               ,@cb))]
    ;; record selection
    [`(let ([,x (select ,v ,i)]) ,t)
     (define-values (nlet cb) (compile-statement (cons x env) t))
     (values (add1 nlet)
              `(,@(compile-value env v)
                (load ($ 1) ($ 1) ,i)
                (push ($ 1))
                ,@cb))
     ]
    ;; record set
    [`(let ([,x (update ,a ,i ,v)]) ,t)
      (define-values (nlet cb) (compile-statement (cons x env) t))
     (values (add1 nlet)
              `(,@(compile-value env v `($ 1))
                ,@(compile-value env a `($ 2))
                (store ($ 1) ($ 2) ,i)
                (push ($ 1))
                ,@cb))
    ]
    ;; handler (new stack, +)
    [`(let ([,x (handle+ ,Lbody ,A ,Lop under ,vEnv)]) ,t)
     (define cEnv (compile-value env vEnv `($ 3)))
     (define-values (nlet cb)
       (compile-statement (cons x env) t))
     (define Lenter (gensym "let-handle+-"))
     (define Lend (gensym "let-handler+-end "))
     (unless (equal? A 'general)
       (error "handle+ only supports general handlers."))
     (values (add1 nlet)
             `(,@(compile-handler-type A `($ 4))
               ,@cEnv
               (mov ($ 2) ,Lop)
               (mov ($ 1) ,Lbody)
               (call ,Lenter)
               (push ($ 1))
               ,@cb
               (jmp ,Lend)
               (label ,Lenter)
               (mov ($ 5) ($ sp))
               (mkstk ($ sp))
               (push ($ 2))
               (push ($ 3))
               (push ($ 4))
               (push ($ 5))
               (mov ($ 6) ($ 1))
               (mov ($ 2) ($ sp))
               (mov ($ 1) ($ 3))
               (call ($ 6))
               (pop ($ 2))
               (sfree 3)
               (mov ($ sp) ($ 2))
               (return)
               (label ,Lend)))]
    ;; handler (same stack, =)
    [`(let ([,x (handle= ,Lbody ,A ,Lop under ,vEnv)]) ,t)
     (define cEnv (compile-value env vEnv `($ 3)))
     (define-values (nlet cb)
       (compile-statement (cons x env) t))
     (define Lenter (gensym "let-handle="))
     (define Lend (gensym "let-handler=-end "))
      (unless (or (equal? A 'abort)
                  (equal? A 'tail))
       (error "handle= only supports tail recursive or escape handlers."))
     (values (add1 nlet)
             `(,@(compile-handler-type A `($ 4))
               ,@cEnv
               (mov ($ 2) ,Lop)
               (mov ($ 1) ,Lbody)
               (call ,Lenter)
               (push ($ 1))
               ,@cb
               (jmp ,Lend)
               (label ,Lenter)
               (push ($ 2))
               (push ($ 3))
               (push ($ 4))
               (push -70) ;; invalid value
               (mov ($ 6) ($ 1))
               (mov ($ 2) ($ sp))
               (mov ($ 1) ($ 3))
               (call ($ 6))
               (sfree 4)
               (return)
               (label ,Lend)))]
    ;; raise
    [`(let ([,x (raise ,v1 ,v2)]) ,t)
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
      (define cV1 (compile-value env v1 `($ 1)))
      (define cV2 (compile-value env v2 `($ 2)))
      (define Lraise (gensym "let-raise-"))
      (define Lraiseend (gensym "let-raise-end"))
      (values (add1 nlet)
              `(
                ,@cV2
                ,@cV1
                (call ,Lraise)
                (push ($ 1))
                ,@cb
                (jmp ,Lraiseend)
                (label ,Lraise)
                (load ($ 4) ($ 1) 0)
                (store ($ sp) ($ 1) 0)
                (mov ($ sp) ($ 4))
                (load ($ 5) ($ 1) 3)
                (malloc ($ 3) 1)
                (store ($ 1) ($ 3) 0)
                (load ($ 1) ($ 1) 2)
                (call ($ 5))
                (return)
                (label ,Lraiseend)))]
    ;; tailraise
    [`(let ([,x (tailraise ,v1 ,v2)]) ,t)
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
      (define cV1 (compile-value env v1 `($ 1)))
      (define cV2 (compile-value env v2 `($ 2)))
      (values (add1 nlet)
              `(,@cV2
                ,@cV1
                (load ($ 3) ($ 1) 3)
                (load ($ 1) ($ 1) 2)
                (call ($ 3))
                (push ($ 1))
                ,@cb))]
    ;; abort ==> t ignored
    [`(let ([,x (abortraise ,v1 ,v2)]) ,t)
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
      (define cV1 (compile-value env v1 `($ 1)))
      (define cV2 (compile-value env v2 `($ 2)))
      (values (add1 nlet)
              `(,@cV2
                ,@cV1
                (dump)
                (load ($ 3) ($ 1) 3)
                (mov ($ sp) ($ 1))
                (load ($ 1) ($ 1) 2)
                (dump)
                (sfree 4)
                (jmp ($ 3))))]
    ;; resume
    [`(let ([,x (resume ,v1 ,v2)]) ,t)
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
      (define cV1 (compile-value env v1 `($ 1)))
      (define cV2 (compile-value env v2 `($ 2)))
      (define Lresume (gensym "let-resume"))
      (define Lresume-end (gensym "let-resume-end"))
      (values
       (add1 nlet)
       `(,@cV2
         ,@cV1
         (dump)
         (call ,Lresume)
         (push ($ 1))
         ,@cb
         (jmp ,Lresume-end)
         (label ,Lresume)
         (load ($ 3) ($ 1) 0)
         ;; set an invalid IP to crash if
         ;; double-shot resume
         (mov ($ 10) -71)
         (store ($ 10) ($ 1) 0)
         (load ($ 4) ($ 3) 0)
         (store ($ sp) ($ 3) 0)
         (mov ($ 1) ($ 2))
         (mov ($ sp) ($ 4))
         (return)
         (label ,Lresume-end)
         ))]
    ;; 
    ;; value
    [`(let ([,x ,v]) ,t)
      (define result (compile-value env v))
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
     (values (add1 nlet) `(,@result (push ($ 1)) ,@cb))]
    ;; value
    [x (values 0 (compile-value env x))]))
    
       
(define (compile-program pgrm)
   (match pgrm
     ;; nothing
    [`() `((call main) (halt))]
     ;; ( (fun name (args) body) ... )
    [`((fun ,name (,@params) ,body) ,rest ...)
     (define-values (num-let compiled-body)
      (compile-statement params body))
     (define Lskip (gensym (format "~a-skip" name)))
     `((jmp ,Lskip)
       (label ,name)
       ,@(for/list ([i (in-range (length params) 0 -1)])
           `(push ($ ,i)))
       ,@compiled-body
       (sfree ,(+ (length params) num-let))
       (return)
       (label ,Lskip)
       ,@(compile-program rest))]))