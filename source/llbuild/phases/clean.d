module llbuild.phases.clean;
import llbuild.plugin, llbuild.project, llbuild.logger;
import llbuild.phases.phase;

class Clean : Phase, Extension!( Clean, Phase )
{
    this()
    {
        super( "clean" );
    }

    override void execute()
    {
        import std.array: array;
        import std.file: dirEntries, SpanMode, exists, remove;
        import std.path: buildNormalizedPath;

        info( "Cleaning..." );

        if( !project.buildPath.exists )
            return;

        auto files = project.buildPath.dirEntries( SpanMode.breadth ).array();

        foreach( file; files ) if( file.isFile )
        {
            trace( "Removing file ", file.name );
            file.name.remove();
        }
    }
}
