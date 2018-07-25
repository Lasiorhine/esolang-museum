#lang brag

crim-program         :  crim-directive*
crim-directive       :  crim-op | crim-loop  | crim-catch-all
crim-loop            :  crim-l-open crim-program crim-l-close
crim-l-open          :  MIN-A{1} PERSON{1} IS{1} GUILTY{1} OF{1}
crim-l-close         :  WITH{1} KNOWLEDGE{1} OR{1} INTENT{1}
crim-op              :  crim-adv-p | crim-rew-p |crim-incr-one | crim-incr-two | crim-decr-one | crim-decr-two | crim-ascii | crim-blank | crim-readout-curr | crim-readout-stack | crim-numb | crim-read-specified | crim-write-to | crim-multip | crim-add | crim-subtr | crim-concat | crim-comp-same | crim-comp-diffr | crim-copy | crim-end-curr | crim-end-last | crim-end-none | crim-end-stack
crim-adv-p           :  FELONY-STOP{1}
crim-rew-p           :  MISDEMEANOR-STOP{1}
crim-incr-two        :  MALICE{1} AFORETHOUGHT{1}
crim-incr-one        :  MALICE{1}
crim-decr-two        :  GROSS{1} NEGLIGENCE{1}
crim-decr-one        :  NEGLIGENCE{1}
crim-ascii           :  BY{1} COLOR{1} OR{1} AID{1} OF{1}
crim-blank           :  UPON{1} CONVICTION{1}
crim-readout-curr    :  CLASS{1} CAP-A{1}
crim-readout-stack   :  CLASS{1} CAP-B{1}
crim-numb            :  OPEN-NUMB{1} INTEGER CLOSE-NUMB{1}
crim-read-specified  :  PURSUANT{1} TO{1} CCR{1} INTEGER
crim-write-to        :  NOTWITHSTANDING{1} SUB-CHAPTER{1} INTEGER
crim-multip          :  DAMAGING{1}
crim-add             :  TAMPERING{1}
crim-subtr           :  IMPEDING{1}
crim-concat          :  BODILY{1} HARM{1}
crim-comp-same       :  PURPOSEFULLY{1}
crim-comp-diffr      :  RECKLESSLY{1}
crim-copy            :  POSSESSING{1}
crim-end-curr        :  INTENT{1} OF{1} THE{1} LEGISLATURE{1}
crim-end-last        :  AT{1} COMMON{1} LAW{1}
crim-end-none        :  MODEL{1} JURY{1} INSTRUCTION{1}
crim-end-stack       :  SSDGM{1}
crim-catch-all       :  OPEN-NUMB{1} | CLOSE-NUMB{1} | CAP-A{1} | AFORETHOUGHT{1} | AID{1} | AT{1} | MIN-A{1} | CAP-B{1} | BODILY{1} | BY{1} | CCR{1} | CLASS{1} | COLOR{1} | COMMON{1} | CONVICTION{1} | GROSS{1} | GUILTY{1} | HARM{1} | INSTRUCTION{1} | INTENT{1} | IS{1} | JURY{1} | KNOWLEDGE{1} | LAW{1} | LEGISLATURE{1} | MODEL{1} | NOTWITHSTANDING{1} | OF{1} | OR{1} | PERSON{1} | PURSUANT{1} | SUB-CHAPTER{1} | THE{1} | TO{1} | UPON{1} | WITH{1} | INTEGER{1}
