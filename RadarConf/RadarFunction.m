% 接收信号功率
% 雷达结构体
% 目标结构体
function Pr = RadarFunction(Radar, Target)
   
    Pr = Radar.Pt * Radar.Gt * Radar.Gr * Target.RCS * Radar.Lambda^2 / ...
            ((4 * pi)^3 * norm(Target.Position - Radar.Position)^4);

end