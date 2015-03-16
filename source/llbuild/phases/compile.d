module llbuild.phases.compile;
import llbuild.plugin, llbuild.project;
import llbuild.phases.phase;

final class Compile : Phase, Extension!( Compile, Phase )
{
    this()
    {
        super( "compile" );
    }

    override void initialize( Project project, ref string[] args )
    {
        super.initialize( project, args );
    }

    override void execute()
    {

    }
}
