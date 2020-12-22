import numpy as np
import matplotlib.pyplot as pyplot

# FIR filter coeficients used on the Interpolation filter
FIR_Coefs = np.array([1300, -420, 236, -152, 104, -70, 48, -32, 20, -12, 6, -4])
FIR_Norm_Coef = 2048

# Number of (downsampled) samples
Test_Sample_size = 100

# Test vector
rng = np.random.default_rng()
rand_seq = np.absolute(rng.standard_normal(Test_Sample_size))
Test_Sample_in = np.divide(rand_seq, np.amax(rand_seq))*255

# Number of head and tail buffer samples
Paddind_Head_size = (FIR_Coefs.size*2)-1
Padding_Tail_Size = FIR_Coefs.size*2



#Test_Sample_in = np.zeros(Test_Sample_size*2 + Paddind_Head_size + Padding_Tail_Size)

#Test_Sample_in[0:(FIR_Coefs.size*2)-1] =
print(Test_Sample_in)

pyplot.figure(1)
pyplot.plot(Test_Sample_in)
pyplot.show()