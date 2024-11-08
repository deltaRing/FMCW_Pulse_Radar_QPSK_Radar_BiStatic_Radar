function Pr = BiRadarFunction(Emitter, Target)
    if isempty(Target)
        Pr = Emitter.Pt * Emitter.Gt * Emitter.Lambda^2 * Emitter.Gr / ...
        (4 * pi)^2 / norm(Emitter.Position - Emitter.ReceiverPosition)^2;
    else
        Pr = Emitter.Pt * Emitter.Gt * Target.RCS * Emitter.Lambda^2 * Emitter.Gr / ...
        (4 * pi)^3 / norm(Emitter.Position - Target.Position)^2 / ...
        norm(Emitter.ReceiverPosition - Target.Position)^2;
    end
end