function rx_signal = BuildLeakage(RD, R, R_STD, Doppler, Doppler_STD, amp, amp_side, main_Leakage, side_Leakage)
    if nargin == 1
        R = 25.0;             % 距离
        R_STD = 2.5;         % 距离方差
        Doppler = 7.5;      % 多普勒
        Doppler_STD = 50.0; % 多普勒方差
        amp = -7.5;          % 泄露幅度
        amp_side = -9.5;
        main_Leakage = 1;
        side_Leakage = 500;
    end
    Init
    N_chirps = RD.N_chirps;
    N_samples = RD.N_samples;
    rx_signal = zeros(N_chirps, N_samples);
    
    for ii = 1:main_Leakage+side_Leakage
        R_ = R + R_STD * randn;
        if ii <= main_Leakage
            D_ = Doppler + 0.1 * randn;
            attenuation = 10^(amp + 0.01 * randn);
        else
            D_ = Doppler + Doppler_STD * randn; 
            attenuation = 10^(amp_side + 0.05 * randn);
        end
       
        for chirp_idx = 1:N_chirps
            tau = 2 * R_ / c;                             % 往返延迟
            fd = 2 * D_ / RD.lambda;   % 多普勒频移

            delayed_t = RD.t + tau;
            valid_idx = delayed_t >= 0;  % 延迟后仍在采样范围

            % 延迟并加入多普勒的回波信号
            echo = zeros(1, RD.N_samples);
            delayed_chirp = exp(1j * pi * RD.K * delayed_t(valid_idx).^2);
            doppler_phase = exp(1j * 2 * pi * fd * (chirp_idx-1) * RD.T_chirp);

            echo(valid_idx) = attenuation * delayed_chirp * doppler_phase;

            rx_signal(chirp_idx, :) = rx_signal(chirp_idx, :) + echo; 
        end
    end
end