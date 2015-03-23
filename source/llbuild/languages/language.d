module llbuild.languages.language;
import llbuild.plugin, llbuild.arghandler;
import llbuild.compilers;

class Language : ArgHandler
{
public:
    mixin( extendable!Language );

    static Language[] activeLanguages;

    immutable(string) name;
    immutable(string[]) extensions;
    immutable(string[]) libs;
    Compiler compiler() @property { return Compiler[ compilerName ]; }

    this( immutable(string) name_, immutable(string[]) extensions_, immutable(string) compilerName_, immutable(string[]) libs_ )
    {
        name = name_;
        extensions = extensions_;
        compilerName = compilerName_;
        libs = libs_;
    }

private:
    immutable(string) compilerName;
}
