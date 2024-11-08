function output = CorFFT2D(Ssurv, Sref)

fftEcho1 = fft(Ssurv);
fftEcho2 = fft(Sref);

PulseNum = size(Ssurv, 2);
output   = zeros(size(Ssurv));

for pp = 1:PulseNum
    output(:, pp) = ifft(fftEcho1(:, pp) .* fftEcho2');
end

% figure(1000)
% mesh(db(output))
% figure(1001)
% mesh(db(fftshift(fft(output, 512, 2))))

end

