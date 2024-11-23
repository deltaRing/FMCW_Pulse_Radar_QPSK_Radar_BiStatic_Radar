% 变分模态分解
% 输入1：K 模态数
% 输入2：alpha 每个模态初始中心约束强度
% 输入3：tau   对偶项梯度下降率
% 输入4：tol   终止阈值
% 输入5：maxIters 最大迭代次数
% 输入6：eps
function vmd = VMD(K, alpha, tau, tol, maxIters, eps)
    if nargin == 3
        tol      = 1e-7;
        maxIters = 200;
        eps      = 1e-9;
    end

    vmd.K     = K;
    vmd.alpha = alpha;
    vmd.tau   = tau;
    vmd.tol   = tol;
    vmd.maxIters = maxIters;
    vmd.eps   = eps;
    vmd.call  = @(f) call(f, vmd.K, vmd.alpha, vmd.tau, ...
        vmd.tol, vmd.maxIters, vmd.eps);
end

function result = call(f, K, alpha, tau, tol, maxIters, eps)
    % N = length(f);
    % % 拼接
    % f = [f(1:fix(N / 2)), f, f(fix(N / 2):end)];
    T = length(f);
    t = linspace(1, T, T) / T;
    omega = t - 1.0 / T;
    % 解析信号
    f = hilbert(f);
    f_hat = fft(f);
    u_hat = zeros(K, T);
    omega_K = zeros(1, K);
    lambda_hat = zeros(1, T);
    % 判断
    u_hat_pre = zeros(K, T);
    u_D       = tol + eps;

    % 迭代
    n = 0;
    while n < maxIters && u_D > tol
        for k = 1:K
            % u_hat
            sum_u_hat = sum(u_hat, 1) - u_hat(k, :);
            res = f_hat - sum_u_hat;
            u_hat(k, :) = (res + lambda_hat / 2) ./ ...
                (1 + alpha * (omega - omega_K(k)).^2);

            % omega
            u_hat_k_2 = abs(u_hat(k, :)).^2;
            omega_K(k) = sum(omega .* u_hat_k_2) / sum(u_hat_k_2);
        end
        % lambda hat
        sum_u_hat = sum(u_hat, 1);
        res = f_hat - sum_u_hat;
        lambda_hat = lambda_hat - tau * res;
        n = n + 1;
        u_D = sum(sum(abs(u_hat - u_hat_pre).^2));
        u_hat_pre = u_hat;
    end

    % reconstruct the signal
    u = real(ifft(u_hat, length(u_hat), 2));
    omega_K = omega_K * T / 2;

    result.u = u;
    result.omega_K = omega_K;
end