# Copyright (C) 2022 Analog Devices, Inc.
#
# SPDX short identifier: ADIBSD

import time
import adi
import matplotlib.pyplot as plt
import numpy as np
from scipy import signal

# Create radio
sdr = adi.ad9361(uri="ip:192.168.2.1")

sample_rate     = 2e6   # 10MHz
center_freq     = 1e9   # 1GHz
num_samps       = 1024  # sample numbers
sdr.sample_rate = sample_rate

# Configure RX
sdr.rx_rf_bandwidth = int(sample_rate)
sdr.rx_lo = int(center_freq)
sdr.rx_buffer_size = num_samps
sdr.rx_enabled_channels = [0,1] # enable both rx channels

# Configure TX
sdr.tx_lo = int(center_freq)
sdr.tx_cyclic_buffer = True
sdr.tx_hardwaregain_chan0 = -10
sdr.gain_control_mode_chan0 = "slow_attack"

# Configuration data channels
sdr.tx_enabled_channels = [0]

# Read properties
print("RX LO %s" % (sdr.rx_lo))

# Create a sinewave waveform
fs = int(sdr.sample_rate)
ts = 1 / float(fs)
t = np.arange(0, num_samps) / fs
i = np.cos(2 * np.pi * t * 2e5) * 2 ** 14
q = np.sin(2 * np.pi * t * 2e5) * 2 ** 14
iq = i + 1j * q

plt.figure(num=10001)
plt.plot(i)
plt.show(block=False)

# Send data
sdr.tx(iq)
plt.figure(num=10000)

# Collect data
for r in range(20):
    [x1, x2] = sdr.rx()
    plt.clf()
    plt.plot(np.real(x1))
    plt.xlabel("Amplify")
    plt.ylabel("Sample Number")
    plt.draw()
    plt.pause(0.05)
    time.sleep(0.1)

plt.show()