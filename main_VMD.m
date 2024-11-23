T   = 1e3;
fs  = 1 / T;
t   = linspace(0, 1, T);
f_1 = 10;
f_2 = 50;
f_3 = 100;
mode_1 = (2 * t).^2;
mode_2 = sin(2 * pi * f_1 * t);
mode_3 = sin(2 * pi * f_2 * t);
mode_4 = sin(2 * pi * f_3 * t);
f = mode_1 + mode_2 + mode_3 + mode_4;

figure(10000)
plot(f)

K = 4;
alpha = 2000;
tau = 1e-6;
vmd = VMD(K, alpha, tau);
result = vmd.call(f);

figure(10001)
subplot(141)
plot(result.u(1, :))
subplot(142)
plot(result.u(2, :))
subplot(143)
plot(result.u(3, :))
subplot(144)
plot(result.u(4, :))