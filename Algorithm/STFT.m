function spectrum = STFT(Signal, Fs, wLen)
    if nargin == 2
        wLen = 128;
    end

    sLen = length(Signal);
    hop  = wLen / 2;
    nFFT = wLen;
    
    % generate analysis and synthesis windows
    anal_win = blackmanharris(wLen, 'periodic');
    synth_win = hamming(wLen, 'periodic');

    [spectrum, ~, ~] = stft(Signal, Fs, 'Window', ...
        anal_win, 'OverlapLength', hop, ...
        'FFTLength', nFFT);
end