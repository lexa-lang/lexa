#lang racket

(define (collect-filter-label-defs p)
  (define lmap (make-hash))
  (define pc 0)
  (values lmap (reverse (foldl
   (lambda (instr a)
     (match-define `(,op ,@args) instr)
     (cond
       [(equal? op 'label)
        (hash-set! lmap (first args) pc)
        a]
       [else
        (set! pc (add1 pc))
        (cons instr a)]))
   (list)
   p))))


(define (replace-labels lmap p)
  (map
   (lambda (inst)
     (match inst
       [`(call ,(? symbol? l)) `(call (! ,(hash-ref lmap l) 0))]
       [`(mov ,r ,(? symbol? l)) `(mov ,r (! ,(hash-ref lmap l), 0))]
       [`(add ,r ,(? symbol? l)) `(mov ,r (! ,(hash-ref lmap l), 0))]
       [inst inst]))
   p))

(define (assemble p)
  (define-values (lmap p_) (collect-filter-label-defs p))
  (replace-labels lmap p_))