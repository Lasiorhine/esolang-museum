# ESOLANG-MUSEUM


## Crime and Punishment 

##### (Formerly "Homicidal Breakfast with Drugs")

### What is this, and why is it happening?

The short answer:   Charles said I needed to make my own language, instead of just compiling and tweaking those of others.

The longer answer:  This language is inspired, in equal measure, by the minimalist stack-manipulation langugages Chicken and Brainf-ck, and by the .Gertrude and Chef, which use language that does not, at first blush, look like computer code to generate computer programs. 

Crime and Punishment is, primarily, an experminent with tokenizing and parsing.  The goal is to create a more-or-less Turing complete language that (1) Can be hidden amid legalistic language; and (2) Can be sucessfully and predictably processed despite the presence of a great deal of irrelevant verbiage.  The fun of this (and I do hope it turns out to be fun) is that you should be able to write yourself a fairly plausible-looking criminal statute, and then run it as code.  (Note -- your statute, most likely, will not look especially plausible to an actual, practicing lawyer.  Yours will be a sit-com quality criminal statute.) 

#### Minimum Basic Requirements for Turing Completeness:

(Based on μ-recursive functions)
(Understanding via Stack Exchange: https://cs.stackexchange.com/questions/991/are-there-minimum-criteria-for-a-programming-language-being-turing-complete)

1.  Constants (aka numbers -- in this case, natural numbers)
2.  Incrementation
3.  Variable access
4.  Program statement concatenation (here, a freebie) 
5.  Primitive recursion
6.  Selective exectution (i.e., conditionals/while loops)

(Based on the Bohm Jacopini Structured Program Theorem)

A. Sequential execution (overlaps with 4, above)
B. Selection (overlaps with 6, above) 
C. Retpetition (overlaps with 5, above). 
`
### Commands:

#### Pointer manipulation

(Note the presence of the periods.  They are necessary parts of the syntax.)

`felony.`  -- Advance the pointer by 1.

`misdemeanor.` -- Pull back the pointer by 1. 

#### Action on current stack position

`malice` -- Increment by 1

`malice aforethought` -- Increment by 2

`negligence` -- Decrement by 1

`gross negligence` -- Decrement by 2

`by color or aid of` -- Convert int to equivalent ASCII value (outputs a single-character string)

`upon conviction` -- Blank the current stack position (assigns the value _null_)

`Class A` -- Read the value under the pointer

`Class B` -- Read out the entire stack. 

#### Numbers
 
 `($INT.00)` -- Whatever is in the INT position will be pushed to the stack

####  Actions involving multiple stack positions - Reading and writing

`pursuant to CCR ` (followed by an integer) -- Read from the cell specified by the integer, and push that value to the stack.  (Leaves the original value in place.) 

`notwithistanding sub-chapter` (followed by an integer) -- Write the value at the top of the stack to the cell specified by the integer. (Leaves the original value in place) 

#### Actions involving multiple stack positions - Arithmetic

(In these actions, the cell under the pointer is the first term, and the cell immediately below it is the second term. These two terms will be left in place, and the result-value will be pushed to the stack. )

`damagaging` - multiplication
`tampering` - addition
`impeding` - subtraction

#### Actions involving multiple stack positions - String manipulation

(Here, the cell at the top of the stack is the first term, and the one immediately below it is the second.  These two values will be popped from the stack (thus, permanently removed) and the resulting, concatenated string will be pushed to the stack.)

`bodily harm` - concatenate strings

#### Actions involving multiple stack positions - comparison

`knowingly` - compares the top two values in the stack, and pushes the value "true" to the stack if they are equivalent. (leaves the original values in place)

`recklessly` - compares the top two values in the stack, and pushes the value "false" to the stack if they are equivalent. (leaves the original values in place)

#### Actions involving multiple stack positions - Copying

`grievous` - copy the cell beneath the pointer and push it to the stack 

#### Looping

Loops are made a number of times equivalent to the integer currently beneath the pointer.  If the value beneath the number is note an integer (i.e, if it is a string, or a boolean, or null) the loop will not run. 

`a person is guilty of` (looped material) `with knowledge or intent` 

(Guard expression to come). 

#### Program termination

`intent of the legislature` -- Read the value of last cell written-to, then terminate the program. 

`at common law` -- Read the last value of the last cell in the stack, then terminate the program. 

`model jury instruction` -- Terminate the program without reading anything out.

`SSDGM` -- Read out the entire stack, then terminate the program

### Notes:

* Each crime-and-punishment function will take in the stack and two pointers.  The first pointer will be to a given position within the stack, and the second will track the top of the stack. 







