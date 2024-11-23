function output = CorFFT(surv, ref)
    FFT_s = fftshift(fft(surv));
    FFT_ref = fftshift(fft(ref));
    output = ifftshift(ifft((FFT_s).*conj(FFT_ref.')));
end