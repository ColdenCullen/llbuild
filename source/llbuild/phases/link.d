module llbuild.phases.link;
import llbuild.plugin, llbuild.project, llbuild.logger;
import llbuild.phases.phase;
import llbuild.filefinders;
import std.process;

class Link : Phase, Extension!( Link, Phase )
{
public:
    this()
    {
        super( "link" );
    }

    override void execute()
    {
        auto finder = FileFinder[ "filetree" ];
        auto files = finder.findFiles( project.intermediatePath );

        trace( "intermediate path: ", project.intermediatePath );
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
