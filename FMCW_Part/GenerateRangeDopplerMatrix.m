function [R, D, iR, iD] = GenerateRangeDopplerMatrix(RD, RFFT, DFFT)
    if nargin == 1
        RFFT = 2048;
        DFFT = 240;
    end
    % 
    Init
    RDP = zeros(DFFT, RFFT);
    B  = RD.B;
    K  = RD.K;
    Fs = RD.DFs;
    lambda = RD.lambda;
    T_chirp = RD.T_chirp;
    
    
    delta_r = c / 2 / B;
    delta_b = K * 2 / c;
    delta_R = c * Fs * T_chirp / 2 / B / RFFT;
    delta_Rf = Fs / RFFT;
    
    delta_D = lambda / 2 / DFFT / T_chirp;
    delta_Df = 1 / DFFT / T_chirp;
    
    n = -DFFT/2:DFFT/2-1;
    k = n';
    D = exp(-1j * 2 * pi * k * n / DFFT); % DFT 矩阵;
    
    n = 0:RFFT-1;
    k = n';
    R = exp(-1j * 2 * pi * k * n / RFFT); % DFT 矩阵;
    
    iD = conj(D);
    iR = conj(R);
end