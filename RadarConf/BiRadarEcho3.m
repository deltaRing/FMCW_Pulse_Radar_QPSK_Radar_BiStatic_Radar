function [Echos, delayIndex, Velo] = BiRadarEcho3(Radar, Target)
    
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
    delayIndex = fix(tau * Radar.Fs);
    % 回波获取
    Echo = [zeros(1, delayIndex) Radar.Waveform];
    % 径向速度
    Velo = Target.BiRadialVelo(RadarPos, RadarReceiverPos);
    % 多普勒频率
    Fd   = 2 * Velo / Radar.Lambda;
    % 每段信号都存在一定多普勒 计算相位差
    DeltaFai = 2 * pi * Fd; % 4 * pi * Velo * Radar.Tc / Radar.Lambda
    % 发射多个脉冲
    Echo_ = [];
    for pp = 1:Radar.PulseNum
        % 截取信号
        Echo = Pr * Echo(1: Radar.LPRI) .* exp(1j * DeltaFai * (pp - 1) * Radar.PRI);
        Echo_(:, pp) = Echo;
    end 
    % + wgn(1, Radar.SignalLength, -110);
    % Amuzith Radar
    theta = atan2(TargetPos(2) - RadarReceiverPos(2), TargetPos(1) - RadarReceiverPos(1));
    % 多天线
    SteerVector = Radar.SteerVector(theta);
    % Echo = Echo.' * SteerVector;
    
    for rr = 1:Radar.ReceiverNum
        Echos{rr} = Echo_ .* SteerVector(rr);
    end

end