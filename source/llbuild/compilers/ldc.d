module llbuild.compilers.ldc;
import llbuild.plugin;
import llbuild.compilers.compiler;

final class LDC : Compiler, Extension!( LDC, Compiler )
{
    this()
    {
        super( "ldc", [ "d", "di" ], "ldc2" );
    }

    override string[] createArgs( const CompilationOptions options )
    {
        import std.algorithm: reduce;
        import std.conv: to;
        import std.path: setExtension;

        typeof(return) args = [
            options.emitIR ? "-output-ll" : "-output-bc",
            "-od="~options.intDir,
            "-oq",
            "-"~options.optimizationLevel.to!string
        ];

        foreach( imp; options.importPaths )
            args ~= ("-I=" ~ imp);

        return args;
    }
}
