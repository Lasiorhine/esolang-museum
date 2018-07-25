#lang br/quicklang
(require (for-syntax syntax/parse))
(require racket/list)
(require racket/bool)
(require brag/support)




;;;;;;;;CORE EXECUTION MECHANISMS 

;; MODULE BEGIN-- necessary, core macro for converting a parse tree to syntax
(define-macro (criminalicious-module-begin PARSE-TREE)
  #'(#%module-begin
;     'PARSE-TREE))
     PARSE-TREE))
(provide (rename-out [criminalicious-module-begin #%module-begin]))

;; CRIMINALICIOUS CENTRAL ENGINE
(define (fold-funcs stack-ptrs-l criminalicious-funcs)
  (for/fold ([current-stack-ptrs-l stack-ptrs-l])
            ([crime-func (in-list criminalicious-funcs)]
             #:unless (equal? crime-func "\n"))
    (apply crime-func current-stack-ptrs-l)))
 ;   (printf "Coming in through crime-func: ~a.  Coming in as args: ~a" crime-func current-stack-ptrs-l)))

;;VECTOR-LENGTH CONSTANT ESTABLISHED

(define vec-length-const 10)

;; PROGRAM MACRO
(define-macro (crim-program PROGRAM-ARG ...)
  #'(begin
      (define first-stack-ptrs-l (list (make-vector vec-length-const null) 0 0))
      (fold-funcs first-stack-ptrs-l (list PROGRAM-ARG ...))))
(provide crim-program)

;;;;;;;;;;;;;;;;;;Misc Helpers for Macros:

(define (target-stack-value arr ptr)
  (vector-ref arr ptr))

(define (set-stack-value! arr ptr val)
  (define new-arr (vector-copy arr))
  (vector-set! new-arr ptr val)
  new-arr)

(define (move-pointer ptr interval)
  (define new-ptr (+ ptr interval))
  (cond [(< new-ptr 0)
         (set! new-ptr 0)]
        [(>= new-ptr vec-length-const)
         (set! new-ptr (- vec-length-const 1))])
  new-ptr)

(define (stringify target-val)
   (match target-val
      [#f 'false]
      [#t 'true]
      [(? number?) (number->string target-val)]
      [(? empty?) "(null)"]
      [else target-val]))

;;;;;;;;;;;;;;;WRAPPER AND PASS-THROUGH MACROS

;DIRECTIVE WRAPPER
(define-macro (crim-directive DIRECTIVE-ARG ...)
  #'(first (list DIRECTIVE-ARG ...)))
(provide crim-directive)

;OP WRAPPER
(define-macro (crim-op OP-ARG ...)
  #'(first (list OP-ARG ...)))
(provide crim-op)

;LOOP-BRACKET TRASHBINS

;(left)
(define-macro (crim-l-open LOOP-OPEN-ARG ...)
   #'(void LOOP-OPEN-ARG ...))
(provide crim-l-open)

;(right)
(define-macro (crim-l-close LOOP-CLOSE-ARG ...)
   #'(void LOOP-CLOSE-ARG ...))
(provide crim-l-close)

;CATCH-ALL PASSTHROUGH (Function and Macro pair)
(define (catch-all stack top-ptr free-ptr)
  (list stack top-ptr free-ptr))

(define-macro (crim-catch-all CATCH-ALL-ARG ...)
  #'catch-all)
(provide crim-catch-all)

;;;;;;;;;;;;;;;;;;;;EXCEPTIONS:



; Special exception for terminating the program WITH A TAILORED STATEMENT.
(struct exn:end-crimes exn:fail ()) ; subtype of `exn:fail`
(define (end-program final-statement)
  (raise (exn:end-crimes
          (format "~v \n Per your request, the criminal justice system is now cancelled." final-statement)
          (current-continuation-marks))))

; Special exception for terminating the program WITHOUT a tailored statement.
(struct exn:plain-end-crimes exn:fail ()) ; subtype of `exn:fail`
(define (plain-end-program)
  (raise (exn:plain-end-crimes
          (format "\n Per your request, the criminal justice system is now cancelled.")
          (current-continuation-marks))))

; Feeder for random, legalistic flavor-text for errors:
(define error-msg-source (list
                          " ~v \n is a violation of a defendant's due process rights under the eighth amendment. \n See In re Gault, 387 U.S. 1 (1967)."
                          " ~v \n may constitute a violation of a defendant's right to discovery under Brady v. Maryland, 373 U.S. 83 (1963)"
                          " ~v \n is likely to constitute an abuse of prosecutorial discretion under Heckler v. Chaney, 470 U.S. 821 (1985)"
                          " ~v \n may constitute an illegal search under Maryland v. King, 569 U.S. 435 (2013)"
                          " ~v \n would tend to violate the common-law rule of lenity, as per United States v. Wiltberger, 18 U.S. 76 (1820)"))

; Exception for impossible operations (data-type mismatches, etc).
(struct exn:ops-error exn:fail ()) ; subtype of `exn:fail`
(define (operation-error error-statement)
  (raise (exn:ops-error
           (format (list-ref error-msg-source (random 0 4)) error-statement)
          (current-continuation-marks))))

;;;;;;;;;;;;;;;;;;;;COMMANDS:
;;;;;;;;;;;;;;;;;;;;;;;;;;;::OPS:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::MACRO/FUNCTION PAIRS

;ADVANCE-ONE (command: felony.) (Function and Macro pair)
;WORKS
(define (advance-one stack top-ptr free-ptr)
  (define new-free-ptr (move-pointer free-ptr 1))
  (cond [(> new-free-ptr top-ptr) (set! new-free-ptr top-ptr)])
  (list stack top-ptr new-free-ptr))

(define-macro (crim-adv-p FELONY-STOP-ARG ...)
  ;  #'(void FELONY-STOP-ARG ...))
  #'advance-one)
(provide crim-adv-p)

;REWIND-ONE (command: misdemeanor.) (Function and Macro pair)
;WORKS
(define (rewind-one stack top-ptr free-ptr)
  (define new-free-ptr (move-pointer free-ptr -1))
  (cond [(< new-free-ptr 0) (set! new-free-ptr 0)])
  (list stack top-ptr new-free-ptr))

(define-macro (crim-rew-p MISDEMEANOR-STOP-ARG ...)
;  #'(void MISDEMEANOR-STOP-ARG ...))
  #'rewind-one)
(provide crim-rew-p)

;INCREMENT-ONE (command: malice) (Function and Macro pair)
;WORKS
(define (increment-one stack top-ptr free-ptr)
  (define starting-cell-val (target-stack-value stack free-ptr))
  (cond [(not (number? starting-cell-val ))
         (let ([error-statement "Trying to increment something that is not a number"])
           (raise (operation-error error-statement)))])
  (define new-cell-val (+ starting-cell-val 1))
  (define updated-stack (set-stack-value! stack free-ptr new-cell-val))
  (list updated-stack top-ptr free-ptr))

(define-macro (crim-incr-one MALICE-ARG ...)
  ;  #'(void MALICE-ARG ...))
  #'increment-one)
(provide crim-incr-one)

;INCREMENT-TWO (command: malice aforethought) (Function and Macro pair)
;WORKS
(define (increment-two stack top-ptr free-ptr)
  (define starting-cell-val (target-stack-value stack free-ptr))
  (cond [(not (number? starting-cell-val ))
         (let ([error-statement "Trying to increment something that is not a number"])
           (raise (operation-error error-statement)))])
  (define new-cell-val (+ starting-cell-val 2))
  (define updated-stack (set-stack-value! stack free-ptr new-cell-val))
  (list updated-stack top-ptr free-ptr))

(define-macro (crim-incr-two MALICE-AFORETHOUGHT-ARG ...)
  ;  #'(void MALICE-AFORETHOUGHT-ARG ...))
  #'increment-two)
(provide crim-incr-two)

;DECREMENT-ONE (command: negligence) (Function and Macro pair)
;WORKS
(define (decrement-one stack top-ptr free-ptr)
  (define starting-cell-val (target-stack-value stack free-ptr))
  (cond [(not (number? starting-cell-val ))
         (let ([error-statement "Trying to decrement something that is not a number"])
           (raise (operation-error error-statement)))])
  (define new-cell-val (- starting-cell-val 1))
  (define updated-stack (set-stack-value! stack free-ptr new-cell-val))
  (list updated-stack top-ptr free-ptr))

(define-macro (crim-decr-one NEGLIGENCE-ARG ...)
  ;  #'(void NEGLIGENCE-ARG ...))
  #'decrement-one)
(provide crim-decr-one)

;DECREMENT-TWO (command: gross negligence) (Function and Macro pair)
;WORKS
(define (decrement-two stack top-ptr free-ptr)
  (define starting-cell-val (target-stack-value stack free-ptr))
  (cond [(not (number? starting-cell-val ))
         (let ([error-statement "Trying to decrement something that is not a number"])
           (raise (operation-error error-statement)))])
  (define new-cell-val (- starting-cell-val 2))
  (define updated-stack (set-stack-value! stack free-ptr new-cell-val))
  (list updated-stack top-ptr free-ptr))

(define-macro (crim-decr-two GROSS-NEGLIGENCE-ARG ...)
;  #'(void GROSS-NEGLIGENCE-ARG ...))
  #'decrement-two)
(provide crim-decr-two)

;MAKE-ASCII (command: by color or aid of) (Function and Macro pair)
;WORKS
(define (make-ascii stack top-ptr free-ptr)
  (define starting-cell-val (target-stack-value stack free-ptr))
    (cond [(not (number? starting-cell-val ))
         (let ([error-statement "Trying to make an ASCII character out of something other than an integer"])
           (raise (operation-error error-statement)))])
  (define new-char (integer->char starting-cell-val))
  (define char-string (string new-char))
  (define updated-stack (set-stack-value! stack top-ptr char-string))
  (define new-top-ptr (move-pointer top-ptr 1))
  (list updated-stack new-top-ptr top-ptr))

(define-macro (crim-ascii BY-COLOR-OR-AID-OF-ARG ...)
;  #'(void BY-COLOR-OR-AID-OF-ARG ...))
  #'make-ascii)
(provide crim-ascii)

;BLANK-CELL (command: upon conviction) (Function and Macro pair)
;WORKS
(define (blank-cell stack top-ptr free-ptr)
  (define updated-stack (set-stack-value! stack free-ptr null))
  (list updated-stack top-ptr free-ptr))

(define-macro (crim-blank UPON-CONVICTION-ARG ...)
    ;  #'(void UPON-CONVICTION-ARG ...))
  #'blank-cell)
(provide crim-blank)

;STDOUT-CELL (command: Class A) (Function and Macro pair)
;WORKS
(define (stdout-cell stack top-ptr free-ptr)
  (define starting-cell-val (target-stack-value stack free-ptr))
  (printf "The stack's value at the requested index is: ~a" starting-cell-val)
  (list stack top-ptr free-ptr))

(define-macro (crim-readout-curr CLASS-A-ARG ...)
  ;  #'(void CLASS-A-ARG ...))
  #'stdout-cell)
(provide crim-readout-curr)

;STDOUT-STACK (command: Class B) (Function and Macro pair)
;WORKS
(define (stdout-stack stack top-ptr free-ptr)
  (printf "Beginning with index zero, your entire criminal record is as follows: \n" )
  (for/vector #:length (cond [(< 0 top-ptr) top-ptr]
                             [else 1])
    ([i stack]) (printf "~a \n" (stringify i)))
  (list stack top-ptr free-ptr))

(define-macro (crim-readout-stack CLASS-B-ARG ...)
  ;  #'(void CLASS-B-ARG ...))
  #'stdout-stack)
(provide crim-readout-stack)


;GET-PRODUCT (command: damaging) (Function and Macro pair)
;WORKS
(define (get-product stack top-ptr free-ptr)
  (define upper-ptr (move-pointer top-ptr -1))
  (define lower-ptr (move-pointer top-ptr -2))
  (define val-top (target-stack-value stack upper-ptr))
  (define val-bottom (target-stack-value stack lower-ptr))
  (define type_test_list (list val-bottom val-top))
  (define new-product (cond
                      [(andmap number? type_test_list) (* val-bottom val-top)]
                      [else (let ([error-statement "Trying to multiply two things that aren't both numbers"])
                                   (raise (operation-error error-statement)))]))
  (define updated-stack (set-stack-value! stack lower-ptr new-product ))
  (define re-updated-stack (set-stack-value! updated-stack upper-ptr null))
  (list re-updated-stack upper-ptr lower-ptr))

(define-macro (crim-multip DAMAGING-ARG ...)
  ;  #'(void DAMAGING-ARG ...))
  #'get-product)
(provide crim-multip)

;GET-SUM (command: tampering) (Function and Macro pair)
;WORKS
(define (get-sum stack top-ptr free-ptr)
  (define upper-ptr (move-pointer top-ptr -1))
  (define lower-ptr (move-pointer top-ptr -2))
  (define val-top (target-stack-value stack upper-ptr))
  (define val-bottom (target-stack-value stack lower-ptr))
  (define type_test_list (list val-bottom val-top))
  (define new-sum (cond
                      [(andmap number? type_test_list) (+ val-bottom val-top)]
                      [else (let ([error-statement "Trying to add two things that aren't both numbers"])
                                   (raise (operation-error error-statement)))]))
  (define updated-stack (set-stack-value! stack lower-ptr new-sum ))
  (define re-updated-stack (set-stack-value! updated-stack upper-ptr null))
  (list re-updated-stack upper-ptr lower-ptr))

(define-macro (crim-add TAMPERING-ARG ...)
  ;  #'(void TAMPERING-ARG ...))
  #'get-sum)
(provide crim-add)

;GET-DIFFERENCE (command: impeding) (Function and Macro pair)
;WORKS
(define (get-difference stack top-ptr free-ptr)
  (define upper-ptr (move-pointer top-ptr -1))
  (define lower-ptr (move-pointer top-ptr -2))
  (define val-top (target-stack-value stack upper-ptr))
  (define val-bottom (target-stack-value stack lower-ptr))
  (define type_test_list (list val-bottom val-top))
  (define new-difference (cond
                      [(andmap number? type_test_list) (- val-bottom val-top)]
                      [else (let ([error-statement "Trying to calculate the difference between two things that aren't numbers"])
                                   (raise (operation-error error-statement)))]))
  (define updated-stack (set-stack-value! stack lower-ptr new-difference ))
  (define re-updated-stack (set-stack-value! updated-stack upper-ptr null))
  (list re-updated-stack upper-ptr lower-ptr))

(define-macro (crim-subtr IMPEDING-ARG ...)
;  #'(void IMPEDING-ARG ...))
  #'get-difference)
(provide crim-subtr)

;STRING-CONCAT (command: bodily harm) (Function and Macro pair)
;WORKS
(define (string-concat stack top-ptr free-ptr)
  (define lower-ptr (- top-ptr 2))
  (define upper-ptr (- top-ptr 1))
  (define string-a (vector-ref stack lower-ptr))
  (define string-b (vector-ref stack upper-ptr))
  (define type_test_list (list string-a string-b))
  (define new-string (cond
                      [(andmap string? type_test_list) (string-append string-a string-b)]
                      [else (let ([error-statement "Trying to concatenate two things that aren't strings"])
                                   (raise (operation-error error-statement)))]))
  (define new-stack (set-stack-value! stack lower-ptr new-string ))
  (define newer-stack (set-stack-value! new-stack upper-ptr null))
  (list newer-stack upper-ptr lower-ptr))

(define-macro (crim-concat BODILY-HARM-ARG ...)
  #'(void BODILY-HARM-ARG ...))
; #'string-concat
(provide crim-concat)

;COMPARE-FOR-MATCH (command: purposefully) (Function and Macro pair)
;WORKS
(define (compare-for-match stack top-ptr free-ptr)
  (define lower-ptr (- top-ptr 2))
  (define upper-ptr (- top-ptr 1))
  (define value-a (vector-ref stack lower-ptr))
  (define value-b (vector-ref stack upper-ptr))
  (define comp-result (eqv? value-a value-b))
  (define new-stack (set-stack-value! stack top-ptr comp-result ))
  (define new-top-ptr (move-pointer top-ptr 1))
  (list new-stack new-top-ptr top-ptr))

(define-macro (crim-comp-same PURPOSEFULLY-ARG ...)
  #'(void PURPOSEFULLY-ARG ...))
; #'compare-for-match
(provide crim-comp-same)

;COMPARE-FOR-DIFF (command: recklessly) (Function and Macro pair)
;WORKS
(define (compare-for-diff stack top-ptr free-ptr)
  (define lower-ptr (- top-ptr 2))
  (define upper-ptr (- top-ptr 1))
  (define value-a (vector-ref stack lower-ptr))
  (define value-b (vector-ref stack upper-ptr))
  (define comp-result (eqv? value-a value-b))
  (define vals-diffr (eqv? comp-result #f))
  (define new-stack (set-stack-value! stack top-ptr vals-diffr ))
  (define new-top-ptr (move-pointer top-ptr 1))
  (list new-stack new-top-ptr top-ptr))

(define-macro (crim-comp-diffr RECKLESSLY-ARG ...)
  #'(void RECKLESSLY-ARG ...))
; #'compare-for-diff
(provide crim-comp-diffr)

;COPY-TOP-VAL (command: possessing) (Function and Macro pair)
;WORKS
(define (copy-top-val stack top-ptr free-ptr)
  (define finder-ptr (move-pointer top-ptr -1))
  (define to-copy (target-stack-value stack finder-ptr))
  (define new-stack (set-stack-value! stack top-ptr to-copy ))
  (define new-top-ptr (move-pointer top-ptr 1))
  (list new-stack new-top-ptr top-ptr))

(define-macro (crim-copy POSSESSING-ARG ...)
;  #'(void POSSESSING-ARG ...))
   #'copy-top-val)
(provide crim-copy )

;PRINT-CURRENT-AND-CLOSE (command: intent of the legislature) (Function and Macro Pair)
(define (print-curr-and-end stack top-ptr free-ptr)
  (define last-targeted-value (target-stack-value stack free-ptr))
  (define printable-last (stringify last-targeted-value))
  (define final-statement (format "Your last criminal endeavor resulted in: ~v." printable-last))
  (raise (end-program final-statement)))        

(define-macro (crim-end-curr INTENT-OF-THE-LEGISLATURE-ARG ...)
;  #'(void INTENT-OF-THE-LEGISLATURE-ARG ...))
   #'print-curr-and-end)
(provide crim-end-curr)

;PRINT-LAST-AND-END(command: at common law) (Function and Macro Pair)
;WORKS
(define (print-last-and-end stack top-ptr free-ptr)
  (define last-populated-ptr (move-pointer top-ptr -1))
  (define top-value (target-stack-value stack last-populated-ptr))
  (define printable-top (stringify top-value))
  (define final-statement (format "The result of your last criminal endeavor was: ~v." printable-top))
  (raise (end-program final-statement)))        

(define-macro (crim-end-last AT-COMMON-LAW-ARG ...)
;  #'(void AT-COMMON-LAW-ARG ...))
   #'print-last-and-end)
(provide crim-end-last )

;PRINT-NONE-AND-END(command: model jury instruction) (Function and Macro Pair)
;WORKS
(define (print-none-and-end stack top-ptr free-ptr)
  (define final-statement (format "The result of your last criminal endeavor is being kept under seal." ))
  (raise (end-program final-statement)))        

(define-macro (crim-end-none MODEL-JURY-INSTRUCTION-ARG ...)
;  #'(void MODEL-JURY-INSTRUCTION-ARG ...))
   #'print-none-and-end)
(provide crim-end-none )

;PRINT-STACK-AND-END(command: model jury instruction) (Function and Macro Pair)
;WORKS
(define (print-stack-and-end stack top-ptr free-ptr)
  (stdout-stack stack top-ptr free-ptr)
  (raise (plain-end-program)))        

(define-macro (crim-end-stack SSDGM-ARG ...)
;  #'(void SSDGM-ARG-ARG ...))
   #'print-stack-and-end)
(provide crim-end-stack )

;;;;;;;;;;;;;;;;;;;;COMMANDS:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;OPS:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::STAND-ALONE MACROS

;CRIM-NUMB: (command ($INT.00)) (Stand-alone macro)
;WORKS
(define-macro (crim-numb NUMERICAL-ARG ...)
  #'(lambda (stack top-ptr free-ptr)
      (let ([target-int (second (list NUMERICAL-ARG ...))])
        (let ([updated-stack (set-stack-value! stack top-ptr target-int)]
              [new-top-ptr (move-pointer top-ptr 1)])
          (list updated-stack new-top-ptr top-ptr)))))    
(provide crim-numb)

;READ-SPECIFIED (command: pursuant to CCR) (Stand-alone macro)
;WORKS
(define-macro (crim-read-specified PURSUANT-TO-CCR-ARG ...)
  #'(lambda (stack top-ptr free-ptr)
      (let ([finder-ptr (last (list PURSUANT-TO-CCR-ARG ...))])
        (cond [(> finder-ptr (- top-ptr 1))
               (let ([error-statement "Trying to use an excessively high number as an index"])
                 (raise (operation-error error-statement)))]
              [else (let ([target-val (target-stack-value stack finder-ptr)])
                      (let ([updated-stack (set-stack-value! stack top-ptr target-val)]
                            [new-top-ptr (move-pointer top-ptr 1)])
                        (list updated-stack new-top-ptr finder-ptr)))]))))        
(provide crim-read-specified)

;WRITE-TO (command: notwithstanding sub-chapter) (Stand-alone macro)
(define-macro (crim-write-to NOTWITHSTANDING-SUB-CHAPTER-ARG ...)
  #'(lambda (stack top-ptr free-ptr)
      (let ([writer-ptr (last (list NOTWITHSTANDING-SUB-CHAPTER-ARG ...))])
        (cond [(> writer-ptr (- top-ptr 1))
               (let ([error-statement "Trying to use an excessively high number as an index"])
                 (raise (operation-error error-statement)))]
              [else (let ([finder-ptr (move-pointer top-ptr -1)])
                      (let ([val-to-write (target-stack-value stack finder-ptr)])
                        (let ([updated-stack (set-stack-value! stack writer-ptr val-to-write)])
                          (list updated-stack top-ptr free-ptr))))]))))        
(provide crim-write-to)


;;;;;;;;;;;;;;;;;;;;;;;;;;;::LOOP:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;::::STAND-ALONE MACRO

  
;LOOP MACRO
(define-macro (crim-loop "pursuant to subsection " CRIM-PROGRAM ... "or intent." )
  #'(lambda (stack top-ptr free-ptr )
      (for/fold ([current-apl (list arr ptr)])
                ([i (in-range 0 iterations)]
                 #:break (zero? (apply current-byte
                                       current-apl)))
        (fold-funcs current-apl (list  ...)))))
(provide crim-loop)



