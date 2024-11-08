% 双向雷达回波获取
% 输入1： RadarTransmitter 发射站
% 输入2： RadarReceiver    接收站
% 输入3： Target           目标（多个目标）
% 输入4： PulseNum         脉冲数目（重复次数）
function [Sref, Ssurv] = BiRadarEcho(Transmitter, ...
    Receiver, ...
    Target, ...
    PulseNum)

    if nargin == 3
        PulseNum = 64;
    end
    
    TargetNum = length(Target);
    % 直接距离
    RangeTR   = norm(Transmitter.Position - Receiver.Position);
    % 发射站到目标的距离
    RangeTP   = [];
    % 目标到接收站的距离
    RangePR   = [];
    % 相对多普勒频率
    Fd        = [];
    % 径向速度
    Velo      = [];
    % 参考信号延时
    TauRefIndex = RangeTR / Transmitter.C;
    % 目标信号延时
    TauTarIndex = [];
    % 距离计算
    for tt = 1:TargetNum
        RangeTP(tt) = norm(Target{tt}.Position - Transmitter.Position);
        RangePR(tt) = norm(Target{tt}.Position - Receiver.Position);
        Velo(tt)        = Target{tt}.BiRadialVelo(Transmitter.Position, Receiver.Position);
        Fd(tt)          = 2 * Velo(tt) / Transmitter.Lambda;
        TauTarIndex(tt) = (RangeTP(tt) + RangePR(tt)) / Transmitter.C;
    end
    % 参考信号定义
    Sref   = zeros(1, PulseNum * Transmitter.LPRI);
    % 目标与杂点接收信号定义
    Ssurv  = zeros(1, PulseNum * Transmitter.LPRI);
    % 信号定义
    Signal = zeros(1, PulseNum * Transmitter.LPRI);

    % 重复发射信号
    for pp = 1:PulseNum
        Signal((pp - 1) * Transmitter.LPRI + 1: ...
                (pp - 1) * Transmitter.LPRI + Transmitter.LT) = Transmitter.WaveForm;
    end

    % 幅度计算
    Amp = Amplitude(Transmitter, [], Receiver);

    % 参考信号
    Sref = [zeros(1, fix(TauRefIndex / Transmitter.realTimeFactor)) Signal];
    Sref = Amp * Sref(1:PulseNum * Transmitter.LPRI);

    % 目标信号
    for tt = 1:TargetNum
        Echoes  = [zeros(1, fix(TauTarIndex(tt) / Transmitter.realTimeFactor)) Signal];
        TarAmp  = Amplitude(Transmitter, Target{tt}, Receiver);
        Signal  = 1 .* Echoes(1:PulseNum * Transmitter.LPRI);
        % 加相位
        Phase   = zeros(1, PulseNum * Transmitter.LPRI);
        for pp = 1:PulseNum
            DeltaFai = 4 * pi * Velo(tt) * Transmitter.LPRI / Transmitter.Lambda;
            Phase((pp - 1) * Transmitter.LPRI + 1: pp * Transmitter.LPRI) = ...
                exp(1j * DeltaFai * (pp - 1));
        end
        Ssurv = Ssurv + Signal .* Phase;
    end
    Ssurv = Ssurv;

    % Reshape
    SrefMatrix  = zeros(PulseNum, Transmitter.LPRI);
    SsurvMatrix = zeros(PulseNum, Transmitter.LPRI);

    % 重塑矩阵
    for pp = 1:PulseNum
        SrefMatrix(pp, :)  = Sref((pp - 1) * Transmitter.LPRI + 1: pp * Transmitter.LPRI);
        SsurvMatrix(pp, :) = Ssurv((pp - 1) * Transmitter.LPRI + 1: pp * Transmitter.LPRI);
    end

    % 脉冲压缩 填充
    MatchFilter   = [Transmitter.MatchFilter zeros(1, Transmitter.LPRI - length(Transmitter.MatchFilter))];
    SsurvMatrixPC = zeros(PulseNum, Transmitter.LPRI);
    for pp = 1:PulseNum
        SsurvMatrixPC(pp, :) = ifft(fft(SsurvMatrix(pp, :), Transmitter.LPRI) .* ... 
                                        fft(MatchFilter, Transmitter.LPRI));
    end
    

    figure(9998)
    mesh(abs(SsurvMatrixPC))

    RDMap = fftshift(fft(SsurvMatrixPC, 1024));
    figure(9999)
    mesh(abs(RDMap))
end