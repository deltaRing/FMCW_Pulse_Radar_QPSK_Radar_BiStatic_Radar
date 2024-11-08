% 双站雷达回波获取
% 输入1：雷达结构体
% 输入2：目标结构体
% 输入3：距离FFT点数
% 输入4：速度FFT点数
% 单目标情形下
function [RadarPulse, DownSample] = BiRadarEcho2(Radar, Target)
    RadarPos = Radar.Position;
    RadarReceiverPos = Radar.ReceiverPosition;
    % 目标位置
    TargetPos = Target.Position;
    % 接收功率
    Pr = BiRadarFunction(Radar, Target);
    % 延迟时间
    tau = norm(RadarPos - TargetPos) / Radar.c + ...
        norm(RadarReceiverPos - TargetPos) / Radar.c;
    % 获取Index
    delayIndex = fix(tau * Radar.realTimeFactor);
    % 回波获取
    Echo = [zeros(1, delayIndex) Radar.Waveform];
    % 径向速度
    Velo = Target.BiRadialVelo(RadarPos, RadarReceiverPos);
    % 多普勒频率
    Fd   = 2 * Velo / Radar.Lambda;
    % 每段信号都存在一定多普勒 计算相位差
    DeltaFai = 4 * pi * Velo * Radar.Tc / Radar.Lambda;
    % 截取信号
    Echo = 1 * Echo(1: Radar.SignalLength); % + wgn(1, Radar.SignalLength, -110);
    % 混频信号
    Mixed = Echo .* conj(Radar.Waveform);
    % 降采样后
    Number = Radar.PRI * Radar.Fs; % 降采样点数
    Index  = linspace(1, Radar.SignalLength, Number);
    DownSample = Mixed(fix(Index));
    % 转换为脉冲 x 时序矩阵
    SinglePulse = fix(Radar.SingleLength * Radar.Fs);
    RadarPulse = zeros(Radar.Nc, SinglePulse);
    for ii = 1:Radar.Nc
        DownSample((ii - 1) * SinglePulse + 1: ii * SinglePulse) = ...
            DownSample((ii - 1) * SinglePulse + 1: ii * SinglePulse) * exp(1j * DeltaFai * (ii - 1));
        RadarPulse(ii, :) = DownSample((ii - 1) * SinglePulse + 1: ii * SinglePulse);
    end
    % 最大探测距离
    Rmax = Radar.Fs * Radar.c / 2 / Radar.K;
    % 最大探测速度
    Vmax = Radar.Lambda / 4 / Radar.Tc;
end