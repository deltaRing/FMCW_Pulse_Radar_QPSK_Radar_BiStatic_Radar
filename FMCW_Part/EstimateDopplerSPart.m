function S = EstimateDopplerSPart(RD, R, R_STD, Doppler, D_STD, amp, amp_STD)
    if nargin == 1
        R = 25.0;             % 距离
        R_STD = 2.5;         % 距离方差
        Doppler = 7.5;      % 多普勒
        D_STD = 0.25; % 多普勒方差
        amp = -6.0;          % 泄露幅度
        amp_STD = 0.1;
    end
    Init
    
    N_chirps = RD.N_chirps;
    N_samples = RD.N_samples;
    S = zeros(N_chirps, N_samples);
    
    for chirp_idx = 1:N_chirps
        R_ = R + R_STD * randn;
        D_ = Doppler + D_STD * randn;
        amp_ = amp + amp_STD * randn;
        tau = 2 * R_ / c;                             % 往返延迟
        fd = 2 * D_ / RD.lambda;   % 多普勒频移

        delayed_t = RD.t + tau;
        valid_idx = delayed_t >= 0;  % 延迟后仍在采样范围

        % 延迟并加入多普勒的回波信号
        echo = zeros(1, RD.N_samples);
        delayed_chirp = exp(1j * pi * RD.K * delayed_t(valid_idx).^2);
        doppler_phase = exp(1j * 2 * pi * fd * (chirp_idx-1) * RD.T_chirp);

        echo(valid_idx) = amp_ * delayed_chirp * doppler_phase;
        S(chirp_idx, :) = S(chirp_idx, :) + echo; 
    end
end