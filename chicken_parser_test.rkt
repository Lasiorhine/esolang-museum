#lang br
(require racket/sequence)
(require "chicken/parser.rkt" "chicken/tokenizer.rkt" brag/support)
(define str #<<HERE

chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken
chicken chicken
chicken chicken chicken chicken chicken chicken

chicken chicken chicken chicken chicken chicken chicken chicken chicken
chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken chicken

chicken chicken

HERE
)

(define test-datums (parse-to-datum (apply-tokenizer make-tokenizer str)))





