module llbuild.phases.phase;
import llbuild.plugin, llbuild.project, llbuild.arghandler;
import std.process;

abstract class Phase : ArgHandler
{
public:
    mixin( extendable!Phase );

    immutable(string) name;
    immutable(string) verb;
    Project project;
    Pid processId;

    this( immutable(string) name_, immutable(string) verb_ )
    {
        name = name_;
        verb = verb_;
    }

    void initialize( Project project_ )
    {
        project = project_;
    }

    final bool waitForExecution()
    {
        return processId.wait() == 0;
    }

    final bool executeSync()
    {
        execute();
        return waitForExecution();
    }

    abstract void execute();
}
