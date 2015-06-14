module llbuild.filefinders.filefinder;
import llbuild.plugin;

/**
 * Class responsible for finding files to compile.
 */
abstract class FileFinder
{
    mixin( extendable!FileFinder );

    immutable(string) name;

    abstract string[] findFiles( string rootPath );

    this( immutable(string) name_ )
    {
        name = name_;
    }
}
