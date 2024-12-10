% 采样率   Fs
% 中频     F0
% 位置     Position
% 速度     Velocity
% 加速度   Accelerate
function EM = SourceReceiver(Fs, F0, Gr, Position, Velocity, Accelerate, ReceiverNum)

if nargin == 0
    Fs = 50e6;
    F0 = 10e9;
    Gr = 43;
    Position = [0 0 0];
    Velocity = [0 0 0];
    Accelerate = [0 0 0];
    ReceiverNum = 16;
end

EM.Fs = Fs;
EM.F0 = F0;
EM.Gr = Gr;
EM.B  = Fs / 2;
EM.c  = 3e8; % 光速
EM.Lambda = EM.c / EM.F0;
EM.Position = Position;
EM.Velocity = Velocity;
EM.Accelerate = Accelerate;

B = Fs / 2; % 带宽
realTimeFactor = 1 / F0 / 2; % 实时时间

EM.B = B;
EM.realTimeFactor = realTimeFactor;
EM.GetQPSKBase    = @(signal, t) exp(-1j * 2 * pi * F0 * t) .* signal;
EM.UpdatePosition = @(t) EM.Position + t * EM.Velocity + 0.5 * t^2 * EM.Accelerate;
EM.UpdateVelocity = @(t) EM.Velocity + t * EM.Accelerate;

EM.ReceiverNum = ReceiverNum;
EM.SteerVector = @(theta) exp(1j * pi * sin(theta) * (0:EM.ReceiverNum-1));
end