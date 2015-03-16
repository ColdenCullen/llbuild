module llbuild.phases.compile;
import llbuild.plugin, llbuild.project, llbuild.logger;
import llbuild.phases.phase;
import llbuild.compilers;

final class Compile : Phase, Extension!( Compile, Phase )
{
    this()
    {
        super( "compile" );
    }

    override void initialize( Project project, ref string[] args )
    {
        super.initialize( project, args );
    }

    override void execute()
    {
        import std.algorithm: canFind, filter, group, map;
        import std.array: array, join, replace;
        import std.path: extension, relativePath, buildNormalizedPath;

        string getIntermediatePath( const string path ) pure
        {
            auto relPath = relativePath( path, project.projectRoot ).replace( "..", "." ).buildNormalizedPath();
            return project.intermediatePath.buildNormalizedPath( relPath );
        }

        auto files = project.sourcePaths.map!( p => project.fileFinder.findFiles( p ) ).join();

        foreach( compiler; Compiler.getCompilers() )
        {
            auto filesForComp = files.filter!( f => compiler.extensions.canFind( f.extension ) ).array();

            tracef( "Files for compiler %s: %s", compiler.name, filesForComp );

            if( filesForComp.length > 0 )
            {
                compiler.execute( filesForComp, project );
                if( !compiler.waitForExecution() )
                    return ;// false;
            }
        }
    }
}
