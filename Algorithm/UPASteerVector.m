% 生成均匀面阵列导向矢量
% 输入1：theta  目标方位角
% 输入2：fai    目标俯仰角
% 输入3：Lambda 阵列波长
% 输入4：Am     阵列多少行
% 输入5：An     阵列多少列
function A = UPASteerVector(theta, fai, Am, An)
    A = [];
    for pp = 1:Am
        for qq = 1:An
            Atf = 1 / sqrt(Am * An) * ...
                exp(1j * pi * ((pp - 1) * sin(theta) * sin(fai) + (qq - 1) *cos(fai)));
            A(pp, qq) = Atf;
        end
    end
    
end