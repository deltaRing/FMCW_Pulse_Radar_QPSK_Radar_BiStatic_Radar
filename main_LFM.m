addpath PassiveRadarConf\
addpath TargetConf

% 定义雷达位置
RadarPosition = [0 0 0];
RadarVelocity = [0 0 0];
RadarAccelerate = [0 0 0];
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
    RadarPosition, RadarVelocity, RadarAccelerate, 16);

% 总共时间
time = 20.0;
dt   = 0.1;

% 定义目标
TargetCenter   = [250, 150, 200];
TargetVelocity = [5, 1.5, 0];
TargetRCS      = 20;
TargetNum      = 1;
Target  = PointTarget(TargetCenter, TargetVelocity, TargetRCS);

% 定义杂波位置
ClutterTotalNum   = randi([50 100]);
ClutterLoction    = TargetCenter + randi(PRI * 3e8 / 2 / 4, [ClutterTotalNum, 3]);
ClutterVelocity   = randi(10, [ClutterTotalNum, 3]);
ClutterAverageRCS = abs(randn([1, ClutterTotalNum])) * 2.5;

%% 记录距离谱、以及距离多普勒谱图
range_doppler = {};
range_profile = {};
echo          = {};

% 更新目标位置
for t = dt:dt:time
    TargetCenter = Target.Update(t);
    Target  = PointTarget(TargetCenter, TargetVelocity, TargetRCS);
    % 目标定义
    Targets = {Target};

    % 遍历杂波
    for cc = 1:ClutterTotalNum
        % 定义杂波
        ClutterNum = 30;
        for tt = 1:ClutterNum
            ClutterRCS     = abs(ClutterAverageRCS(cc) + randn() * 2.5);
            ClutterRandPos = ClutterLoction(cc, :) + randn(1, 3) * 50.0;
            ClutterRandVel = ClutterVelocity(cc, :) + randn(1, 3) * 2.0;
            Clutter = PointTarget(ClutterRandPos, ...
                ClutterRandVel, ClutterRCS);
            Targets{tt + (cc-1)*ClutterNum + TargetNum} = Clutter;
        end
    end
    % 定义回波
    [Sref, Ssurv, RangeProfile, RangeDoppler, AngleEcho] = BiRadarEcho(Emitter, Receiver, Targets);
    
    range_profile{end + 1} = RangeProfile;
    range_doppler{end + 1} = RangeDoppler;
    echo{end + 1}          = Ssurv;
end