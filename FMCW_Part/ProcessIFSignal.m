function ProcessIFSignal(RD, rx_signal_)
prob1 = 0.25; % 生成0的概率
prob2 = 0.99; % 生成0的概率
prob3 = 0.9;
%% 获取中频信号傅里叶变换矩阵
[R, D, iR, iD] = GenerateRangeDopplerMatrix(RD, 1000, 224);

%% ===== 混频过程：TX 与 RX 共轭相乘，得到中频信号 =====
IF_signal = rx_signal_ .* conj(RD.tx_chirp);  % 点乘，模拟下变频
IF_signal = IF_signal(:, 1:RD.dI:end);

IF_signal_MTI = IF_signal(33:end,:) - IF_signal(1:end-32, :);
% IF_signal_MTI = IF_signal - mean(IF_signal);
area_start    = 20;
area_end      = 50;
area_del      = area_end - area_start;
% Rx IF Signal is downsampled to 256 x 1000
% Range Profile is computed to 256 x 2048
% 
%% 显示第一条chirp的频谱
figure(1);
fft_IF_MTI = IF_signal_MTI * R;
imagesc(db(fft_IF_MTI));
MTD    = D * fft_IF_MTI;
% MTD    = [MTD(121:240, :); MTD(1:120, :)];
figure(2);
mesh(db(MTD));

%% Use the Compress Sensing
Hn = size(MTD, 1);
Vm = size(MTD, 2);
% 
% rank_estimated = 30;
% U_i = eye(rank_estimated);
% Y_i = eye(Vm);
% Y_i = Y_i(1:rank_estimated, :);
% 
% alphabet = [0 1]; prob = [prob1 1 - prob1];
% C2 = randsrc(Hn, Vm, [alphabet; prob]); % 伯努利随机01矩阵 （VM x HN）
% alphabet = [0 1]; prob = [prob2 1 - prob2];
% C1 = randsrc(Hn, area_del, [alphabet; prob]); % 伯努利随机01矩阵 （VM x HN）
% C = C2;
% C(:, area_start+1:area_end) = C1;
% observed_measures = C .* fft_IF_MTI;
% 
% % observed_measures = C .* IF_signal;
% [X, U, Y, ~, ~] = admm2(U_i, Y_i, observed_measures, observed_measures, C);
% %% result
% Z = X * U * Y;
% 
% DFT = D * Z;
% figure(3);
% mesh(db(DFT));
% figure(4)
% imagesc(db(Z));
% 
% [X_hat, ~] = admm_l21_ifft(observed_measures);
% figure(5)
% mesh(db(X_hat))
% figure(6)
% imagesc(db(ifft(X_hat)))
% figure(7)
% DFT2 = fft(C .* fft_IF_MTI, [], 1);
% mesh(db(DFT2))
% 

% %% 显示第一条chirp的频谱
% weigR(20:40,:) = weigR(20:40,:) * 1e-2;
% index = randi(1000, 1, 100);
% weigR(index, :) = weigR(index,:) * 1e-2;
% wR = (R * weigR);
% fft_IF_MTI = IF_signal_MTI * wR;
% 
% wD = (weigD * D);
% MTD    = wD * fft_IF_MTI;
% % MTD    = [MTD(121:240, :); MTD(1:120, :)];

alphabet = [0 1]; prob = [prob3 1 - prob3];
C1 = randsrc(Hn, Vm, [alphabet; prob]); % 伯努利随机01矩阵 （VM x HN）
X_i = C1 .* IF_signal_MTI;
alphabet = [0 1]; prob = [prob1 1 - prob1];
C2 = randsrc(Hn, Vm, [alphabet; prob]); % 伯努利随机01矩阵 （VM x HN）
alphabet = [0 1]; prob = [prob2 1 - prob2];
C1 = randsrc(Hn, area_del, [alphabet; prob]); % 伯努利随机01矩阵 （VM x HN）
C = C2;
C(:, area_start+1:area_end) = C1;
M = C .* MTD;

weigR = eye(1000) * 1e-2;
weigD = eye(224) * 1e-2;

[wa, X, wb, Z, A] = admm_wdft(weigD, D, ...
                            weigR, R, ...
                            X_i, M, ...
                            MTD, C);
MTDx = wa * D * X * R * wb;

figure(10)
mesh(abs(MTDx))
figure(11)
mesh(abs(ifft(MTDx, [], 1)))

end