#lang br
(require brag/support)

(define chicken-lexer
  (lexer-srcloc
   ["chicken" (token 'CHICKEN lexeme)]
   ["\n" (token 'RETURN lexeme)]
   [whitespace (token lexeme #:skip? #t)]))
(provide chicken-lexer)