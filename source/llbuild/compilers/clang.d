module llbuild.compilers.clang;
import llbuild.plugin;
import llbuild.compilers.compiler;

/*
final class Clang : Compiler, Extension!( Clang, Compiler )
{
    this()
    {
        super( "clang", [ "cpp", "cxx" ], "clang" );
    }

    override string[] createArgs( const string path, const string outDir, const CompilationOptions options )
    {
        import std.conv: to;

        return [
            "clang",
            options.emitIR ? "-emit-llvm" : "-emit-llvm-bc",
            "-o", outDir,
            "-"~options.optimizationLevel.to!string,
            path
        ];
    }
}
*/
