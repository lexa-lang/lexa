#lang racket

(provide program1 program2 program3)

;; def body(env, ask_L) {
;;    let val = raise ask_L 0 in
;;   43
;; }
;;
;; def ask(env, _) {
;;    env[0]
;; }
;;
;; def main() {
;;   let s = newref <42> in {
;;       handle <s>
;;            body
;;        with TAIL ask
;;    }
;; }

;; produces 43 in $1 --> val is 42, is placed on the stack
(define program1
    '((fun body (env askL)
        (let ([val (tailraise askL 0)])
            43)
      )
      (fun ask (env _)
        (let ([val (select env 0)])
            val)
      )
      (fun main ()
        (let ([s (newref 42)])
            (let ([x (handle= body tail ask under s)])
                x)))
    ))

;;
;; def body(env, ask_L) {
;;   let val = raise ask_L 0 in
;;     43
;; }
;; def ask(env, _) {
;;   let val = env[0] in
;;     val
;; }
;;
;; def main() {
;;    let s = newref <42> in {
;;        handle <s>
;;            body
;;        with ABORT ask
;;    }
;; }
(define program2
    '((fun body (env askL)
        (let ([val (abortraise askL 0)])
            43)
      )
      (fun ask (env _)
        (let ([val (select env 0)])
            val)
      )
      (fun main ()
        (let ([s (newref 42)])
            (let ([x (handle= body abort ask under s)])
                x)))
    ))
;; returns 42 in $1 --> aborts the handler with ask, returning 42, storing that in x, returning x.

;; // An general handler: that resumes resumption twice
;; // the whole program should evaluate to 44
;; def body(env, inc_L) {
;;     let _ = raise inc_L 0 in
;;     let val = env[0] in
;;     let _ = env[0] <- val + 1 in
;;     0
;; }
;; 
;; def inc(env, _, k) {
;;     let _ = resume k 0 in
;;     let _ = resume k 0 in
;;     0
;; }

;; def main() {
;;     let s = newref <42> in 
;;     let _ = {
;;         handle <s>
;;             body
;;         with MULTISHOT inc
;;     } in
;;     s[0]
;; }

;; produces 43 in $1
(define program3
    '((fun body (env incL)
        (let ([_ (raise incL 0)])
            (let ([val (select env 0)])
                (let ([newval (+ val 1)])
                    (let ([_ (update env 0 newval)])
                        0))))
      )
      (fun inc (env _ k)
        (let ([_ (resume k 0)]) 0)
           ;; (let ([_ (resume k 0)])
            ;;    0))
      )
      (fun main ()
        (let ([s (newref 42)])
            (let ([_ (handle+ body general inc under s)])
                (let ([val (select s 0)])
                    val)))
      )
    ))