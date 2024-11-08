function S_eca = ECA(Ssurv, Sref, R, N)
    % 500 x 20000
    X     = zeros(N, R);
    
    for ii = 1:R
        X(:, ii) = Sref(R + 1 - ii: R + N - ii);
    end

    W = inv(X' * X) * X' * Ssurv.';
    S_eca = Ssurv - (X * W).';
end