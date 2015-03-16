module llbuild.phases.link;
import llbuild.plugin, llbuild.project;
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

    override void initialize( Project project, ref string[] args )
    {
        super.initialize( project, args );
    }

    override void execute()
    {
        auto finder = FileFinder[ "filetree" ];
        auto files = finder.findFiles( project.intermediatePath );

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
