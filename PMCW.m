clear all 
code1 = (randi([0 1], [1, 500]) - 0.5) * 2;
% each code continue 50e-6 / 200

t = 15e-6;
fc = 1e4;
fs = 245.76e6;

phase1 = code1 * pi;

t_mod1 = 0:1/fs:t-1/fs;

for ii = 1:length(t_mod1)-1
    index = fix(ii / ((t / 500) * fs)) + 1;
    s1(ii) = exp(1j * 2 * pi * fc * t_mod1(ii) + 1j * code1(index));
end

qq1 = [zeros(1, 120), s1, zeros(1, 12800)];
qq2 = [zeros(1, 2400), s1, zeros(1, 12800-2400+120)];
qq3 = [zeros(1, 1200), s1, zeros(1, 12800-1200+120)];
qq4 = [zeros(1, 1654), s1, zeros(1, 12800-1654+120)];
qq5 = [zeros(1, 1300), s1, zeros(1, 12800-1300+120)];
qq1 = awgn(qq1, 10);
qq2 = awgn(qq2, 10);
qq3 = awgn(qq3, 10);
qq4 = awgn(qq4, 10);
qq5 = awgn(qq5, 10);
qq  = qq1 + qq2 + qq3 + qq4 + qq5;

s = fft(qq, 16384);
c = fft(conj(fliplr(s1)), 16384);
pc = ifft(s .* c, 16384);

range_axis = 3e8 * 1 / fs / 2 * linspace(1, 16384, 16384);
figure
plot(range_axis, abs(pc))