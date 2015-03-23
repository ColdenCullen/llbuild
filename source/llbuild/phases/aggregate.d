module llbuild.phases.aggregate;
import llbuild.plugin, llbuild.project, llbuild.logger;
import llbuild.phases.phase;
import llbuild.filefinders;

class Aggregate : Phase, Extension!( Aggregate, Phase )
{
public:
    this()
    {
        super( "aggregate" );
    }

    override void execute()
    {
        import std.process;

        info( "Aggregating..." );

        auto finder = FileFinder[ "filetree" ];
        auto files = finder.findFiles( project.intermediatePath );

        trace( "Executing: ", [ "llvm-link" ] ~ createArgs( project ) ~ files );
        processId = spawnProcess( [ "llvm-link" ] ~ createArgs( project ) ~ files );
    }

private:
    string[] createArgs( Project project )
    {
        typeof(return) args = [
            project.emitIR ? "-S" : "",
            "-o", project.aggregateFile
        ];

        return args;
    }
}
