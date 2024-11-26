MOV R0,X ; r0 gets address of X (10)
LDR R1,[R0] ; r1 = 0xABCD
MOV R2,Y ; r2 gets address of Y (11)
STR R1,[R2] ; address of Y should have value  r1 =0xABCD
MOV R3, #8 ; r3 = 8
MOV R4, R3 ; r4 = 8
ADD R5, R4, R3 ; r5 = 16
CMP R4, R5 ; N = 1
AND R6, R3, R5 ; r6 = 0 
MVN R7, R6 ; r7 = -1
HALT
X:
.word 0xABCD
Y:
.word 0x0000
