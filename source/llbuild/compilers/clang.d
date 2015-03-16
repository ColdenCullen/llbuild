module llbuild.compilers.clang;
import llbuild.plugin;
import llbuild.compilers.compiler;

final class Clang : Compiler, Extension!( Clang, Compiler )
{
    this()
    {
        super( "clang", [ "cpp", "cxx" ], "clang" );
    }

    override string[] createArgs( const CompilationOptions options )
    {
        import std.conv: to;

        typeof(return) args = [
            "-cc1",
            options.emitIR ? "-S" : "",
            options.emitIR ? "-emit-llvm" : "-emit-llvm-bc",
            "-o", options.intDir~"/cpp."~options.intExtension,
            "-"~options.optimizationLevel.to!string
        ];

        foreach( imp; options.importPaths )
            args ~= ("-I=" ~ imp);

        return args;
    }
}
