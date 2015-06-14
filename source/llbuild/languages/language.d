module llbuild.languages.language;
import llbuild.plugin, llbuild.project;
import llbuild.arghandler, llbuild.logger;
import std.process: Pid, spawnProcess, wait;

class Language : ArgHandler
{
public:
    mixin( extendable!Language );

    static Language[] activeLanguages;

    immutable(string) name;
    immutable(string[]) extensions;
    immutable(string[]) libs;
    Compiler compiler;

    this( immutable(string) name_, immutable(string[]) extensions_, Compiler compiler_, immutable(string[]) libs_ )
    {
        name = name_;
        extensions = extensions_;
        compiler = compiler_;
        libs = libs_;
    }
}

/**
 * Class responsible for defining a compiler.
 */
abstract class Compiler : ArgHandler
{
public:
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
    abstract string[] createArgs( Project project ) const;

private:
    Pid processId;
}
