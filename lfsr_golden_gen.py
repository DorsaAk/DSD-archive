"""
    The pyhton script lfsr_golden_gen.py is in charge of generating the 
    golden sequence file for the testbench

"""

def lfsr_fibonacci(state, taps, width):
    """Calculate next LFSR state (Fibonacci configuration)"""
    # Calculate feedback bit by XORing tapped bits
    feedback = 0
    for i in range(width):
        if taps[i]:
            feedback ^= (state >> i) & 1
    
    # Shift right and insert feedback at MSB
    next_state = (state >> 1) | (feedback << (width - 1))
    return next_state & ((1 << width) - 1)  # Mask to width

def generate_golden_sequence(init_state, taps, width, steps):
    """Generate golden sequence for LFSR"""
    sequence = []
    state = init_state
    for i in range(steps):
        sequence.append(state)
        state = lfsr_fibonacci(state, taps, width)
    return sequence



# 8-bit LFSR parameters
WIDTH = 8
TAPS = [0, 0, 0, 1, 1, 1, 0, 1] # x^8 + x^6 + x^5 + x^4 + 1
INIT_STATE = 0xAA  # 8'b10101010
STEPS = 21

# Generate sequence
golden_seq = generate_golden_sequence(INIT_STATE, TAPS, WIDTH, STEPS)

# Write to file in Verilog format
with open("golden_sequence.txt", "w") as f:
    for i, val in enumerate(golden_seq):
        f.write(f"// Step {i}: 8'b{val:08b} (0x{val:02X})\n")
    f.write("\n// Verilog array format:\n")
    f.write("// reg [7:0] golden_seq [0:19] = '{\n")
    for i, val in enumerate(golden_seq):
        if i < len(golden_seq) - 1:
            f.write(f"//     8'b{val:08b},\n")
        else:
            f.write(f"//     8'b{val:08b}\n")
    f.write("// };\n")

print("Golden sequence generated in 'golden_sequence.txt'")
print("\nGenerated sequence:")
for i, val in enumerate(golden_seq):
    print(f"Step {i:2d}: 8'b{val:08b} (0x{val:02X})")