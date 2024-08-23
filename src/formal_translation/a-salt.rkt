#lang racket

(provide assemble)

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
       [`(call ,(? symbol? l)) `(call (* ,(hash-ref lmap l)))]
       [`(mov ,r ,(? symbol? l)) `(mov ,r (* ,(hash-ref lmap l)))]
       [`(add ,r ,(? symbol? l)) `(mov ,r (* ,(hash-ref lmap l)))]
       [`(jmp ,(? symbol? l)) `(jmp (* ,(hash-ref lmap l)))]
       [inst inst]))
   p))

(define (assemble p)
  (define-values (lmap p_) (collect-filter-label-defs p))
  (hash-set! lmap 'sp 'sp)
  ;; (pretty-print lmap)
  (replace-labels lmap p_))