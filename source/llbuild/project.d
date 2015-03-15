module llbuild.project;
import llbuild.logger;
import llbuild.filefinders;
import llbuild.compilers;

struct Project
{
    string[] sourcePaths;
    string[] importPaths;
    string intermediatePath;
    string projectRoot;
    FileFinder fileFinder;
    bool emitIR;

    void loadDefaultSettings()
    {
        import std.process: getcwd;

        sourcePaths = [ "source" ];
        intermediatePath = ".llbuild/int";
        projectRoot = getcwd();
        fileFinder = FileFinder[ "filetree" ];
        emitIR = false;
    }

    void loadSettings()
    {
        // Load from file
    }

    bool initialize( ref string[] args )
    {
        import std.algorithm: uniq;
        import std.array: array;
        import std.getopt;
        arraySep = ",";

        // Load default settings.
        loadDefaultSettings();

        // Load project root path.
        try
        {
            args.getopt(
                config.passThrough,
                "project|p", &projectRoot
            );
        }
        catch( GetOptException e )
        {
            fatal( e.msg );
            return false;
        }

        // Load settings from project file.
        loadSettings();

        // Override with command options.
        try
        {
            string fileFinderName = null;
            string[] extraSourcePaths;
            string[] extraImportPaths;
            args.getopt(
                config.passThrough,
                "sourcePath|S", &extraSourcePaths,
                "importPath|I", &extraImportPaths,
                "intermediatePath|o", &intermediatePath,
                "filefinder", &fileFinderName,
                "emit-ir|r", &emitIR,
                "verbose|v", () => stdlog.logLevel = LogLevel.all
            );

            sourcePaths ~= extraSourcePaths;
            importPaths ~= extraImportPaths;

            // If file finder name specified, use that one.
            if( fileFinderName )
                fileFinder = FileFinder[ fileFinderName ];
        }
        catch( GetOptException e )
        {
            fatal( e.msg );
            return false;
        }

        // Add source paths to import paths
        importPaths = (sourcePaths ~ importPaths).uniq().array();
        sourcePaths = sourcePaths.uniq().array();

        trace( "Settings: \nsourcePaths: ", sourcePaths, "\nimportPaths: ", importPaths, "\nint: ", intermediatePath, "\nff: ", fileFinder.name );

        return true;
    }

    CompilationOptions getCompilationOptions()
    {
        CompilationOptions opt;
        opt.emitIR = emitIR;
        opt.importPaths = importPaths;
        opt.intDir = intermediatePath;
        return opt;
    }

    bool compile()
    {
        import std.algorithm: canFind, filter, group, map;
        import std.array: array, join;
        import std.path: extension;

        info( "Compiling..." );

        auto files = sourcePaths.map!( p => fileFinder.findFiles( p ) ).join();
        CompilationOptions options = getCompilationOptions();

        foreach( compiler; Compiler.getCompilers() )
        {
            auto filesForComp = files.filter!( f => compiler.extensions.canFind( f.extension ) ).array;
            tracef( "Files for compiler %s: %s", compiler.name, filesForComp );
            compiler.execute( filesForComp, options );
            if( !compiler.waitForExecution() )
                return false;
        }

        return true;
    }

    string getIntermediatePath( const string path ) const pure
    {
        import std.array: replace;
        import std.path: relativePath, buildNormalizedPath;

        auto relPath = relativePath( path, projectRoot ).replace( "..", "." ).buildNormalizedPath();
        return intermediatePath.buildNormalizedPath( relPath );
    }
}
