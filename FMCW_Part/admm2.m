function [X, U, Y, Z, A] = admm2(U_i, Y_i, Z_i, M, Omega)
   pho = 10^8;
   A = 0;
   tol = 10^-8;
   max_iter = 200;
   U = U_i;
   Y = Y_i;
   Z = Z_i;
   gamma = 1;
   t = 1;
   output_size = size(M, 1);
   
   while(true)
       % Update X 
       UY = U*Y;
       X = (Z*(UY'))/(UY*(UY'));
       
       % Update Y
       XU = X*U;
       Y = ((XU')*(XU))\((XU')*Z);
       
       % Update U
       U = pinv(X'*X)*(X'*Z*Y')*pinv(Y*Y');
       
       % Update Z
       Z = X*U*Y + Omega.*(M - X*U*Y) - A/pho;
       
       % Update A
       A = A + gamma*pho*Omega.*(Z - M);
       
       % Update iteration count.
       t = t + 1;
       
       disp(t);
       
       if mean(mean(abs(M - X*U*Y))) < tol
           break
       end
       if t == max_iter
           break
       end
    end
end