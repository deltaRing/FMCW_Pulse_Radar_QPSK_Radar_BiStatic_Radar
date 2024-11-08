Receiver = SourceReceiver();
Emitter  = SourceEmitter();

Target1  = PointTarget([1000, 100, 10], [3, 10, 0], 10);
Target2  = PointTarget([1000, 100, 10] + 100 * randn(), [-10, 10, 0], 10);

Targets = {Target1, Target2};

[Sref, Ssurv] = BiRadarEcho(Emitter, Receiver, Targets);