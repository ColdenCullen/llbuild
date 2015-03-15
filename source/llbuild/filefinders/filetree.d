module llbuild.filefinders.filetree;
import llbuild.plugin;
import llbuild.filefinders.filefinder;

/**
 * Finds files by traversing the file tree.
 */
final class FileTreeFileFinder : FileFinder, Extension!( FileTreeFileFinder, FileFinder )
{
    this()
    {
        super( "filetree" );
    }

    override string[] findFiles( string rootPath )
    {
        import std.algorithm: map;
        import std.array: array;
        import std.file: dirEntries, SpanMode;

        return rootPath.dirEntries( SpanMode.breadth ).map!( f => f.name ).array();
    }
}
