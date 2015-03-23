module llbuild.languages.cpp;
import llbuild.plugin, llbuild.project;
import llbuild.languages.language;
import llbuild.compilers;

class Cpp : Language, Extension!( Cpp, Language )
{
    this()
    {
        super( "c++", [".c", ".cpp", ".cxx", ".C"], "clang", ["c++"] );
    }
}
