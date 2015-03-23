module llbuild.commands;
import llbuild.plugin, llbuild.project;
import llbuild.phases;
import llbuild.logger;

abstract class Command
{
public:
    mixin( extendable!Command );

    immutable(string) name;

    this( immutable(string) name_ )
    {
        name = name_;
    }

    abstract Phase[] getPhases();

    final void initialize( Project project )
    {
        foreach( phase; getPhases() )
            phase.initialize( project );
    }

    final bool execute()
    {
        import std.process: wait;

        foreach( phase; getPhases() )
        {
            info( phase.verb, "..." );
            phase.execute();
            if( phase.processId )
            {
                auto status = phase.processId.wait();
                if( status != 0 )
                {
                    fatalf( "%s has failed with code %d.", phase.verb, status );
                    return false;
                }
            }
        }

        return true;
    }
}

final class Build : Command, Extension!( Build, Command )
{
    this()
    {
        super( "build" );
    }

    override Phase[] getPhases()
    {
        import std.algorithm: map;
        import std.array: array;

        return [
            "clean",
            "compile",
            "aggregate",
            "optimize",
        ].map!( n => Phase[ n ] ).array();
    }
}
