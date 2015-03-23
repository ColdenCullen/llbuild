module llbuild.commands.command;
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
        foreach( phase; getPhases() )
            phase.execute();
    }
}
