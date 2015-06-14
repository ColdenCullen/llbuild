module llbuild.languages.d;
import llbuild.plugin, llbuild.project;
import llbuild.languages.language;

class D : Language, Extension!( D, Language )
{
    this()
    {
        super( "d", [".d", ".di"], new LDC(), ["druntime-ldc", "phobos2-ldc"] );
    }
}

final class LDC : Compiler
{
    this()
    {
        super( "ldc", [ "d", "di" ], "ldc2" );
    }

    override string[] createArgs( Project project ) const
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
