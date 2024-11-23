addpath PassiveRadarConf\

% 定义雷达位置
RadarPosition = [0, 0, 0];
RadarVelocity = [0 0 0];
RadarAccelerate = [0 0 0];
Tc = 1e-6;
Ts = 25e-6;
B  = 20e6;
Pt = 1000e3;
Gt = 30;
PRI = 100e-6; % 有信号的时间 Ts PRI - Ts Idle Time
Fs = 50e6;
F0 = 10e9;
Gr = 20;
% 雷达结构体
Emitter  = SourceEmitter(Tc, Ts, Fs, F0, B, PRI, Pt, Gt, ...
    RadarPosition, RadarVelocity, RadarAccelerate);
Receiver = SourceReceiver(Fs, F0, Gr, ...
    RadarPosition, RadarVelocity, RadarAccelerate);

% 定义目标
Target1  = PointTarget([1000, 1000, 10], [10, 10, 0], 10);
Target2  = PointTarget([1000, 1000, 10] + 100 * [10 10 0], [0, 0, 0], 10);

Targets = {Target1};

% 定义回波
[Sref, Ssurv] = BiRadarEcho(Emitter, Receiver, Targets);
