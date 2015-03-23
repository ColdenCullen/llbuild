module llbuild.languages.d;
import llbuild.plugin, llbuild.project;
import llbuild.languages.language;
import llbuild.compilers;

class D : Language, Extension!( D, Language )
{
    this()
    {
        super( "d", [".d", ".di"], "ldc", ["druntime-ldc", "phobos2-ldc"] );
    }
}
