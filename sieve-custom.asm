# This "fast-move" macro replaces the 'move' instruction, since 'move' is an "other" instruction
# we have to calculate it as being 5x more expensive than "add" (even though it's probably not)
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
.eqv ARRAY_START $s3	# This is the start of the array of booleans (moves downward)

.data
start: .asciiz "2 "
space: .asciiz " "

.text
main:
li MAX 200 			# Set our max to 200
li COUNTER 3 			# Initialize counter to 2
li BOOL 0			# Initialize our bool to 'false'
FMOVE(ARRAY_START, $sp)		# Set the starting point of the array to the stack pointer

la $a0 start			# Print "2" to begin with, since we already know that's a prime.
CALLSYS(4)

outerLoop:
bgt COUNTER MAX finish		# If we've reached the end, move to the end of program
sub $sp ARRAY_START COUNTER	# Calculate the current position in the array
lb BOOL, 0($sp)			# Load the current array item
bnez BOOL endOuterLoop		# If it's false, go to next iteration of loop

# PRINT IT! (This could be optimized)
FMOVE($a0, COUNTER)
CALLSYS(1)
la $a0 space
CALLSYS(4)

add INNER_COUNTER COUNTER COUNTER 	# Set the inner counter to counter*2, and begin inner loop
	innerLoop:
	bgt INNER_COUNTER MAX endOuterLoop	# If we've reached the end, return to outer loop
	sub $sp ARRAY_START INNER_COUNTER	# Calculate the current index
	li BOOL 1				# Set the array item to 'true'
	sb BOOL 0($sp)				# Save it into the array
	add INNER_COUNTER INNER_COUNTER COUNTER # Incrememt inner counter by counter
	j innerLoop				# Go back to the top of the loop
endOuterLoop:
addi COUNTER COUNTER 2			# Increment the counter
j outerLoop				# Return to the top of the loop

# Prime calculation has finished
finish:


