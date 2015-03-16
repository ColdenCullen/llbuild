module llbuild.linker;
import llbuild.project;
import llbuild.filefinders;

struct Linker
{
    bool initialize( ref string[] args )
    {
        return true;
    }

    bool execute( Project project )
    {
        auto finder = FileFinder[ "filetree" ];
        auto files = finder.findFiles( project.intermediatePath );

        return true;
    }
}
