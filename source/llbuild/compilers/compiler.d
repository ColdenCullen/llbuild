module llbuild.compilers.compiler;
import llbuild.plugin;
import std.process;

enum OptimizationLevel
{
    O0,
    O1,
    O2,
    O3,
    Os,
    Oz,
}

struct CompilationOptions
{
    bool emitIR = false;
    string[] importPaths;
    string intDir;
    OptimizationLevel optimizationLevel = OptimizationLevel.O0;

    string intExtension() const
    {
        return emitIR ? "ll" : "bc";
    }
}

/**
 * Class responsible for defining a compiler.
 */
abstract class Compiler
{
public:
    mixin( extendable!Compiler );

    /**
     * Get all supported file extensions.
     */
    static immutable(string[]) getExtensions()
    {
        import std.algorithm: map;
        import std.array: join;

        return getCompilers().map!( c => c.extensions ).join();
    }

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
    Pid processId;

    this( immutable(string) name_, immutable(string[]) extensions_, immutable(string) executable_ )
    {
        import std.algorithm: map;
        import std.array: array;

        name = name_;
        extensions = extensions_.map!( e => "." ~ e ).array;
        executable = executable_;
    }

    void execute( string[] files, const CompilationOptions opts )
    {
        auto args = createArgs( opts );
        processId = spawnProcess( executable ~ args ~ files );
    }

    bool waitForExecution()
    {
        auto result = processId.wait();

        return result == 0;
    }

    abstract string[] createArgs( const CompilationOptions options );
}
