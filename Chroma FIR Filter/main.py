import numpy as np
from scipy import signal
import matplotlib.pyplot as pyplot

### Sinc filter design
# Define the parameters
fc = 1000
b = 100
N = int(np.ceil((4 / b)))
#if not N % 2: N += 1  # Make sure that N is odd.
n = np.arange(N)
# Compute sinc filter.
h = np.sinc(2 * fc * (n - (N - 1) / 2.))
# Compute Blackman window.
w = np.blackman(N)
# Multiply sinc filter with window.
h = h * w
# Normalize to get unity gain.
h_unity = h / np.sum(h)
print(h_unity)

# FIR filter coeficients used on the Interpolation filter
filter_scenario = 1
if filter_scenario == 1:
    FIR_Coefs = np.array([1300, -420, 236, -152, 104, -70, 48, -32, 20, -12, 6, -4])
    FIR_Norm_Coef = 2048

    FIR_Coefs = h_unity
    FIR_Norm_Coef = 1
else:
    FIR_Coefs = np.array([1])
    FIR_Norm_Coef = 2

# Number of (downsampled) samples
Test_Sample_size = 200

# Test vector
sample_data_scenario = 2
if sample_data_scenario == 1:
    # 1 - Random sequence
    rng = np.random.default_rng()
    rand_seq = np.absolute(rng.standard_normal(Test_Sample_size))
    Test_Sample_in = np.floor(np.divide(rand_seq, np.amax(rand_seq))*255)
elif sample_data_scenario == 2:
    # 2 - sine sequence
    x = np.linspace(-np.pi*10, np.pi*10, Test_Sample_size)
    sin_seq = np.sin(x)
    Test_Sample_in = np.floor(np.divide((sin_seq - np.amin(sin_seq)), np.amax(sin_seq))*255)
elif sample_data_scenario == 3:
    # 3 - step data
    t = np.linspace(0, 1, Test_Sample_size, endpoint=False)
    square_seq = signal.square(2 * np.pi * 5 * t)
    Test_Sample_in = np.floor(np.divide((square_seq - np.amin(square_seq)), np.amax(square_seq)) * 255)
else:
    # 4 - sawtooth data
    t = np.linspace(0, 1, Test_Sample_size)
    sawtooth_seq = signal.sawtooth(2 * np.pi * 5 * t)
    Test_Sample_in = np.floor(np.divide((sawtooth_seq - np.amin(sawtooth_seq)), np.amax(sawtooth_seq)) * 255)

# Number of head and tail buffer samples
Paddind_Head_size = (FIR_Coefs.size*2)-2
Padding_Tail_Size = FIR_Coefs.size*2-1
Padding_Head = np.ones(Paddind_Head_size)*0
Padding_Tail = np.ones(Padding_Tail_Size)*0

# Build output vector
Test_Sample_out = np.zeros(Test_Sample_size*2 + Paddind_Head_size + Padding_Tail_Size)
Test_Sample_out[:Paddind_Head_size] = Padding_Head
Test_Sample_out[Paddind_Head_size + Test_Sample_size*2:] = Padding_Tail

# Adjust Test vector for plotting against interpolated result
Test_Sample_in_spread = np.zeros(Test_Sample_size * 2 + Paddind_Head_size + Padding_Tail_Size)
Test_Sample_in_spread[Paddind_Head_size:Paddind_Head_size + Test_Sample_size * 2:2] = Test_Sample_in

# Process filter
for i in range(Paddind_Head_size+1, Paddind_Head_size + Test_Sample_size*2 + 1, 2):
    samples_after = Test_Sample_in_spread[(i+1):(i+Padding_Tail_Size+1):2]
    samples_before = Test_Sample_in_spread[(i-Paddind_Head_size-1):i:2]

    Test_Sample_out[i-1] = Test_Sample_in_spread[i-1]
    Test_Sample_out[i] = np.sum(np.multiply(np.add(samples_after, np.flip(samples_before)), FIR_Coefs))/FIR_Norm_Coef

# Plots
pyplot.figure(1)
pyplot.plot(Test_Sample_in_spread, '.')
pyplot.plot(Test_Sample_out)
pyplot.show()
