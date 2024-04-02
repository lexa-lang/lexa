#lang racket

;; compile env program -> (values #let #pgrm)
(define (compile-value env value [result `($ 1)])
  (match value
    ;; variable
    [(? symbol? name)
     `(load result sp ,(index-of env name))]
    ;; number
    [(? number? i)
     `(mov result ,i)]
    ;; symbol (function name)
    [(? symbol? i)
     `(mov result i)]))

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
    [`(let ([,x (set-and-return ,a ,i ,v)]) ,t)
      (define-values (nlet cb) (compile-statement (cons x env) t))
     (values (add1 nlet)
              `(,@(compile-value env v `($ 1))
                ,@(compile-value env a `($ 2))
                (store ($ 1) ($ 2) ,i)
                (push ($ 1))
                ,@cb))   
    ]
    ;; handler (new stack, +)
    [`(let ([,x (handle+ ,Lbody ,Lop under ,vEnv)]) ,t)
     (define cEnv (compile-value env vEnv `($ 3)))
     (define-values (nlet cb)
       (compile-statement (cons x env) t))
     (define Lenter (gensym))
     (values (add1 nlet)
             `(,@cEnv
               (mov ($ 2) ,Lop)
               (mov ($ 1) ,Lbody)
               (call ,Lenter)
               (push ($ 1))
               ,@cb
               (label ,Lenter)
               (mov ($ 29) sp)
               (mkstk sp)
               (push ($ 2))
               (push ($ 3))
               (push ($ 29))
               (mov ($ 4) ($ 1))
               (mov ($ 2) sp)
               (mov ($ 1) ($ 3))
               (call ($ 4))
               (pop ($ 2))
               (sfree 2)
               (mov sp ($ 2))
               (return)))]
    ;; handler (same stack, =)
    [`(let ([,x (handle= ,Lbody ,Lop under ,vEnv)]) ,t)
     (define cEnv (compile-value env vEnv `($ 3)))
     (define-values (nlet cb)
       (compile-statement (cons x env) t))
     (define Lenter (gensym))
     (values (add1 nlet)
             `(,@cEnv
               (mov ($ 2) ,Lop)
               (mov ($ 1) ,Lbody)
               (call ,Lenter)
               (push ($ 1))
               ,@cb
               (label ,Lenter)
               (push ($ 2))
               (push ($ 3))
               (mov ($ 4) ($ 1))
               (mov ($ 2) sp)
               (mov ($ 1) ($ 3))
               (call ($ 4))
               (pop ($ 2))
               (sfree 1)
               (return)))]
    ;; raise
    [`(let ([,x (raise ,v1 ,v2)]) ,t)
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
      (define cV1 (compile-value env v1 `($ 1)))
      (define cV2 (compile-value env v2 `($ 2)))
      (define Lraise (gensym))
      (values (add1 nlet)
              `(
                ,@cV2
                ,@cV1
                (call ,Lraise)
                (push ($ 1))
                ,@cb
                (label ,Lraise)
                (load ($ 29) ($ 1) 0)
                (store sp ($ 1) 0)
                (mov sp ($ 29))
                (load ($ 4) ($ 1) 2)
                (malloc ($ 3) 1)
                (store ($ 1) ($ 3) 0)
                (load ($ 1) ($ 1) 1)
                (call ($ 4))
                (return)))]
    [`(let ([,x (tailraise ,v1 ,v2)]) ,t)
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
      (define cV1 (compile-value env v1 `($ 1)))
      (define cV2 (compile-value env v2 `($ 2)))
      (values (add1 nlet)
              `(,@cV2
                ,@cV1
                (load ($ 3) ($ 1) 2)
                (load ($ 1) ($ 1) 1)
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
                (load sp ($ 1) 0)
                (load ($ 3) ($ 1) 2)
                (load ($ 1) ($ 1) 1)
                (call ($ 3))
                (push ($ 1))
                (jump ($ 3))))]
    ;; resume
    [`(let ([,x (resume ,v1 ,v2)]) ,t)
      (define-values (nlet cb)
       (compile-statement (cons x env) t))
      (define cV1 (compile-value env v1 `($ 1)))
      (define cV2 (compile-value env v2 `($ 2)))
      (define Lresume (gensym))
      (values
       (add1 nlet)
       `(,@cV2
         ,@cV1
         (call Lresume)
         (push ($ 1))
         ,@cb
         (label Lresume)
         (load ($ 3) ($ 1) 0)
         ;; set an invalid IP to crash if
         ;; double-shot resume
         (mov ($ 29) -1)
         (store ($ 29) ($ 1) 0)
         (load ($ 29) ($ 3) 0)
         (store sp ($ 3) 0)
         (mov ($ 1) ($ 2))
         (mov sp ($ 29))
         (return)
         ))]
    ;; 
    ;; value
    [`(let ([,x ,v]) t)
     (compile-value env v)
     `(push ($ 1))]))
    
       
(define (compile-program pgrm)
   (match pgrm
     ;; nothing
    [`() `()]
     ;; ( (fun name (args) body) ... )
    [`((fun ,name (,@params) ,body) ,rest ...)
     (define-values (num-let compiled-body)
       (compile-statement params body))
     (define Lskip (gensym))
     (define Lfun (gensym))
     `((jmp ,Lskip)
       (label name)
       ,@(for/list ([i (in-range (length params) 0 -1)])
           `(push ($ ,i)))
       ,@compiled-body
       (sfree (+ (length params) num-let))
       (return)
       (label ,Lskip)
       ,(compile-program rest))]))