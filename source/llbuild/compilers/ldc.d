module llbuild.compilers.ldc;
import llbuild.plugin;
import llbuild.project;
import llbuild.compilers.compiler;

final class LDC : Compiler, Extension!( LDC, Compiler )
{
    this()
    {
        super( "ldc", [ "d", "di" ], "ldc2" );
    }

    override string[] createArgs( Project project )
    {
        import std.algorithm: reduce;
        import std.conv: to;
        import std.path: setExtension;

        typeof(return) args = [
            project.emitIR ? "-output-ll" : "-output-bc",
            "-od="~project.intermediatePath,
            "-oq",
            "-"~project.compileOptimizationLevel.to!string
        ];

        foreach( imp; project.importPaths )
            args ~= ("-I=" ~ imp);

        return args;
    }
}
