module llbuild.languages.cpp;
import llbuild.plugin, llbuild.project;
import llbuild.languages.language;

class Cpp : Language, Extension!( Cpp, Language )
{
    this()
    {
        super( "c++", [".c", ".cpp", ".cxx", ".C"], new Clang(), ["c++"] );
    }
}

final class Clang : Compiler
{
    this()
    {
        super( "clang", [ "cpp", "cxx" ], "clang" );
    }

    override string[] createArgs( Project project ) const
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
