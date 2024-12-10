import adi
import numpy as np

# Create radio
dev = adi.adrv9025('ip:zcu102.local')
dev.lo1 = int(6e9)
dev.lo2 = int(6e9)
# Enable all channels
for c in range(4):
    for e in [True, False]:
        chan = dev._ctrl.find_channel(f'voltage{c}', e)
        chan.attrs['en'].value = '1'
dev.dds_single_tone(100000, 1.2)

fs = int(200e6)
num_samps = int(819200)
ts = 1 / float(fs)
t = np.arange(0, num_samps * ts, ts)
i = np.cos(2 * np.pi * t * 10e6) * 2 ** 14
q = np.sin(2 * np.pi * t * 10e6) * 2 ** 14
iq = i + 1j * q

dev.tx_buffer_size = num_samps
dev.rx_buffer_size = num_samps

# dev.tx([iq, iq, iq, iq])
data = dev.rx()
print(data)