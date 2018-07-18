#lang br
(require "lexer.rkt" brag/support)

(define (make-tokenizer port [path #f])
  (define (next-token) (chicken-lexer port))
  next-token)
(provide make-tokenizer)

