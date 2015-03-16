module llbuild.project;
import llbuild.logger;
import llbuild.linker;
import llbuild.filefinders;
import llbuild.compilers;

enum projectFileName = "llbuild.sdl";

/// LLVM optimization levels
enum OptimizationLevel
{
    O0,
    O1,
    O2,
    O3,
    Os,
    Oz,
}

struct Project
{
    string[] sourcePaths;
    string[] importPaths;
    string intermediatePath;
    string projectRoot;
    FileFinder fileFinder;
    bool emitIR;
    OptimizationLevel linkOptimizationLevel;
    OptimizationLevel compileOptimizationLevel;
    Linker linker;

    string intermediateExt() const
    {
        return emitIR ? "ll" : "bc";
    }

    void loadDefaultSettings()
    {
        import std.process: getcwd;

        sourcePaths = [];
        importPaths = [];
        intermediatePath = ".llbuild/int";
        projectRoot = getcwd();
        fileFinder = FileFinder[ "filetree" ];
        emitIR = false;
    }

    bool loadSettings()
    {
        import sdl = sdlang;
        import std.algorithm: map;
        import std.array: array;
        import std.file: exists;
        import std.path: buildNormalizedPath;

        auto packagePath = projectRoot.buildNormalizedPath( projectFileName );

        // If no package file, don't parse but building can continue.
        if( !packagePath.exists )
            return true;

        sdl.Tag packageSdl;
        try
        {
            packageSdl = sdl.parseFile( packagePath );
        }
        catch( sdl.SDLangParseException e )
        {
            fatal( e.msg );
        }

        foreach( tag; packageSdl.tags )
        {
            // Add paths
            switch( tag.name )
            {
            case "paths":
                foreach( pathDef; tag.tags )
                {
                    auto vals = pathDef.values.map!( v => v.get!string ).array;

                    switch( pathDef.name )
                    {
                    case "source":
                        sourcePaths ~= vals;
                        break;
                    case "import":
                        importPaths ~= vals;
                        break;
                    case "intermediate":
                        intermediatePath = vals[ 0 ];
                        break;
                    default:
                        fatalf( "Invalid path definition at %s.", pathDef.location.toString() );
                        return false;
                    }
                }
                break;

            case "filefinder":
                fileFinder = FileFinder[ tag.values[ 0 ].get!string ];
                break;

            case "emit-ir":
                emitIR = tag.values[ 0 ].get!bool;
                break;

            case "verbosity":
                import std.conv: to;
                stdlog.logLevel = tag.values[ 0 ].get!string.to!LogLevel;
                break;

            default:
                fatalf( "Invalid path definition at %s.", tag.location.toString() );
                return false;
            }
        }

        return true;
    }

    bool initialize( ref string[] args )
    {
        import std.algorithm: uniq;
        import std.array: array;
        import std.getopt;
        import std.path: buildNormalizedPath;
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
        if( !loadSettings() )
            return false;

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

        // Make intermediate path absolute.
        intermediatePath = projectRoot.buildNormalizedPath( intermediatePath );

        // Initialize the linker.
        linker.initialize( args );

        trace( "Settings: \nsourcePaths: ", sourcePaths, "\nimportPaths: ", importPaths, "\nint: ", intermediatePath, "\nff: ", fileFinder.name );

        return true;
    }

    void clean()
    {
        import std.array: array;
        import std.file: dirEntries, SpanMode, remove;
        import std.path: buildNormalizedPath;

        auto files = intermediatePath.dirEntries( SpanMode.breadth ).array();

        foreach( file; files )
        {
            trace( "Removing file ", file.name );
            file.name.remove();
        }
    }

    bool compile()
    {
        import std.algorithm: canFind, filter, group, map;
        import std.array: array, join, replace;
        import std.path: extension, relativePath, buildNormalizedPath;

        string getIntermediatePath( const string path ) pure
        {
            auto relPath = relativePath( path, projectRoot ).replace( "..", "." ).buildNormalizedPath();
            return intermediatePath.buildNormalizedPath( relPath );
        }

        info( "Compiling..." );

        auto files = sourcePaths.map!( p => fileFinder.findFiles( p ) ).join();

        foreach( compiler; Compiler.getCompilers() )
        {
            auto filesForComp = files.filter!( f => compiler.extensions.canFind( f.extension ) ).array();

            tracef( "Files for compiler %s: %s", compiler.name, filesForComp );

            compiler.execute( filesForComp, this );
            if( !compiler.waitForExecution() )
                return false;
        }

        return true;
    }

    bool link()
    {
        linker.execute( this );

        return true;
    }
}
