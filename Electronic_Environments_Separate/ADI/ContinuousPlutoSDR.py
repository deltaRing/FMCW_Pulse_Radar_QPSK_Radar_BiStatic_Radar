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
sdr.rx_buffer_size = int(num_samps * (pulsenum + 2))
# sdr.rx_annotated = True
sdr.rx_enabled_channels = [0] # enable both rx channels

# Configure TX
sdr.tx_lo = int(center_freq)
sdr.tx_cyclic_buffer = True
sdr.tx_buffer_size = num_samps
sdr.tx_hardwaregain_chan0 = -5
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

# plt.figure(num=1001)
# plt.plot(np.real(iq))
# plt.show(block=False)

# Send data
sdr.tx(iq)
x1 = np.array([])

# Collect data
while True:
    if len(sdr.rx_enabled_channels) == 2:
        [x1, x2] = sdr.rx()
    else:
        x1 = sdr.rx()

    plt.figure(num=1000)
    plt.clf()
    plt.plot(np.abs(x1))
    plt.xlabel("Amplify")
    plt.ylabel("Sample Number")
    plt.draw()
    plt.show(block=False)

    # 检测峰值
    max_peaks = max(abs(x1))
    detection_threshold = max_peaks / 3
    peaks_index = np.where(np.abs(x1) > detection_threshold, 1, 0)
    delta_index = peaks_index[1:len(peaks_index)] - peaks_index[0:len(peaks_index)-1]

    # plt.figure(num=1003)
    # plt.plot(delta_index)
    # plt.show(block=False)
    delta_1  = []
    delta_n1 = []

    for ii in range(len(delta_index)):
        if delta_index[ii] == 1:
            delta_1.append(ii)
        else:
            delta_n1.append(ii)

    first_index = delta_1[0]
    pulse_start = first_index + num_samps

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

    plt.figure(num=1004)
    plt.clf()
    plt.imshow(10 * np.log10(abs(pulse_compression)), aspect='auto')
    plt.draw()
    plt.pause(0.01)
    plt.show(block=False)

    # MTI
    mti = pulse_compression[1:pulsenum][:] -  pulse_compression[0:pulsenum-1][:]
    # MTD
    mtd = np.fft.fftshift(np.fft.fftshift(np.fft.fft(pulse_compression, 512, 0)), axes=1)

    plt.figure(num=1005)
    plt.clf()
    plt.imshow(10 * np.log10(abs(mtd)), aspect='auto')
    plt.draw()
    plt.pause(0.01)
    plt.show(block=False)