#lang racket
(require racket/pretty)
(require "a-sstal.rkt")
(require "t-sstal.rkt")
(require "sstal.rkt")
(require "programs.rkt")

(define compiled-program-1 (compile-program program1))
(define compiled-program-2 (compile-program program2))
(define compiled-program-3 (compile-program program3))

(define assembled-program-1 (assemble compiled-program-1))
(define assembled-program-2 (assemble compiled-program-2))
(define assembled-program-3 (assemble compiled-program-3))

(pretty-print assembled-program-2)
(run-sstal! assembled-program-2)