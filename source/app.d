module app;
import llbuild.compilers, llbuild.filefinders, llbuild.project;
import std.algorithm: map;
import std.process: getcwd;
import llbuild.logger;

int main( string[] args )
{
    trace( "Compilers: ", Compiler.getCompilers().map!( c => c.name ) );
    trace( "File finders: ", FileFinder.getFileFinders().map!( ff => ff.name ) );

    Project project;
    if( !project.initialize( args ) )
        return 1;

    if( !project.compile() )
        return 1;

    return 0;
}
