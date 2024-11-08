% 雷达发射机类
% Fs  采样率
% Nc  Chirp数目
% PRI 脉冲间隔时间
% Tc  Chirp时间
% Ti  Idle时间
% f0  载频
% K   调频斜率
% Gt  发射增益
% Gr  接受增益
% Pt  发射功率
% Position: 1 x 3
% Velocity: 1 x 3
%
% FMCW 波形
function FMCW = RadarStructure(Fs, ...
    Nc, PRI, Tc, Ti, f0, K, Gt, Gr, Pt, ...
    Position, ReceiverPosition, Velocity, ReceiverVelocity)
    
    if nargin == 0
        Fs  = 200e6; % by default the Fs is 200 MHz
        Nc  = 64;
        PRI = 10e-3; % 10ms
        Tc  = 100e-6; % 100us
        Ti  = 10e-6;
        f0  = 24e9;   % 24GHz
        K   = 10e12;  % 10MHz/us 
        Gt  = 13;
        Gr  = 13;
        Pt  = 10e3;
        % B = 1e9;    % 带宽有1GHz
        Position = [0 0 0];
        Velocity = [0 0 0];
        ReceiverPosition = [-30, 100, 100]; % 接收天线
        ReceiverVelocity = [0, 0, 0];
    end

    FMCW.Fs = Fs;
    FMCW.Nc = Nc; % 脉冲数目
    FMCW.PRI = PRI;
    FMCW.c   = 3e8; % 光速

    if Nc * Tc >= PRI
        error("RadarTransmitter: Chirp Number multiply the Chirp Time ..." + ...
            " cannot greater than PRI");
    end

    FMCW.Tc = Tc;
    FMCW.Ti = Ti;
    FMCW.f0 = f0;
    FMCW.K  = K;
    FMCW.B  = K * Tc;
    FMCW.Gt = Gt;
    FMCW.Gr = Gr;
    FMCW.Pt = Pt;
    FMCW.Lambda = FMCW.c / f0;

    realTimeFactor = 1 / (1 / K / Tc / 2);
    FMCW.realTimeFactor = realTimeFactor;

    FMCW.Waveform = zeros(1, fix(realTimeFactor * PRI));
    t   = linspace(0, Tc, fix(realTimeFactor * Tc));
    LFM = [exp(1j * pi * K * t.^2) zeros(1, fix(realTimeFactor * Ti))];
    
    % 单个波形
    FMCW.SingleWave = LFM;
    FMCW.SingleLength = Tc + Ti;

    % 生成多个脉冲
    for ii = 1:Nc
        FMCW.Waveform((ii-1) * length(LFM) + 1: ...
            ii * length(LFM)) = LFM;
    end
    FMCW.Position = Position; % 位置
    FMCW.Velocity = Velocity; % 速度
    FMCW.SignalLength = fix(realTimeFactor * PRI);

    FMCW.ReceiverNum = 8;
    FMCW.ReceiverPosition = ReceiverPosition;
    FMCW.ReceiverVelocity = ReceiverVelocity;
    % 计算相对径向速度
    FMCW.RadialVelo = @(Position) sum((FMCW.Position - Position) .* Velocity / ...
        norm(Position - FMCW.Position));
    FMCW.SteerVector = @(theta) exp(1j * pi * sin(theta) * 0:FMCW.ReceiverNum-1);
end