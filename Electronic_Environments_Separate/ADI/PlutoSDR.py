# Copyright (C) 2022 Analog Devices, Inc.
#
# SPDX short identifier: ADIBSD

import time
import adi
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import axes3d
import numpy as np
from scipy import signal

# Create radio
sdr = adi.ad9361(uri="ip:fe80::9880:3eff:fed3:e404%22")

sample_rate     = 30.72e6     # 30MHz
rf_bandwidth    = sample_rate # 30MHz
center_freq     = 4e9         # 1GHz
num_samps       = 8192        # sample numbers
pulsenum        = 64
sdr.sample_rate = sample_rate

# Configure RX
sdr.rx_rf_bandwidth = int(rf_bandwidth)
sdr.rx_lo = int(center_freq)
sdr.rx_buffer_size = int(8192 + 8192 * pulsenum + 8192)
# sdr.rx_annotated = True
sdr.rx_enabled_channels = [0] # enable both rx channels

# Configure TX
sdr.tx_lo = int(center_freq)
sdr.tx_cyclic_buffer = True
sdr.tx_buffer_size = num_samps
sdr.tx_hardwaregain_chan0 = -10
sdr.gain_control_mode_chan0 = "fast_attack"

# Configuration data channels
sdr.tx_enabled_channels = [0]

# Read properties
print("RX LO %s" % (sdr.rx_lo))

# Create a sinewave waveform
fs = int(sdr.sample_rate)
ts = 1 / float(fs)
t = np.arange(0, num_samps * ts, ts)

t_ = np.arange(0, num_samps / 4 * ts, ts) # max time: 6.8233e-5
K  = 10e6 / max(t_)
LFM = np.exp(1j * K * np.pi * t_ ** 2)
iq = np.zeros(shape=len(t), dtype=np.complex64)
iq[0:len(LFM)] = LFM * 2 ** 14
match_filter = np.conj(iq) * 2 ** 14

# i = np.cos(2 * np.pi * t * 2e6) * 2 ** 14
# q = np.sin(2 * np.pi * t * 2e6) * 2 ** 14
# iq = i + 1j * q

# plt.figure(num=1001)
# plt.plot(np.real(iq))
# plt.show(block=False)

# Send data
sdr.tx(iq)
x1 = np.array([])

# Collect data
# plt.figure(num=10000)
for r in range(1):
    if len(sdr.rx_enabled_channels) == 2:
        [x1, x2] = sdr.rx()
    else:
        x1 = sdr.rx()
    # plt.clf()
    # plt.plot(np.abs(x1))
    # plt.xlabel("Amplify")
    # plt.ylabel("Sample Number")
    # plt.draw()
    # plt.pause(0.05)
# plt.show(block=False)

# 检测峰值
max_peaks = max(abs(x1))
detection_threshold = max_peaks / 3
peaks_index = np.where(np.abs(x1) > detection_threshold, 1, 0)
delta_index = peaks_index[1:len(peaks_index)] - peaks_index[0:len(peaks_index)-1]

# plt.figure(num=1003)
# plt.plot(delta_index)
# plt.show(block=False)

peaks_1  = []
peaks_0  = []
delta_1  = []
delta_n1 = []
N_LFMs   = len(t_)
N_zeros  = num_samps - len(t_)

for ii in range(len(peaks_index)):
    if peaks_index[ii] == 1:
        peaks_1.append(ii)
    else:
        peaks_0.append(ii)

for ii in range(len(delta_index)):
    if delta_index[ii] == 1:
        delta_1.append(ii)
    else:
        delta_n1.append(ii)

pulse_start = -1
# 先检查第一个脉冲是不是1
if peaks_1[0] == 1:
    # find first 0
    first_index = delta_n1[0]
    pulse_start = first_index + N_zeros
else:
    first_index = delta_1[0]
    pulse_start = first_index + N_zeros + N_LFMs

echo = x1[pulse_start:pulse_start+num_samps * pulsenum]

# plt.figure(num=1003)
# plt.plot(np.real(echo))
# plt.show(block=False)

echos = np.reshape(echo, [pulsenum, num_samps])
pulse_compression = np.array([])
for ii in range(pulsenum):
    result = np.fft.ifft(np.fft.fft(echos[ii][:], num_samps) *
                         np.fft.fft(match_filter, num_samps))
    if len(pulse_compression) == 0:
        pulse_compression = result
    else:
        pulse_compression = np.vstack([pulse_compression, result])

# ax = plt.figure(num=1004).add_subplot(projection='3d')
# X, Y = np.mgrid[0:pulsenum, 0:num_samps]
# ax.plot_surface(X, Y, abs(pulse_compression), cmap='autumn', cstride=2, rstride=2)
# plt.show(block=False)

# MTI
mti = pulse_compression[1:pulsenum][:] -  pulse_compression[0:pulsenum-1][:]
# MTD
mtd = np.fft.fftshift(np.fft.fftshift(np.fft.fft(mti, 512, 0)), axes=1)

# ax = plt.figure(num=1005).add_subplot(projection='3d')
# X, Y = np.mgrid[0:512, 0:num_samps]
# ax.plot_surface(X, Y, abs(mtd), cmap='autumn', cstride=2, rstride=2)
plt.figure(num=1005)
plt.imshow(abs(mtd), aspect='auto')
plt.tight_layout()
plt.show(block=True)

121.723 -112.312