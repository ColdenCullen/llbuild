module llbuild.linker;
import llbuild.project;
import llbuild.filefinders;
import std.process;

struct Linker
{
public:
    Pid processId;

    bool initialize( ref string[] args )
    {
        return true;
    }

    void execute( Project project )
    {
        auto finder = FileFinder[ "filetree" ];
        auto files = finder.findFiles( project.intermediatePath );

        processId = spawnProcess( [ "llvm-link" ] ~ createArgs( project ) ~ files );
    }

    bool waitForExecution()
    {
        return processId.wait() == 0;
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
