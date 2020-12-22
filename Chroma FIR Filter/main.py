import numpy as np
import matplotlib.pyplot as pyplot

# FIR filter coeficients used on the Interpolation filter
FIR_Coefs = np.array([1300, -420, 236, -152, 104, -70, 48, -32, 20, -12, 6, -4])
FIR_Norm_Coef = 2048

# Number of non-zero samples
Test_Sample_size = 100

# Test vector
Test_Sample_in = np.zeros(Test_Sample_size*2 + FIR_Coefs.size*2)
