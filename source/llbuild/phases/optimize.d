module llbuild.phases.optimize;
import llbuild.plugin, llbuild.project;
import llbuild.phases.phase;
import llbuild.logger;

final class Optimize : Phase, Extension!( Optimize, Phase )
{
public:
    this()
    {
        super( "optimize" );
    }

    override void execute()
    {
        import std.process: spawnProcess;

        info( "Optimizing..." );

        trace( "Executing: ", [ "opt" ] ~ createArgs( project ) ~ project.aggregateFile );
        processId = spawnProcess( [ "opt" ] ~ createArgs( project ) ~ project.aggregateFile );
    }

private:
    string[] createArgs( Project project )
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
