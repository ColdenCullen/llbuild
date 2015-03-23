module llbuild.phases.execute;
import llbuild.plugin, llbuild.project, llbuild.logger;
import llbuild.phases.phase;
import llbuild.languages;

final class Execute : Phase, Extension!( Execute, Phase )
{
public:
    this()
    {
        super( "execute", "Executing" );
    }

    override void execute()
    {
        import std.process: spawnProcess;
        import std.path: absolutePath, buildNormalizedPath;

        auto exe = project.projectRoot.buildNormalizedPath( project.outPath, project.outFile )
                                      .absolutePath();

        trace( "Executing: ", exe ~ createArgs() );
        processId = spawnProcess( exe ~ createArgs() );
    }

private:
    string[] createArgs()
    {
        return [];
    }
}
