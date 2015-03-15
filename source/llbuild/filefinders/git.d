module llbuild.filefinders.git;
version( Use_GitFileFinder ):

import llbuild.plugin;
import llbuild.filefinders.filefinder;

/**
 * Finds files by travising the git index.
 */
final class GitFileFinder : FileFinder, Extension!( GitFileFinder, FileFinder )
{
    this()
    {
        super( "git" );
    }

    override string[] findFiles( string rootPath )
    {
        assert( false, "Not implemented." );
    }
}
