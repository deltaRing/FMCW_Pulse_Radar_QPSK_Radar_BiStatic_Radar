function [wa, X, Z, A] = admm_dft(wa_i, D, X_i, Z_i, M, Omega)
   % Input 1: Range Weights
   % Input 2: DFT Matrix
   % Input 3: X_i Random Signal Matrix
   % Input 4: Z_i Random RD Map
   % Input 5: M Observed RD Map
   % Input 6: Omega 01 Matrix
   pho = 10^8;
   A = 0;
   tol = 10^-6;
   max_iter = 200;
   gamma = 1;
   t = 1;
   DFTs = size(X_i, 1);
   RFTs = size(X_i, 2);
   
   while(true)
       % Update wa
       wa_i = Z_i * (D * X_i)' * ...
           pinv(D * X_i * (D * X_i)');
       
       % Update X
       Wai  = wa_i * D;
       X_i  = pinv(Wai' * Wai) * ...
           Wai' * Z_i;
       
       % Update Z
       Z_i = Wai * X_i + Omega.*(M - Wai * X_i) - A/pho;
       
       % Update A
       A = A + gamma*pho*Omega.*(Z_i - M);
       
       % Update iteration count.
       t = t + 1;
       
       disp(mean(mean(abs(M - Wai * X_i))));
       
       if mean(mean(abs(M - Wai * X_i))) < tol
           break
       end
       if t == max_iter
           break
       end
   end
   wa = wa_i;
   X  = X_i;
   Z  = Z_i;
end