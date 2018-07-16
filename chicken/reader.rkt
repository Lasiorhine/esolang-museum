#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  (define module-datum `(module chicken-mod chicken/expander
                          ,parse-tree))
 (datum->syntax #f module-datum))
(provide read-syntax)