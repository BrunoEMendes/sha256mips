#@Author Bruno Mendes 62181 Ualg
.data

values:
  0x87564C0C #0   A
  0xF1369725 #4   B
  0x82E6D493 #8   C
  0x63A6B509 #12  D
  0xDD9EFF54 #16  E
  0xE07C2655 #20  F
  0xA41F32E7 #24  G
  0xC7D25631 #28  H
  0x6534EA14 #32  W
  0xC67178F2 #36  K

letter:
	.asciiz "A= "
	.asciiz "B= "
	.asciiz "C= "
	.asciiz "D= "
	.asciiz "E= "
	.asciiz "F= "
	.asciiz "G= "
	.asciiz "H= "


space: .asciiz " \n"
start: .asciiz "START:\n"
final: .asciiz "FINAL:\n"

.text

#main 
#program details
#main uses all functions
#all functions need to use get_RA
#print and loop work independently
#pre_loop and loop count as "1 function" because pre_loop is only initializing the vars for loop
#same works for print and print_loop
#loop requires the use of the functions t1 and t2
main:
	#prints Start
	li $v0,4
	la $a0,start
	syscall
	#print initial array
	jal print
	la $a0,space
	syscall
	#sha 256 loop
	jal pre_loop
	#prints final
	la $a0,final
	syscall
	#prints end array
	jal print
	#ends program
	li $v0,10
	syscall
###########################################################################################################
#functions
	#doesnt receive any argument
	#saves Address in the stack
pre_loop:
	li $t7,64 #max
	li $t8,0
	sub $sp,$sp,-4
	sw $ra,($sp)
	j loop

	#N1 = h + Sum(e) + ch(e,f,g) + k + w
	#N2 = Sum(a) + MAJ(a,b,c)
	#h=g
	#g=f
	#f=e
	#e = d + N1
	#d = c
	#c=b
	#b=a
	#a = N1 +N2		
loop:
	beq $t8,$t7,get_Ra
	la $a0,values
	
	#get N1
	jal t1

	#get N2
	jal t2
	#gets N2 from stack
	lw $t5,($sp)
	subi $sp,$sp,4
	#gets N1 from stack
	lw $t6,($sp)
	subi $sp,$sp,4
	
	#array starts on position 28 which is H
	addi $a0,$a0,28
	#h 
	lw $t1,-4($a0)
	sw $t1,($a0)
	subi $a0,$a0,4
	#g
	lw $t1,-4($a0)
	sw $t1,($a0)
	subi $a0,$a0,4
	#f
	lw $t1,-4($a0)
	sw $t1,($a0)
	subi $a0,$a0,4
	#e
	lw $t1,-4($a0)
	addu $t1,$t1,$t6
	sw $t1,($a0)
	subi $a0,$a0,4
	#d
	lw $t1,-4($a0)
	sw $t1,($a0)
	subi $a0,$a0,4
	#c
	lw $t1,-4($a0)
	sw $t1,($a0)
	subi $a0,$a0,4
	#b
	lw $t1,-4($a0)
	sw $t1,($a0)
	subi $a0,$a0,4
	#a
	addu $t5,$t5,$t6
	sw $t5,0($a0)		
	#increments loop	
	add $t8,$t8,1
	j loop
	
	#E(e) + h + w + k + ch(e,f,g)
	#E(e) = ror14 xor ror18 xor 39 
	##ch(e,f,g)= (e ^ f) xor (-e ^ g) 
	#receives array in $a0
	#returns the result in the stack	
t1:

	lw $t0,16($a0)
	ror $t1,$t0,6
	ror $t2,$t0,11
	ror $t3,$t0,25
	xor $t6,$t1,$t2
	xor $t6,$t6,$t3
	
	#ch(e,f,g)= (e ^ f) xor (-e ^ g ) 
	# t0 -E t1-F t2-G
	lw $t1,20($a0)
	lw $t2,24($a0)
	#e^f
	and $t4,$t0,$t1
	
	#-e
	not $t0,$t0
	and $t5,$t0,$t2
	
	xor $t5,$t4,$t5
	
	addu $t6,$t6,$t5
	
	lw $t0,28($a0) #h
	
	addu $t6,$t6,$t0
	
	lw $t0,32($a0) #w
	
	addu $t6,$t6,$t0
	
	lw $t0,36($a0) #k
	
	addu $t6,$t6,$t0	
	#saves value in the stack
	subi $sp,$sp,-4
	sw $t6,($sp)	
	
	jr $ra	

	#E0(a) + MAJ(a,b,c)
	#E0(a) = ror 2 xor ror 13 xor ror 22
	#MAJ(a,b,c) = (a^b) xor (a^c) xor (b^c) 			
	#receives array in $a0
	#returns the result in the stack
t2:
	#E0(a)

	lw $t0,0($a0) #a
	ror $t1,$t0,2
	ror $t2,$t0,13
	ror $t3,$t0,22
	xor $t6,$t1,$t2
	xor $t6,$t6,$t3
	
	lw $t1,4($a0) #b
	lw $t2,8($a0) #c
	
	#a^b
	and $t3,$t0,$t1
	
	#a^c
	and $t4,$t0,$t2
	
	#b^c
	and $t5,$t1,$t2
	
	xor $t3,$t3,$t4
	xor $t5,$t3,$t5
	
	addu $t6,$t6,$t5
	#saves value in the stack
	subi $sp,$sp,-4
	sw $t6,($sp)
	
	jr $ra

 	#will save the Address to the stack
 	#will start the Vars for the print_loop
print:
	subi $sp,$sp,-4
	sw $ra,($sp)
	li $t4,0
	li $t5,4
	li $t6,8
	j print_loop
	
	#after the loop is over it will jump into the get_Ra
print_loop: 
	beq $t4,$t6,get_Ra
	mult $t5,$t4
	mflo $t3
	la $a0,letter
	la $t0,values
	add $a0,$a0,$t3
	add $t0,$t0,$t3
	
	li $v0,4 
	syscall
	lw $a0,($t0)
	li $v0,34
	syscall
	la $a0, space
	li $v0,4
	syscall
	addi $t4,$t4,1
	j print_loop	
	
	#this will pop the last value added to the stack
	#this value will be an address in this case
	#this function will also JUMP to that address
get_Ra:
	lw $ra,($sp)
	jr $ra

	
	
	
	
																																																																																																							
