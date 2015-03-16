module app;
import llbuild.compilers, llbuild.filefinders, llbuild.project;
import llbuild.commands;
import std.algorithm: canFind, map;
import std.process: getcwd;
import llbuild.logger;

int main( string[] args )
{
    trace( "Compilers: ", Compiler.getCompilers().map!( c => c.name ) );
    trace( "File finders: ", FileFinder.getFileFinders().map!( ff => ff.name ) );

    Command command;
    Project project = new Project;

    if( args.length > 1 && Command.getCommands().map!( c => c.name ).canFind( args[ 1 ] ) )
        command = Command[ args[ 1 ] ];
    else
        command = Command[ "build" ];

    if( !project.initialize( args ) )
        return 1;
    command.initialize( project, args );

    command.execute();

    return 0;
}
