function [Echo, delayIndex] = BiRadarDirectEcho2(Radar)

    % 雷达位置
    RadarPos = Radar.Position;
    RadarReceiverPos = Radar.ReceiverPosition;
    % 接收功率
    Pr = BiRadarFunction(Radar, []);
    % 延迟时间
    tau = norm(RadarPos - RadarReceiverPos) / Radar.c;
    % 获取Index
    delayIndex = fix(tau * Radar.Fs);
    % 回波获取
    Echo = [zeros(1, delayIndex) Radar.Waveform];
    % 径向速度
    Velo = Radar.RadialVelo(RadarReceiverPos);
    % 多普勒频率
    Fd   = 2 * Velo / Radar.Lambda;
    % 每段信号都存在一定多普勒 计算相位差
    DeltaFai = 4 * pi * Velo * Radar.Tc / Radar.Lambda;
    % 截取信号
    Echo = 1 * Echo(1: Radar.LPRI) .* exp(1j * DeltaFai); % + wgn(1, Radar.SignalLength, -110);
end