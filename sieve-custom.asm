# This "fast-move" macro replaces the 'move' instruction, since 'move' is classified as an "other" instruction
# we have to calculate it as being 5x more expensive than 'add' (even though it's probably not)
.macro FMOVE(%lhs, %rhs)
addi %lhs %rhs 0
.end_macro

.macro CALLSYS(%id)
li $v0 %id
syscall
.end_macro

# Registers that never change purpose
.eqv MAX $s6
.eqv COUNTER $s0 	# This is the counter for the outer loop (i)
.eqv INNER_COUNTER $s1 	# This is the counter for the inner loop
.eqv BOOL $s2		# This is the current boolean variable from the array
.eqv ARRAY_INDEX $s3	# This is responsible for indexing the boolean array, since indices don't match up with COUNTER

.data
start: .asciiz "2 "
space: .asciiz " "

.text
main:
li MAX 200 			# Set our max to 200
li COUNTER 3 			# Initialize counter to 2
li BOOL 0			# Initialize our bool to 'false'
FMOVE(ARRAY_INDEX, $sp)		# Set the starting point of the array to the stack pointer

la $a0 start			# Print "2" to begin with, since we already know that's a prime.
CALLSYS(4)

outerLoop:
div $t0 COUNTER MAX		# If we've reached the end, move to the end of program
bnez $t0 finish			
lb BOOL, 0(ARRAY_INDEX)		# Load the current array item
bnez BOOL endOuterLoop		# If it's false, go to next iteration of loop

# PRINT IT! (This could be optimized)
FMOVE($a0, COUNTER)
CALLSYS(1)
la $a0 space
CALLSYS(4)

add INNER_COUNTER COUNTER COUNTER 	# Set the inner counter to counter*2, and begin inner loop
sub $t1 ARRAY_INDEX COUNTER		# We'll be using t1 to index the array in the inner loop
	innerLoop:
	div $t0 INNER_COUNTER MAX		# If we've reached the end, return to outer loop
	bnez $t0 endOuterLoop			
	li BOOL 1				# Set the array item to 'true'
	sb BOOL 0($t1)
	add INNER_COUNTER INNER_COUNTER COUNTER # Incrememt inner counter by counter
	sub $t1 $t1 COUNTER			# Increment array index
	j innerLoop				# Go back to the top of the loop
endOuterLoop:
addi COUNTER COUNTER 2			# Increment the counter
addi ARRAY_INDEX ARRAY_INDEX -1		# Move to the next item in the array
j outerLoop				# Return to the top of the loop

# Prime calculation has finished
finish:

