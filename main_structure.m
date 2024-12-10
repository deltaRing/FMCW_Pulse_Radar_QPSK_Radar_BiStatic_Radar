addpath Algorithm
addpath PassiveRadarConf
addpath RadarConf
addpath TargetConf

QPSK = QPSKRadarStructure();
N = 4000;
R = 1000;  % Backward
Taxis = linspace(0, N / QPSK.Fs, N); 
Raxis = QPSK.c * Taxis;

delay_t = randperm(R, 4);
[Sref, Sindex] = BiRadarDirectEcho2(QPSK);

delay = Sindex;
Ssurv = zeros(1, N); 
% 
% Sref  = Sref(delay-R+1:delay+N);
TargetPosition = [100, 500, 100];

Clutter1 = PointTarget(TargetPosition + [1 1 0] * 5000, [10 10 0], 10);
Clutter2 = PointTarget(TargetPosition + [0 1 0] * 2500, [10 5 0] * 10, 10);
Clutter3 = PointTarget(TargetPosition + [-0.6 -0.5 0] * 3000, randn(1, 3) * 10, 10);
Clutter4 = PointTarget(TargetPosition + [0.1 0.75 0] * 5000, randn(1, 3) * 10, 10);
Clutter5 = PointTarget(TargetPosition + [0.5 0.25 0] * 1000, randn(1, 3) * 10, 10);
Target   = PointTarget(TargetPosition, [10 100 0], 10);

[Echo1, delayIndex1, Velo1] = BiRadarEcho3(QPSK, Clutter1);
[Echo2, delayIndex2, Velo2] = BiRadarEcho3(QPSK, Clutter2);
[Echo3, delayIndex3, Velo3] = BiRadarEcho3(QPSK, Clutter3);
[Echo4, delayIndex4, Velo4] = BiRadarEcho3(QPSK, Clutter4);
[Echo5, delayIndex5, Velo5] = BiRadarEcho3(QPSK, Clutter5);
[EchoT, delayIndexT, VeloT] = BiRadarEcho3(QPSK, Target);
delay1 = delayIndex1 - delay;
delay2 = delayIndex2 - delay;
delay3 = delayIndex3 - delay;
delay4 = delayIndex4 - delay;
delay5 = delayIndex5 - delay;
delayT = delayIndexT - delay;
delays = [delay1 
            delay2 
            delay3 
            delay4 
            delay5 
            delayT];
Echo   = [Echo1{1}(:,1).';
            Echo2{1}(:,1).'; 
            Echo3{1}(:,1).'; 
            Echo4{1}(:,1).'; 
            Echo5{1}(:,1).'; 
            EchoT{1}(:,1).'];

CEcho = Echo1{1} + Echo2{1} + Echo3{1} + Echo4{1} + Echo5{1};
AllEcho = CEcho + EchoT{1};
AllEcho = AllEcho + wgn(size(AllEcho, 1), size(AllEcho, 2), 1) * 1e-6;

% 最大探测速度
Vmax = QPSK.Lambda / 4 / QPSK.PRI / QPSK.PulseNum;
Doppler_Axis = linspace(-Vmax, Vmax, 512);
% 相对参考信号距离
Rmax = 1/QPSK.Fs * QPSK.LPRI * 3e8;
Range_Axis = linspace(0, Rmax, size(AllEcho, 1));

% output = CorFFT2D(AllEcho, 10, awgn(Sref, 10));
output = CorFFT(AllEcho, awgn(Sref, 10));
figure(1000)
plot(abs(output))

output = CorFFT(AllEcho - CEcho - wgn(size(AllEcho, 1), size(AllEcho, 2), 1) * 1e-6, ...
    awgn(Sref, 10));
figure(999)
plot(abs(output))

% mesh(linspace(1, QPSK.PulseNum, QPSK.PulseNum), Range_Axis, abs(output))
title('相对距离像')
ylabel('距离（m）')
xlabel('脉冲数')
figure(1001)
mesh(Doppler_Axis, Range_Axis, abs((fft(output, 512, 2))))
title('距离多普勒谱图')
ylabel('距离（m）')
xlabel('多普勒（m/s）')

disp(norm(Clutter1.Position - QPSK.ReceiverPosition) + norm(Clutter1.Position - QPSK.Position) - norm(QPSK.ReceiverPosition - QPSK.Position))
disp(norm(Clutter2.Position - QPSK.ReceiverPosition) + norm(Clutter2.Position - QPSK.Position) - norm(QPSK.ReceiverPosition - QPSK.Position))
disp(norm(Clutter3.Position - QPSK.ReceiverPosition) + norm(Clutter3.Position - QPSK.Position) - norm(QPSK.ReceiverPosition - QPSK.Position))
disp(norm(Clutter4.Position - QPSK.ReceiverPosition) + norm(Clutter4.Position - QPSK.Position) - norm(QPSK.ReceiverPosition - QPSK.Position))
disp(norm(Clutter5.Position - QPSK.ReceiverPosition) + norm(Clutter5.Position - QPSK.Position) - norm(QPSK.ReceiverPosition - QPSK.Position))
disp(norm(Target.Position - QPSK.ReceiverPosition) + norm(Target.Position - QPSK.Position) - norm(QPSK.ReceiverPosition - QPSK.Position))
disp(Velo1)
disp(Velo2)

% for ii = 1:size(Echo, 1)
%     signal = Echo(ii, :);
%     signal = signal(delay - delays(ii) + 1: delay - delays(ii) + N);
%     Ssurv  = Ssurv + signal;
% end
% 
% y = CorFFT(awgn([Ssurv zeros([1, R])], 1), awgn(Sref, 1));
% figure(1)
% plot(abs(y))
% 
% S_eca = ECA(Ssurv, Sref, R, N);
% y = CorFFT(awgn([S_eca zeros([1, R])], 1), awgn(Sref, 1));
% figure(2)
% plot(abs(y))
