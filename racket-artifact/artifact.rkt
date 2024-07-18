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

(printf "Test program 1: ~n")
(pretty-print compiled-program-1)
(printf "Assembled program 1: ~n")
(pretty-print assembled-program-1)
(printf "Running program 1...~n")
(run-sstal! assembled-program-1)
;; Check the result makes sense
(unless (equal? (vector-ref R 1) 43)
  (error "Program 1 result did not match expected"))
(printf "================================~n")


(printf "Test program 2: ~n")
(pretty-print compiled-program-2)
(printf "Assembled program 2: ~n")
(pretty-print assembled-program-2)
(printf "Running program 2...~n")
(run-sstal! assembled-program-2)
;; Check the result makes sense
(unless (equal? (vector-ref R 1) 42)
  (error "Program 1 result did not match expected"))
(printf "================================~n")


(printf "Test program 3: ~n")
(pretty-print compiled-program-3)
(printf "Assembled program 3: ~n")
(pretty-print assembled-program-3)
(printf "Running program 3...~n")
(run-sstal! assembled-program-3)
;; Check the result makes sense
(unless (equal? (vector-ref R 1) 43)
  (error "Program 1 result did not match expected"))
(printf "================================~n")
