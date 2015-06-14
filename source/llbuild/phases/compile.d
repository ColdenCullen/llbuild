module llbuild.phases.compile;
import llbuild.plugin, llbuild.project, llbuild.logger;
import llbuild.phases.phase;
import llbuild.languages;

final class Compile : Phase, Extension!( Compile, Phase )
{
    this()
    {
        super( "compile", "Compiling" );
    }

    override void execute()
    {
        import std.algorithm: canFind, filter, group, map;
        import std.array: array, join, replace;
        import std.file: exists, mkdirRecurse;
        import std.path: extension, relativePath, buildNormalizedPath;

        string getIntermediatePath( const string path ) pure
        {
            auto relPath = relativePath( path, project.projectRoot ).replace( "..", "." ).buildNormalizedPath();
            return project.intermediatePath.buildNormalizedPath( relPath );
        }

        // On Windows, compilers don't create the intermediate path if it doesn't exist
        if( !project.intermediatePath.exists )
            mkdirRecurse( project.intermediatePath );

        auto files = project.sourcePaths.map!( p => project.fileFinder.findFiles( p ) ).join();

        foreach( language; Language.getLanguages() )
        {
            auto filesForComp = files.filter!( f => language.extensions.canFind( f.extension ) ).array();

            if( filesForComp.length > 0 )
            {
                Language.activeLanguages ~= language;
                language.compiler.execute( filesForComp, project );
            }
        }

        foreach( lang; Language.activeLanguages )
            lang.compiler.waitForExecution();
    }
}
