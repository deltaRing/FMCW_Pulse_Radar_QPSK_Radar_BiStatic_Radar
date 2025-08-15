clear all; close all;
addpath FMCW_Part

Init

% Radar define and Target Define
RD = RadarDefine();
TD = TargetDefine();
dt = 0.1;
effect_frame = 120;

%% 初始化回波矩阵
rx_signal = zeros(RD.N_chirps, RD.N_samples);
radar_pos = RD.location;

for ii = 102:effect_frame
    target_location = TD.update_location(ii * dt);
    target_range = sqrt(sum(abs(target_location - radar_pos).^2, 2));
    target_speed = TD.get_relative_velo(radar_pos);
    rx_signal = zeros(RD.N_chirps, RD.N_samples);
    for chirp_idx = 1:RD.N_chirps
        for tgt = 1:TD.N_targets
            R = target_range(tgt) + target_speed(tgt) * (chirp_idx - 1) * RD.T_chirp;
            tau = 2 * R / c;                             % 往返延迟
            fd = 2 * target_speed(tgt) / RD.lambda;   % 多普勒频移

            delayed_t = RD.t + tau;
            valid_idx = delayed_t >= 0;  % 延迟后仍在采样范围

            % 延迟并加入多普勒的回波信号
            echo = zeros(1, RD.N_samples);
            delayed_chirp = exp(1j * pi * RD.K * delayed_t(valid_idx).^2);
            doppler_phase = exp(1j * 2 * pi * fd * (chirp_idx-1) * RD.T_chirp);

            % 衰减模型（含RCS & 距离）
            attenuation = sqrt(RD.Pt * RD.Gt * TD.target_rcs(tgt) * RD.lambda^2 / ((4*pi)^3 * R^4));
            echo(valid_idx) = attenuation * delayed_chirp * doppler_phase;

            % 叠加所有目标回波
            rx_signal(chirp_idx, :) = rx_signal(chirp_idx, :) + echo;
        end
    end
    % Leakage
    Leakage = BuildLeakage(RD);

    % 加入复数高斯白噪声
    noise = RD.sigma_n / sqrt(2) * (randn(size(rx_signal)) + 1j * randn(size(rx_signal)));
    rx_signal_ = rx_signal + noise + Leakage;
    
    save(strcat('./SavedEcho/', num2str(ii), '.mat'), 'rx_signal', 'Leakage', ...
        'rx_signal_', 'TD', 'RD');
end

ProcessIFSignal(RD, rx_signal_);
