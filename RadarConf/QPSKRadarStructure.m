% QPSK 信号源
% Pt 发射信号
% Fs 采样率 与载频相关（需要大于两倍采样率）
% Gt 发射天线增益
% Gr 接收天线增益
% F0 载频
% B  基带信号载频
% Tc 单个码元持续时间
% Ts 总持续时间
% PRI 脉冲重复之间
function QPSK = QPSKRadarStructure(Pt, Fs, Gt, Gr, F0, ...
    B, Tc, Ts, PRI, PulseNum, ...
    Position, Velocity, Accelerate, ...
    ReceiverPosition, ReceiverVelocity, ReceiverAccelerate, ReceiverNum)
    
    if nargin == 0
        Pt  = 10e3;   % 10 KW
        Gt  = 13;     % 发射增益
        Gr  = 20;     % 接收增益
        F0  = 20e6;   % 载频
        B   = 10e3;
        Fs  = 100e6;    % 1000 MSPS
        Tc  = 1000e-9;   % 1us
        Ts  = 32e-6;  % 64us
        PRI = 100e-6; % 100us
        PulseNum = 64;
        Position = [0 0 0];
        Velocity = [0 0 0];
        Accelerate = [0 0 0];
        ReceiverPosition = [-2000 5000 1500];
        ReceiverVelocity = [0 0 0];
        ReceiverAccelerate = [0 0 0];
        ReceiverNum = 16;
    end
    
    % 基本参数配置
    QPSK.c    = 3e8;
    QPSK.Pt   = Pt;
    QPSK.Fs   = Fs;
    QPSK.Gt   = Gt;
    QPSK.Gr   = Gr;
    QPSK.F0   = F0;
    QPSK.Tc   = Tc;
    QPSK.Ts   = Ts;
    QPSK.PRI  = PRI;
    QPSK.PulseNum = PulseNum;
    QPSK.LTc  = fix(Tc * Fs);
    QPSK.LTs  = fix(Ts * Fs);
    QPSK.LPRI = fix(PRI * Fs);
    QPSK.Nc   = fix(Ts / Tc);
    QPSK.Waveform = zeros(1, QPSK.LPRI);
    QPSK.Lambda   = QPSK.c / F0;
    QPSK.Code = randi([1 4], [1 QPSK.Nc]);
    QPSK.Fai  = [1e-3 pi / 2 + 1e-3 pi + 1e-3 3 * pi / 2 + 1e-3] + pi / 4;
    QPSK.B    = B;
    t         = 0:1 / Fs:Tc - 1 / Fs;
    QPSK.t    = t;
    QPSK.tT   = [];

    tt = t;
    for ii = 1:QPSK.Nc
        Signal = exp(1j * 2 * pi * F0 * t) .* exp(1j * 2 * pi * B * t + ...
            1j * QPSK.Fai(QPSK.Code(ii)));
        QPSK.Waveform((ii - 1) * QPSK.LTc + 1: ii * QPSK.LTc) = Signal;
        QPSK.tT = [QPSK.tT tt];
        tt      = tt + t;
    end
    
    QPSK.Position = Position;
    QPSK.Velocity = Velocity;
    QPSK.Accelerate = Accelerate;

    QPSK.ReceiverPosition = ReceiverPosition;
    QPSK.ReceiverVelocity = ReceiverVelocity;
    QPSK.ReceiverAccelerate = ReceiverAccelerate;

    QPSK.RadialVelo = @(Position) sum((QPSK.Position - Position) .* Velocity / ...
        norm(Position - QPSK.Position));
    QPSK.ReceiverNum = ReceiverNum;
    QPSK.SteerVector = @(theta) exp(1j * pi * sin(theta) * (0:QPSK.ReceiverNum-1));
end