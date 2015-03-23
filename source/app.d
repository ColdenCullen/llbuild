module app;
import llbuild.compilers, llbuild.filefinders, llbuild.project;
import llbuild.commands;
import llbuild.logger, llbuild.arghandler;

int main( string[] args )
{
    // Process arguments for classes that haven't disabled auto processing
    ArgHandler.autoProcessArgs();

    Command command;
    Project project = new Project;

    if( args.length > 1 && Command[ args[ 1 ] ] )
        command = Command[ args[ 1 ] ];
    else
        command = Command[ "run" ];

    if( !project.initialize( args ) )
        return 1;

    command.initialize( project );

    if( !command.execute() )
        return 1;

    return 0;
}
