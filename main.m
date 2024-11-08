addpath Algorithm
addpath RadarConf
addpath TargetConf
addpath PassiveRadarConf

% 定义雷达1
Radar = RadarStructure();

Target1 = PointTarget([-30 100 0] + randn(1, 3) * 30, [10 10 0] + randn(1, 3) * 5, 1);
[PS1, S1] = BiRadarEcho2(Radar, Target1);

Target2 = PointTarget([-30 100 0] + randn(1, 3) * 30, [10 10 0] + randn(1, 3) * 5, 1);
[PS2, S2] = BiRadarEcho2(Radar, Target2);

Target3 = PointTarget([-30 100 0] + randn(1, 3) * 30, [10 10 0] + randn(1, 3) * 5, 1);
[PS3, S3] = BiRadarEcho2(Radar, Target3);

Target4 = PointTarget([-30 100 0] + randn(1, 3) * 30, [1 1 0] + randn(1, 3) * 5, 1);
[PS4, S4] = BiRadarEcho2(Radar, Target4);

Target5 = PointTarget([-30 100 0] + 30 * randn(1, 3), [10 10 0], 1);
[PS5, S5] = BiRadarEcho2(Radar, Target5);

[PSref, Sref] = BiRadarDirectEcho(Radar);

Ssurv  = S1 + S2 + S3 + S4 + S5;
Stotal = Ssurv + Sref;

delay = 300;
N = 2000;
R = 600;

Sref1  = Sref(delay-R+1:delay+N);
Ssurv1 = Ssurv(delay+1:delay+N);

S_eca = ECA(Ssurv1, Sref1, R, N);

figure(1)
plot(abs(fft(S_eca, 2048)))
figure(2)
plot(abs(fft(Ssurv1, 2048)))
figure(3)
plot(abs(fft(Sref, 2048)))
 % FMCW雷达无法使用
