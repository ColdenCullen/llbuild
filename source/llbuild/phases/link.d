module llbuild.phases.link;
import llbuild.plugin, llbuild.project, llbuild.logger;
import llbuild.phases.phase;
import llbuild.languages;

final class Link : Phase, Extension!( Link, Phase )
{
public:
    this()
    {
        super( "link", "Linking" );
    }

    override void execute()
    {
        import std.process: spawnProcess;

        trace( "Executing: ", "clang++" ~ createArgs() ~ project.aggregateOptFile );
        processId = spawnProcess( "clang++" ~ createArgs() ~ project.aggregateOptFile );
    }

private:
    string[] createArgs()
    {
        import std.array: array, join;
        import std.algorithm: map;

        typeof(return) args = [
            "-o", project.outFile,
        ];

        args ~= Language.activeLanguages.map!( l => l.libs )
                                        .join()
                                        .map!( l => "-l" ~ l )
                                        .array();

        args ~= project.libPaths.map!( p => "-L" ~ p ).array();

        return args;
    }
}
