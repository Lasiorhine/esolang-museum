#lang br
(require brag/support)

(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define (make-tokenizer port [path #f])
  (define (next-token)
    (define criminalicious-lexer
      (lexer
       ["($" (token 'OPEN-NUMB lexeme)]
       [".00)" (token 'CLOSE-NUMB lexeme)]
       ["A" (token 'CAP-A lexeme)]
       ["aforethought" (token 'AFORETHOUGHT lexeme)]
       ["aid" (token 'AID lexeme)]
       ["at" (token 'AT lexeme)]
       ["a" (token 'MIN-A lexeme)]
       ["B" (token 'CAP-B lexeme)]
       ["bodily" (token 'BODILY lexeme)]
       ["by" (token 'BY lexeme)]
       ["CCR" (token 'CCR lexeme)]
       ["Class" (token 'CLASS lexeme)]
       ["color" (token 'COLOR lexeme)]
       ["common" (token 'COMMON lexeme)]
       ["conviction" (token 'CONVICTION lexeme)]
       ["damaging" (token 'DAMAGING lexeme)]
       ["gross" (token 'GROSS lexeme)]
       ["felony." (token 'FELONY-STOP lexeme)]
       ["guilty" (token 'GUILTY lexeme)]
       ["harm" (token 'HARM lexeme)]
       ["impeding" (token 'IMPEDING lexeme)]
       ["instruction" (token 'INSTRUCTION lexeme)]
       ["intent" (token 'INTENT lexeme)]
       ["is" (token 'IS lexeme)]
       ["jury" (token 'JURY lexeme)]
       ["knowledge" (token 'KNOWLEDGE lexeme)]
       ["law" (token 'LAW lexeme)]
       ["legislature" (token 'LEGISLATURE lexeme)]
       ["malice" (token 'MALICE lexeme)]
       ["misdemeanor." (token 'MISDEMEANOR-STOP lexeme)]
       ["model" (token 'MODEL lexeme)]
       ["negligence" (token 'NEGLIGENCE lexeme)]
       ["notwithstanding" (token 'NOTWITHSTANDING lexeme)]
       ["of" (token 'OF lexeme)]
       ["or" (token 'OR lexeme)]
       ["person" (token 'PERSON lexeme)]
       ["possessing" (token 'POSSESSING lexeme)]
       ["purposefully" (token 'PURPOSEFULLY lexeme)]
       ["pursuant" (token 'PURSUANT lexeme)]
       ["recklessly" (token 'RECKLESSLY lexeme)]
       ["SSDGM" (token 'SSDGM lexeme)]
       ["sub-chapter" (token 'SUB-CHAPTER lexeme)]
       ["tampering" (token 'TAMPERING lexeme)]
       ["the" (token 'THE lexeme)]
       ["to" (token 'TO lexeme)]
       ["upon" (token 'UPON lexeme)]
       ["with" (token 'WITH lexeme)]
       [digits (token 'INTEGER (string->number lexeme))]
       ["\n" (token lexeme #:skip? #t)]
       [whitespace (token lexeme #:skip? #t)]
       [any-char (next-token)]))
    (criminalicious-lexer port))  
  next-token)

(provide make-tokenizer)