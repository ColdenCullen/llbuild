module llbuild.compilers.compiler;
import llbuild.logger, llbuild.plugin, llbuild.project, llbuild.arghandler;
import std.process;

/**
 * Class responsible for defining a compiler.
 */
abstract class Compiler : ArgHandler
{
public:
    mixin( extendable!Compiler );

    immutable(string) name;
    immutable(string) executable;

    this( immutable(string) name_, immutable(string[]) extensions_, immutable(string) executable_ )
    {
        import std.algorithm: map;
        import std.array: array;

        name = name_;
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
