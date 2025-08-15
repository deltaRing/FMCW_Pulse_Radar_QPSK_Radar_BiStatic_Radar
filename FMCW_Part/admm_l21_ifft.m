function [X_hat, history] = admm_l21_ifft(S, lambda, mu, rho, maxIter, tol_abs, tol_rel)
% ADMM solver for:
%   min_X lambda*||X||_{2,1} + (mu/2)*||S - ifft(X,[],1)||_F^2
%   A = ifft(.,[],1), A^H = fft(.,[],1)
%
% Inputs:
%   S        - Ndop x Nrange complex matrix (multi-chirp range profiles)
%   lambda   - regularization parameter (row-sparsity strength)
%   mu       - data fidelity weight
%   rho      - initial ADMM penalty
%   maxIter  - maximum number of iterations
%   tol_abs  - absolute tolerance for stopping
%   tol_rel  - relative tolerance for stopping
%
% Outputs:
%   X_hat    - estimated RD spectrum (Ndop x Nrange)
%   history  - struct with residuals and objective evolution

if nargin == 1
    lambda = 0.01;
    mu = 1.0;
    rho = 1.0;
    maxIter = 500;
    tol_abs = 1e-8;
    tol_rel = 1e-6;
end

[Ndop, Nrange] = size(S);

% Initialization
X = zeros(Ndop, Nrange);
Z = zeros(Ndop, Nrange);
U = zeros(Ndop, Nrange);

% Precompute A^H S
AH_S = fft(S, [], 1);

history.res_primal = [];
history.res_dual = [];
history.obj = [];

for k = 1:maxIter
    disp(k)
    % ---- X-step ----
    coef = mu + rho; % since A^H A = I
    X = (mu/coef) * AH_S + (rho/coef) * (Z - U);
    
    % ---- Z-step (row-wise shrinkage) ----
    W = X + U;
    Z_old = Z;
    for r = 1:Ndop
        wr = W(r,:);
        nr = norm(wr,2);
        thresh = lambda / rho;
        if nr <= thresh
            Z(r,:) = 0;
        else
            Z(r,:) = (1 - thresh / nr) * wr;
        end
    end
    
    
    
    % ---- dual update ----
    U = U + (X - Z);
    
    % ---- residuals ----
    r_prim = norm(X - Z, 'fro');
    s_dual = rho * norm(Z - Z_old, 'fro');
    history.res_primal(end+1) = r_prim;
    history.res_dual(end+1) = s_dual;
    
    % ---- objective ----
    AX = ifft(X, [], 1);
    obj = lambda * sum(sqrt(sum(abs(X).^2, 2))) + 0.5*mu*norm(S - AX, 'fro')^2;
    history.obj(end+1) = obj;
    
    % ---- stopping criterion ----
    eps_pri = sqrt(numel(X)) * tol_abs + tol_rel * max(norm(X,'fro'), norm(Z,'fro'));
    eps_dual = sqrt(numel(X)) * tol_abs + tol_rel * norm(rho*U,'fro');
    if (r_prim < eps_pri && s_dual < eps_dual)
        break;
    end
end

X_hat = X;

end