function RD = RadarDefine()

%% 基础参数
c = 3e8;                             % 光速
RD.B = 200e6;                           % 带宽
RD.Fs = 200e6;                          % 采样率
RD.DFs = 10e6;
RD.T_chirp = 100e-6;                    % chirp时长R
RD.K = RD.B / RD.T_chirp;                     % chirp斜率
RD.Fc = 6e9;                            % 雷达中心频率
RD.lambda = c / RD.Fc;

RD.Pt_dBm = 31.3;                         % 发射功率 dBm
RD.Pt = 10^((RD.Pt_dBm - 30)/10);          % W
RD.Gt_dBi = 18;
RD.Gt = 10^(RD.Gt_dBi / 10);
RD.Pn_dBm = -130;
RD.Pn_Watt = 10^((RD.Pn_dBm - 30)/10);
RD.sigma_n = sqrt(RD.Pn_Watt);

RD.N_chirps = 256;
RD.N_samples = round(RD.Fs * RD.T_chirp);
RD.t = (0:RD.N_samples-1)/RD.Fs - RD.N_samples / 2 / RD.Fs;
RD.dN_samples = round(RD.DFs * RD.T_chirp);
RD.dt = (0:RD.N_samples-1)/RD.Fs;
RD.dI = RD.Fs / RD.DFs;

%% 发射chirp信号
RD.tx_chirp = exp(1j * pi * RD.K * RD.t.^2);  % 线性调频信号

RD.location = [0, 0, 0];

end