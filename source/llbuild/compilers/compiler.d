module llbuild.compilers.compiler;
import llbuild.logger;
import llbuild.plugin;
import llbuild.project;
import std.process;

/**
 * Class responsible for defining a compiler.
 */
abstract class Compiler
{
public:
    mixin( extendable!Compiler );

    /**
     * Finds a compiler based on the given extension.
     */
    static Compiler getByExtension( string ext )
    {
        import std.algorithm: canFind, filter;

        auto compilers = getCompilers().filter!( c => c.extensions.canFind( ext ) );
        return compilers.empty ? null : compilers.front;
    }

    immutable(string) name;
    immutable(string[]) extensions;
    immutable(string) executable;

    this( immutable(string) name_, immutable(string[]) extensions_, immutable(string) executable_ )
    {
        import std.algorithm: map;
        import std.array: array;

        name = name_;
        extensions = extensions_.map!( e => "." ~ e ).array;
        executable = executable_;
    }

    void execute( string[] files, Project project )
    {
        auto args = createArgs( project );
        trace( "Executing: ", executable ~ args ~ files );
        processId = spawnProcess( executable ~ args ~ files );
    }

    bool waitForExecution()
    {
        return processId.wait() == 0;
    }

protected:
    abstract string[] createArgs( Project project );

private:
    Pid processId;
}
