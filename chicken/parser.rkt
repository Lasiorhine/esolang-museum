#lang brag

chx-program         :  RETURN{1} chx-instruction*
chx-instruction     :  chx-numerical | chx-doublewide-one | chx-doublewide-zero | chx-nine |
                       chx-eight | chx-seven | chx-five | chx-four | chx-three | chx-two | chx-one | chx-zero
chx-numerical       :  CHICKEN{10,} RETURN{1}
chx-doublewide-one  :  CHICKEN{6} RETURN{1} CHICKEN{1} RETURN{1}
chx-doublewide-zero :  CHICKEN{6} RETURN{1} CHICKEN{0} RETURN{1}
chx-nine            :  CHICKEN{9} RETURN{1}
chx-eight           :  CHICKEN{8} RETURN{1}
chx-seven           :  CHICKEN{7} RETURN{1}
chx-five            :  CHICKEN{5} RETURN{1}
chx-four            :  CHICKEN{4} RETURN{1}
chx-three           :  CHICKEN{3} RETURN{1}
chx-two             :  CHICKEN{2} RETURN{1}
chx-one             :  CHICKEN{1} RETURN{1}
chx-zero            :  CHICKEN{0} RETURN{1}