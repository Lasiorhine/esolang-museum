#lang br/quicklang
(require (for-syntax syntax/parse))
(require racket/list)
(require racket/bool)

;; MODULE BEGIN-- necessary, core macro for converting a parse tree to syntax

(define-macro (chicken-module-begin PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE))
(provide (rename-out [chicken-module-begin #%module-begin]))

;; CORE ENGINES THAT DRIVE THE PROGRAM 

#| Mechaninsm for Using Commands to Manipulate the Stack and Pointers:

Commands come in through the list-object chicken-funcs.
Stack-apsl means 'stack array and pointers list'.
In the for/fold loop, current-stack-aspl is the accumulator, which recieves its value through stack-apsl.
The ([chicken-func (in-list chicken-funcs)]) part is the "for clause," which pulls functions out of the chicken-funcs list sequentially, with chicken-func as the iterator. (The guard statement, with #:unless, is there to prevent it from trying to act on the \n that begins the program.) 
The Apply statement allows us to give whatever instruction is currently being represented by chicken-func its arguments as a single list-object, regardless of its arity (arity meaning the number of arguments its designed to take).
|#

;IN-PROGRESS: Option 1: 
(define (run-funcs stack-apsl chicken-funcs inst-numb)
  (until (= inst-numb (-1 (length chicken-funcs)))
         (define current-chicfunc (list-ref chicken-funcs inst-numb))
         (printf "Current-chicfunc: ~a current inst-numb: ~a current stack-apsl ~a" current-chicfunc inst-numb stack-apsl)
         (cond [(equal? (length (list current-chicfunc )) 9) (apply current-chicfunc inst-numb) ]
               [else (apply current-chicfunc stack-apsl)])))

;IN-PROGRESS: Option 2: 
(define (fold-funcs stack-apsl chicken-funcs start-numb)
  (define counter-adjustment 0)
  (for/fold ([current-stack-apsl stack-apsl])
            ([instruction-counter (in-range start-numb 5000)])
    (begin
      (cond [( >= (+ instruction-counter counter-adjustment) (length chicken-funcs)) (apply axe current-stack-apsl)])
      (define current-chicfunc (list-ref chicken-funcs (+ instruction-counter counter-adjustment)))
      (printf "Current-chicfunc: ~a current instruction-counter: ~a \n current counter adjustment: ~a current stack-apsl ~a \n" current-chicfunc instruction-counter counter-adjustment current-stack-apsl)
      ; The GIGANTIC, nested conditional below is all there to make GOTO instructions work.
      ; The first step checks to see if the current instruction is a GOTO (aka, a 'fly.")
      (cond [(procedure-closure-contents-eq? current-chicfunc fly)
             (printf "\n we identified a 'fly' instruction.\n The counter adjustment currently ~a \n" counter-adjustment)
             ; The next conditional chceks to see if it should execture the GOTO, by seeing if the
             ; 2nd-to-last instruction in the stack would be considered truthy in Javascript.
             (cond [(nor
                     (eqv? 0 (vector-ref (first current-stack-apsl) (- (second current-stack-apsl) 2)))
                     (false? (vector-ref (first current-stack-apsl) (- (second current-stack-apsl) 2)))
                     (empty? (vector-ref (first current-stack-apsl) (- (second current-stack-apsl) 2)))
                     )
                    (printf "\n The 'fly' instruction's condition is truthy. \n")
                    ; Now, we get the offset to the instruction counter and set the instruction-counter accordingly. 
                    (let ([ptr-to-offset (- (second current-stack-apsl) 1)])
                      (let ([stack-now (first current-stack-apsl)])
                        (let ([offset-to-apply (vector-ref stack-now ptr-to-offset)])
                          (set! counter-adjustment (- (+ counter-adjustment offset-to-apply) 1)))))
                    (printf "\n The counter-adjustment has been changed to ~a " counter-adjustment)]
                   [else (printf "\n The 'fly' instruction's condition is falsy. It will not be executed. \n")])])
      (apply current-chicfunc current-stack-apsl)))
  (axe))            
#|
;ORIGINAL: 
(define (fold-funcs stack-apsl chicken-funcs)
  (for/fold ([current-stack-apsl stack-apsl])
            ([chicken-func (in-list chicken-funcs)]
             #:unless (equal? chicken-func "\n"))
    (apply chicken-func current-stack-apsl)))
 ;   (printf "Coming in through chicken-func: ~a.  Coming in as args: ~a" chicken-func current-stack-apsl)))

|#

#|  Chx Program Macro: 
Chx-program now does more than just act as a vessel.  Now it:
 (1) Creates the initial stack and pointers;
 (2) Initiate the process of using fold-funcs to manipulate the values of the stack and pointers.
 (2a)  The bit with giving fold-funcs, etc, to void is apparently "like piping to dev/null in a unixy context." (But right now, we're not doing that, because we want to see the state of the stack and pointers at the end of each program.)
 (2b) We pass fold-funcs a one along with the stack and pointers and the program-instruction list to tell the program which instruction to start with -- thus allowing it to ignore the initial \n.
|#

(define-macro (chx-program PROGRAM-ARG ...)
  #'(begin
      (define first-stack-apsl (list (make-vector 35 null) 0 0))
      (fold-funcs first-stack-apsl (list PROGRAM-ARG ...)  1)))
(provide chx-program)

;INSTRUCTION WRAPPER
(define-macro (chx-instruction INSTRUCTION-ARG ...)
  #'(first (list INSTRUCTION-ARG ...)))
(provide chx-instruction)

;; Helpers for Stack and Pointer Manipulation

#|This is a helper function (named target-stack-value) that uses the baked-in Racket procedure vector-ref to retrieve a value from a stack by pointer value.  Note that the whole stack has to be passed into it.
|#

(define (target-stack-value arr ptr) (vector-ref arr ptr))

#| This is a second helper function.  It takes in the entire stack and then uses the pointer location to set
 a specified value (val) at a specified location in the stack. Here, teh origianl stack is copied to new-arr
 and then new-arr is returned-- so instead of mutating the original stack, it makes a brand new one. 
|#

(define (set-stack-value! arr ptr val)
  (define new-arr (vector-copy arr))
  (vector-set! new-arr ptr val)
  new-arr)

#| This is a helper method for moving the pointer.  You can increment it by one to move it up as the stack
increases in length, or you can give it a negative interval to move it down.  
|#

(define (move-pointer ptr interval)
  (define new-ptr (+ ptr interval))
  new-ptr)

;;;; Helpers for misc macros:

; Turns a value from the stack into a printable string, regardless of what it starts out as. 
(define (stringify target-val)
   (match target-val
      [#f 'false]
      [#t 'true]
      [(? number?) (number->string target-val)]
      [(? empty?) "The absence of even the idea of chickens"]
      [else target-val]))

; Special exception for terminating the program.

(struct exn:end-chickens exn:fail ()) ; subtype of `exn:fail`
(define (end-program)
  (raise (exn:end-chickens
          (format "All chickens are now concluded.")
          (current-continuation-marks))))

; Exception for when trying to do math on strings and numbers at once.

(struct exn:mixed-math exn:fail ()) ; subtype of `exn:fail`
(define (math-mixing operation term1 term2)
  (define stringified1 (stringify term1))
  (define stringified2 (stringify term2))
  (raise (exn:mixed-math
          (format "You're trying to do ~v on ~v and ~v. Chickens can concatenate pairs of strings, but they can't use strings for any other kinds of math." operation stringified1 stringified2)
          (current-continuation-marks))))


;;;; MACROS FOR CHICKEN COMMANDS
;;( Note:  all-caps means IT WORKS.)



;ZERO CHICKENS

(define (axe stack ptr1 ptr2)
  (define last-value (target-stack-value stack (- ptr1 1)))
  (define printable-last (stringify last-value))
  (define final-statement (format "Your final chicken-reading is: ~v.\n" printable-last))
  (printf final-statement)
  (raise (end-program)))        

(define-macro (chx-zero AXE-ARG ...)
;  #'(void AXE-ARG ...))
 #'axe)
(provide chx-zero)


;ONE CHICKEN
(define (hen stack ptr1 ptr2)
  (define updated-stack (set-stack-value! stack ptr1 "chicken"))
  (define newptr1 (move-pointer ptr1 1))
  (define newptr2 (move-pointer ptr2 1))
  (list updated-stack newptr1 newptr2))

(define-macro (chx-one HEN-ARG ...)
  #'hen)
(provide chx-one)

;TWO CHICKENS 
(define (hatch stack ptr1 ptr2)
  (define newptr1 (move-pointer ptr1 -1))
  (define interimptr2 (move-pointer ptr2 -2))
  (define val1 (target-stack-value stack newptr1))
  (define val2 (target-stack-value stack interimptr2))
  (define type_test_list (list val1 val2))
  (define added-val (cond
                      [(andmap string? type_test_list) (string-append val2 val1)]
                      [(andmap number? type_test_list) (+ val2 val1)]
                      [else raise (math-mixing "addition" val1 val2)]))
  (define updated-stack (set-stack-value! stack interimptr2 added-val))
  (define re-updated-stack (set-stack-value! updated-stack newptr1 null))
  (define newptr2 (move-pointer interimptr2 1))
  (list re-updated-stack newptr1 newptr2))

(define-macro (chx-two HATCH-ARG ...)
  #'hatch)
(provide chx-two)

;THREE CHICKENS
(define (fox stack ptr1 ptr2)
  (define newptr1 (move-pointer ptr1 -1))
  (define interimptr2 (move-pointer ptr2 -2))
  (define val1 (target-stack-value stack newptr1))
  (define val2 (target-stack-value stack interimptr2))
  (define type_test_list (list val1 val2))
  (define subtracted-val
    (cond
      [(andmap number? type_test_list) (- val2 val1)]
      [else raise (math-mixing "subtraction" val1 val2)]))
  (define updated-stack (set-stack-value! stack interimptr2 subtracted-val))
  (define re-updated-stack (set-stack-value! updated-stack newptr1 null))
  (define newptr2 (move-pointer interimptr2 1))
  (list re-updated-stack newptr1 newptr2))

(define-macro (chx-three FOX-ARG ...)
;  #'(void FOX-ARG ...))
  #'fox)
(provide chx-three)

;FOUR CHICKENS
(define (rooster stack ptr1 ptr2)
  (define newptr1 (move-pointer ptr1 -1))
  (define interimptr2 (move-pointer ptr2 -2))
  (define val1 (target-stack-value stack newptr1))
  (define val2 (target-stack-value stack interimptr2))
  (define type_test_list (list val1 val2))
  (define multiplied-val
    (cond
      [(andmap number? type_test_list) (* val2 val1)]
      [else raise (math-mixing "multiplication" val1 val2)]))
  (define updated-stack (set-stack-value! stack interimptr2 multiplied-val))
  (define re-updated-stack (set-stack-value! updated-stack newptr1 null))
  (define newptr2 (move-pointer interimptr2 1))
  (list re-updated-stack newptr1 newptr2))

(define-macro (chx-four ROOSTER-ARG ...)
;  #'(void ROOSTER-ARG ...))
  #'rooster)
(provide chx-four)

;FIVE CHICKENS
(define (borges stack ptr1 ptr2)
  (define newptr1 (move-pointer ptr1 -1))
  (define interimptr2 (move-pointer ptr2 -2))
  (define val1 (target-stack-value stack newptr1))
  (define val2 (target-stack-value stack interimptr2))
  (define compared-val (equal? val1 val2))
  (define updated-stack (set-stack-value! stack interimptr2 compared-val))
  (define re-updated-stack (set-stack-value! updated-stack newptr1 null))
  (define newptr2 (move-pointer interimptr2 1))
  (list re-updated-stack newptr1 newptr2))

(define-macro (chx-five BORGES-ARG ...)
;  #'(void BORGES-ARG ...))
  #'borges)
(provide chx-five)

;SIX-AND-ZERO CHICKENS
(define (pick-stack stack ptr1 ptr2)
  (define interimptr1 (move-pointer ptr1 -1))
  (define finderptr (target-stack-value stack interimptr1))
  (define foundval (target-stack-value stack finderptr))
  (define updated-stack (set-stack-value! stack ptr1 foundval))
  (define newptr1 (move-pointer ptr1 1))
  (define newptr2 (move-pointer ptr2 1))
  (list updated-stack newptr1 newptr2))

(define-macro (chx-doublewide-zero PICK-STACK-ARG ...)
;  #'(void PICK-STACK-ARG ...))
  #'pick-stack)
(provide chx-doublewide-zero)

;SIX-AND-ONE-CHICKENS

(define (pick-stdin stack ptr1 ptr2)
  (define inputval (read-line))
  (define updated-stack (set-stack-value! stack ptr1 inputval))
  (define newptr1 (move-pointer ptr1 1))
  (define newptr2 (move-pointer ptr2 1))
  (list updated-stack newptr1 newptr2))

(define-macro (chx-doublewide-one PICK-STDIN-ARG ...)
;  #'(void PICK-STDIN-ARG ...))
  #'pick-stdin)
(provide chx-doublewide-one)


; SEVEN CHICKENS
(define (peck stack ptr1 ptr2)
  (define interimptr1 (move-pointer ptr1 -1))
  (define interimptr2 (move-pointer ptr2 -2))
  (define saverptr (target-stack-value stack interimptr1))
  (define saveval (target-stack-value stack interimptr2))
  (define updated-stack (set-stack-value! stack saverptr saveval))
  (define re-updated-stack (set-stack-value! updated-stack interimptr2 null))
  (define rere-updated-stack (set-stack-value! re-updated-stack interimptr1 null))
  (list updated-stack ptr1 ptr2))

(define-macro (chx-seven PECK-ARG ...)
 ; #'(void PECK-ARG ...))
  #'peck)
(provide chx-seven)

;eight chickens
#|(In terms of its affect on the stack, 'fly'really is just a pass-through.  All the actual GOTO mechanics are executed in the for/fold loop.)
|#

(define (fly stack ptr1 ptr2)
  (void "Nothing happens to the stack in 'fly'")
  (list stack ptr1 ptr2))

(define-macro (chx-eight FLY-ARG ...)
 ; #'(void FLY-ARG ...))
  #'fly)
(provide chx-eight)

;NINE CHICKENS
(define (bbq stack ptr1 ptr2)
  (define interimptr1 (move-pointer ptr1 -1))
  (define val1 (target-stack-value stack interimptr1))
  (define new-char (integer->char val1))
  (define char-string (string new-char))
  (define updated-stack (set-stack-value! stack interimptr1 char-string))
  (list updated-stack ptr1 ptr2))

(define-macro (chx-nine BBQ-ARG ...)
;  #'(void BBQ-ARG ...))
  #'bbq)
(provide chx-nine)

;TEN OR MORE CHICKENS
(define-macro (chx-numerical NUMERICAL-ARG ...)
  #'(lambda (stack ptr1 ptr2)
       (let ([total-chx (- (length (list NUMERICAL-ARG ...)) 11)])
         (let ([updated-stack (set-stack-value! stack ptr1 total-chx)]
               [newptr1 (move-pointer ptr1 1)]
               [newptr2 (move-pointer ptr2 1)])
         (list updated-stack newptr1 newptr2)))))     
(provide chx-numerical)
