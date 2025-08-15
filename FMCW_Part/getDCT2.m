% 得到DCT矩阵
function dctMatrix = getDCT2(M, N)
    dctMatrix = zeros(M, N);
    for ii = 1:M
        ap = sqrt(2 / M);
        if ii > 1, ap = 1 / sqrt(M); end
        for jj = 1:N
            aq = sqrt(1 / N);
            if jj > 1, aq = sqrt(2 / N); end
            XX = linspace(1, M, M);
            YY = linspace(1, N, N)';
            XXX = repmat(XX, N, 1)';
            YYY = repmat(YY, 1, M)';
            dctMatrix(ii, jj) = ap * aq * ...
                sum(sum(cos((pi * (2 * XXX + 1) * ii) / 2 / M) .* ...
                        cos((pi * (2 * YYY + 1) * jj) / 2 / N)));
        end
    end
end