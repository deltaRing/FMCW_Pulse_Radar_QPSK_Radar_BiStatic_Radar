% 点目标
% 输入1：坐标 Position (1 x 3)
% 输入2：速度 Velocity (1 x 3)
% 输入3：RCS 雷达反射截面积
% 
%
%
function Target = PointTarget(Position, Velocity, RCS)
    if nargin == 0
        Position = [300 300 0];
        Velocity = [5 5 0];
        RCS      = 10.0;
    end

    Target.Position = Position;
    Target.Velocity = Velocity;
    Target.RCS = RCS;
    % light speed
    Target.c   = 3e8; 

    % 目标位置更新
    Target.Update = @(t) Target.Position + Target.Velocity * t;
    % 计算回波延迟
    Target.Tau   = @(Position) 2 * norm(Position - Target.Position) / ...
        Target.c;
    % 计算相对径向速度
    Target.RadialVelo = @(Position) sum((Target.Position - Position) .* Velocity / ...
        norm(Position - Target.Position));
    % 计算相对方位角度
    Target.Azimuth = @(Position) atan2(-Position(2) + Target.Position(2), ...
        -Position(1) + Target.Position(1));
    % 计算相对俯仰角度
    Target.Elevation = @(Position) atan2(-Position(3) + Target.Position(3), ...
        norm(-Position(1:2) + Target.Position(1:2)));
    % 计算双站相对径向速度
    Target.BiRadialVelo = @(PT, PR) sum(((Target.Position - PT) / ...
        norm(PT - Target.Position) + (Target.Position - PR) / ...
        norm(PR - Target.Position)) .* Velocity);
end