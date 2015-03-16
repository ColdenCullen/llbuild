module llbuild.compilers.clang;
import llbuild.plugin;
import llbuild.project;
import llbuild.compilers.compiler;

final class Clang : Compiler, Extension!( Clang, Compiler )
{
    this()
    {
        super( "clang", [ "cpp", "cxx" ], "clang" );
    }

    override string[] createArgs( Project project )
    {
        import std.conv: to;

        typeof(return) args = [
            "-cc1",
            project.emitIR ? "-S" : "",
            project.emitIR ? "-emit-llvm" : "-emit-llvm-bc",
            "-o", project.intermediatePath~"/cpp."~project.intermediateExt,
            "-"~project.compileOptimizationLevel.to!string
        ];

        foreach( imp; project.importPaths )
            args ~= ("-I=" ~ imp);

        return args;
    }
}
