module llbuild.phases.optimize;
import llbuild.plugin, llbuild.project;
import llbuild.phases.phase;

final class Optimize : Phase, Extension!( Optimize, Phase )
{
    this()
    {
        super( "optimize" );
    }

    override void initialize( Project project, ref string[] args )
    {
        super.initialize( project, args );
    }

    override void execute()
    {

    }
}
