module llbuild.commands.build;
import llbuild.plugin;
import llbuild.phases;
import llbuild.commands.command;

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
