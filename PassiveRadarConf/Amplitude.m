function Pr = Amplitude(Emitter, Target, Receiver)

    if isempty(Target)
        Pr = Emitter.Pt * Emitter.Gt * Emitter.Lambda^2 * Receiver.Gr / ...
        (4 * pi)^2 / norm(Emitter.Position - Receiver.Position)^2;
    else
        Pr = Emitter.Pt * Emitter.Gt * Target.RCS * Emitter.Lambda^2 * Receiver.Gr / ...
        (4 * pi)^3 / norm(Emitter.Position - Target.Position)^2 / ...
        norm(Receiver.Position - Target.Position)^2;
    end
end