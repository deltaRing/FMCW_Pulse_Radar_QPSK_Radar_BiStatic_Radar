function [RadarPulse, DownSample] = BiRadarDirectEcho(Radar)
    % 雷达位置
    RadarPos = Radar.Position;
    RadarReceiverPos = Radar.ReceiverPosition;
    % 接收功率
    Pr = BiRadarFunction(Radar, []);
    % 延迟时间
    tau = norm(RadarPos - RadarReceiverPos) / Radar.c;
    % 获取Index
    delayIndex = fix(tau * Radar.realTimeFactor);
    % 回波获取
    Echo = [zeros(1, delayIndex) Radar.Waveform];
    % 径向速度
    Velo = Radar.RadialVelo(RadarReceiverPos);
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