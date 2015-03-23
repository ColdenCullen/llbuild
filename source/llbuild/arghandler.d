module llbuild.arghandler;
import std.typecons;
import std.traits;

class ArgHandler
{
public:
    alias ArgHelpTup = Tuple!( string, "pattern", string, "help" );

    /// Registers arguments
    void registerArgs( Args... )( Args args )
    {
        assert( processArgs == null, "registerArgs already called." );

        foreach( i, ArgT; Args )
        {
            static if( is(ArgT == Flag!"autoProcess" ) )
            {
                autoProcess = args[ i ];
            }
            else
            {
                static assert( is(typeof(ArgT.isArgument)) && ArgT.isArgument,
                               "All arguments passed to registerArgs must be created by arg()." );

                // Store for help printing.
                _argHelp ~= ArgHelpTup( args[ i ].pattern, args[ i ].help );
            }
        }

        processArgs = {
            import core.runtime: Runtime;
            import std.algorithm: canFind;
            import std.conv: to;
            import std.getopt;

            arraySep = ",";
            foreach( arg; args )
            {
                static if( is(typeof(arg.isArgument)) )
                {
                    string[] rtArgs = Runtime.args;
                    rtArgs.getopt(
                        config.passThrough,
                        arg.pattern, arg.pointer
                    );
                }
            }
        };

        argHandlers ~= this;
    }

    /// The list of argument pattersn and their help texts
    const(ArgHelpTup[]) argHelp() const @property { return _argHelp; }
    static const(ArgHelpTup[]) allArgs() @property
    {
        import std.algorithm: map, join;
        import std.array: array;
        return argHandlers.map!( h => h.argHelp ).join();
    }

    static void autoProcessArgs()
    {
        foreach( handler; argHandlers )
            if( handler.autoProcess )
                handler.processArgs();
    }

    /// Generated function that process arguments
    void delegate() processArgs;

private:
    bool autoProcess = true;
    ArgHelpTup[] _argHelp;
    static ArgHandler[] argHandlers;
}

/// Create argument definition from pointer
auto arg( T )( string pattern, T* pointer, string help ) if( !isCallable!T )
{
    struct Argument
    {
        string pattern;
        T* pointer;
        string help;

        enum isArgument = true;
    }

    return Argument( pattern, pointer, help );
}

/// Create argument definition from function
auto arg( ReturnT, ArgT... )( string pattern, ReturnT delegate( ArgT ) handler, string help )
{
    struct Argument
    {
        string pattern;
        ReturnT delegate( ArgT ) pointer;
        string help;

        enum isArgument = true;
    }

    return Argument( pattern, handler, help );
}
