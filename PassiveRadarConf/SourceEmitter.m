% 随机QPSK（4个码元）
% 码元持续时间 Tc
% 持续时间     Ts
% 采样率       Fs
% 带宽         B
% 载频         F0
% 脉冲重复间隔 PRI
% 位置         Position
% 速度         Velocity
% 加速度       Accelerate
function EM = SourceEmitter(Tc, Ts, Fs, F0, B, PRI, Pt, Gt, Position, Velocity, Accelerate)

% 好像写成了脉冲多普勒雷达了

if (nargin == 0)
    Tc = 1e-6;
    Ts = 25e-6;
    Fs = 50e6;
    B  = 20e6;
    F0 = 10e9;
    Pt = 1000e3;
    Gt = 20;
    PRI = 100e-6; % 有信号的时间 Ts PRI - Ts Idle Time
    Position = [100 100 10];
    Velocity = [0 0 0];
    Accelerate = [0 0 0];
end 

Nc = round(Ts / Tc); % 码元数量
realTimeFactor = 1 / Fs; % 实时时间

EM.B = B;
K      = B / Ts;
EM.K = K;
EM.realTimeFactor = realTimeFactor;
EM.Fs  = Fs;
EM.Tc  = Tc;
EM.Ts  = Ts;
EM.F0  = F0;
EM.Nc  = Nc;
EM.Pt  = Pt;
EM.Gt  = Gt;
EM.PRI = PRI;
EM.LPRI = round(PRI / realTimeFactor);
EM.Fai  = [0, pi / 2, pi, 3 * pi / 2];
EM.Code = randi([0 3], [1 EM.Nc]);
EM.C    = 3e8; % 光速
EM.Lambda = EM.C / F0; % 波长

EM.WaveForm = [];
t             = 0:realTimeFactor:Tc-realTimeFactor; 
EM.t        = t;
EM.Lt       = length(t);
T             = 0:realTimeFactor:Ts-realTimeFactor;
EM.T        = t * Nc;
EM.LT       = length(T);

% 多码元
EM.WaveForm = zeros(1, EM.LT);
% 生成信号
for ii = 1:EM.Nc
    tt = t + Tc * (ii - 1);
    WaveForm = exp(1j * 2 * pi * K * tt.^2 + 1j * EM.Fai(EM.Code(ii) + 1));
    EM.WaveForm((ii - 1) * length(tt) + 1:ii * length(tt)) = WaveForm;
end
% 匹配滤波器
EM.MatchFilter = conj(fliplr([EM.WaveForm zeros(1, EM.LPRI - length(EM.WaveForm))]));

% 位置
EM.Position = Position;
EM.Velocity = Velocity;
EM.Accelerate = Accelerate;

EM.UpdatePosition = @(t) EM.Position + t * EM.Velocity + 0.5 * t^2 * EM.Accelerate;
EM.UpdateVelocity = @(t) EM.Velocity + t * EM.Accelerate;

end