module testrunner;
import std.array;
import std.algorithm;
import std.file;
import std.path;
import std.process;
import std.stdio;

int main()
{
    writeln( "Building..." );
    auto dub = execute( [ "dub", "build" ] );
    if( dub.status != 0 )
    {
        writeln( "Build failed.\n", dub.output );
        return 1;
    }

    auto cwd = getcwd();
    auto llbuild = "llbuild".absolutePath();

    writeln( "Building projects..." );
    auto projects = "examples".dirEntries( SpanMode.shallow ).map!absolutePath.array();
    foreach( project; projects )
    {
        chdir( project );

        auto result = execute( [ llbuild, "run" ] );
        if( result.status != 0 )
        {
            writeln( "Project %s build failed:\n", project.baseName, result.output );
            return 1;
        }
        else
        {
            writefln( "%s: pass", project.baseName );
        }
    }

    return 0;
}
