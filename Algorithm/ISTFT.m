function [X, T] = ISTFT(spectrum, Fs, wLen, hop)
    if nargin == 2
        wLen = 128;
        hop  = wLen / 2;
    end

    % generate analysis and synthesis windows
    anal_win = blackmanharris(wLen, 'periodic');
    synth_win = hamming(wLen, 'periodic');

    [X, T] = istft(spectrum, Fs, 'Window', synth_win, ...
        'OverlapLength', hop);
end