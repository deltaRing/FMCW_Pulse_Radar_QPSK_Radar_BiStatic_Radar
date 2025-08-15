function TD = TargetDefine()
    %% 目标参数（可调）
    TD.N_targets = 3;
    TD.target_range = [50, 100, 250];       % 米
    TD.target_speed = [-30, 10, 25];        % m/s
    TD.target_rcs_dBsm = [-20, -18, -12];   % < -10 dBsm
    TD.target_rcs = 10.^(TD.target_rcs_dBsm / 10);
    
    TD.target_velo  = [20, 10.5, 0;
                        -10.5, -30, 0;
                        20, 25, 0];
    TD.target_location = [-10, 100, 10;
                            550, 300, 10;
                            40, 60, 20];
                        
    TD.update_location = @(t) TD.target_location + TD.target_velo * t;
    TD.get_relative_velo = @(posi) sum((TD.target_location - posi) .* TD.target_velo ./ ...
        sqrt(sum(abs(TD.target_location - posi).^2, 2)), 2);
    TD.get_relative_range = @(posi) sqrt(sum(abs(TD.target_location - posi).^2, 2));
end