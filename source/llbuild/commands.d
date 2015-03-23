module llbuild.commands;
import llbuild.plugin, llbuild.project;
import llbuild.phases;

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

    final void execute()
    {
        import std.process: wait;

        foreach( phase; getPhases() )
        {
            phase.execute();
            if( phase.processId )
                phase.processId.wait();
        }
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
            "link",
            "optimize",
        ].map!( n => Phase[ n ] ).array();
    }
}
