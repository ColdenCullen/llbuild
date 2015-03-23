module llbuild.phases.optimize;
import llbuild.plugin, llbuild.project;
import llbuild.phases.phase;
import llbuild.logger;

final class Optimize : Phase, Extension!( Optimize, Phase )
{
public:
    this()
    {
        super( "optimize", "Optimizing" );
    }

    override void execute()
    {
        import std.process: spawnProcess;

        trace( "Executing: ", "opt" ~ createArgs() ~ project.aggregateFile );
        processId = spawnProcess( "opt" ~ createArgs() ~ project.aggregateFile );
    }

private:
    string[] createArgs()
    {
        import std.conv: to;

        typeof(return) args = [
            project.emitIR ? "-S" : "",
            "-o", project.aggregateOptFile,
            "-"~project.finalOptimizationLevel.to!string
        ];

        return args;
    }
}
