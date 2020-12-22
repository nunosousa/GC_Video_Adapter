import numpy as np
import matplotlib.pyplot as pyplot

# FIR filter coeficients used on the Interpolation filter
FIR_Coefs = np.array([1300, -420, 236, -152, 104, -70, 48, -32, 20, -12, 6, -4])
FIR_Norm_Coef = 2048

# Number of (downsampled) samples
Test_Sample_size = 10

# Test vector
rng = np.random.default_rng()
rand_seq = np.absolute(rng.standard_normal(Test_Sample_size))
Test_Sample_in = np.floor(np.divide(rand_seq, np.amax(rand_seq))*255)

# Number of head and tail buffer samples
Paddind_Head_size = (FIR_Coefs.size*2)-1
Padding_Tail_Size = FIR_Coefs.size*2
Padding_Head = np.ones(Paddind_Head_size)
Padding_Tail = np.ones(Padding_Tail_Size)

# Build output vector
Test_Sample_out = np.zeros(Test_Sample_size*2 + Paddind_Head_size + Padding_Tail_Size)
Test_Sample_out[:Paddind_Head_size] = Padding_Head
Test_Sample_out[Paddind_Head_size + Test_Sample_size*2:] = Padding_Tail

# Adjust Test vector for plotting against interpolated result
Test_Sample_in_spread = np.zeros(Test_Sample_size * 2 + Paddind_Head_size + Padding_Tail_Size)
print(Test_Sample_in_spread[Paddind_Head_size:2:Paddind_Head_size + Test_Sample_size * 2])
Test_Sample_in_spread[Paddind_Head_size:Paddind_Head_size + Test_Sample_size * 2:2] = Test_Sample_in

# Process filter
print(Test_Sample_in_spread)
for i in range(Paddind_Head_size+1, Paddind_Head_size + Test_Sample_size*2 + 1, 2):
    samples_after = Test_Sample_in_spread[(i+1):(i+(FIR_Coefs.size*2)):2]
    samples_before = Test_Sample_in_spread[(i-(FIR_Coefs.size*2)+1):(i-1):2]
    print(samples_before)
    Test_Sample_out[i] = 0.1

# Plots
pyplot.figure(1)
pyplot.plot(Test_Sample_in_spread, '.')
pyplot.plot(Test_Sample_out, '.')
pyplot.show()
