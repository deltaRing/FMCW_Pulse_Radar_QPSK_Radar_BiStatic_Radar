% 生成多通道的时频谱图实现对目标定位
addpath PassiveRadarConf\
addpath TargetConf\
addpath Algorithm\

% 定义雷达位置
RadarPosition = [0 0 0];
RadarVelocity = [0 0 0];
RadarAccelerate = [0 0 0];
ChannelNum = 4;
Tc = 1e-6;
Ts = 25e-6;
B  = 20e6;
Pt = 10e4;
Gt = 60;
PRI = 50e-6; % 有信号的时间 Ts PRI - Ts Idle Time
Fs = 50e6;
F0 = 10e9;
Gr = 60;
% 雷达结构体
Emitter  = SourceEmitter(Tc, Ts, Fs, F0, B, PRI, Pt, Gt, ...
    RadarPosition, RadarVelocity, RadarAccelerate);
Receiver = SourceReceiver(Fs, F0, Gr, ...
    RadarPosition, RadarVelocity, RadarAccelerate, ChannelNum);

% 总共时间
time = 20.0;
dt   = 0.1;

% 定义目标
TargetCenter   = [250, 150, 200];
TargetVelocity = [5, 1.5, 0];
TargetRCS      = 20;
TargetNum      = 1;
Target  = PointTarget(TargetCenter, TargetVelocity, TargetRCS);
Targets = {Target};

% 定义回波
[Sref, Ssurv, RangeProfile, RangeDoppler, AngleEcho] = BiRadarEcho(Emitter, Receiver, Targets);
Spectrums = {};
AngleData = [];
for chan = 1:ChannelNum
    one_AngleEcho   = AngleEcho(chan, :);
    one_spectrum    = STFT(one_AngleEcho, Fs, 128);
    Spectrums{chan} = one_spectrum;
    AngleData(chan) = one_spectrum(49, 2212);
end

