module llbuild.project;
import llbuild.logger;
import llbuild.phases;
import llbuild.filefinders;
import llbuild.compilers;
import llbuild.arghandler;

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

class Project : ArgHandler
{
    string[] sourcePaths;
    string[] importPaths;

    // Root of build folders.
    string buildPath;
    // Where intermediate files go.
    string intermediatePath;
    // The name of the linked aggregate file.
    string aggregateFile;

    string projectRoot;
    FileFinder fileFinder;
    bool emitIR;
    OptimizationLevel linkOptimizationLevel;
    OptimizationLevel compileOptimizationLevel;

    this()
    {
        import std.typecons: No;

        registerArgs(
            No.autoProcess,
            arg( "sourcePath|S", ( string opt, string val ) { sourcePaths ~= val; }, "Add source paths to search for code" ),
            arg( "importPath|I", ( string opt, string val ) { importPaths ~= val; }, "Add import paths to search for code and headers" ),
            arg( "intermediatePath|o", &intermediatePath, "Set intermediate artifact directory" ),
            arg( "filefinder", ( string opt, string val ) { fileFinder = FileFinder[ val ]; }, "Specifiy a file finder to use." ),
            arg( "emit-ir|r", &emitIR, "Emit LLVM IR instead of bitcode" ),
            arg( "verbose|v", { stdlog.logLevel = LogLevel.all; }, "Output more runtime information" )
        );
    }

    string intermediateExt() const
    {
        return emitIR ? "ll" : "bc";
    }

    void loadDefaultSettings()
    {
        import std.process: getcwd;

        sourcePaths = [];
        importPaths = [];

        buildPath = ".llbuild";
        intermediatePath = "int";
        aggregateFile = "app";

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
        import std.path: buildNormalizedPath, setExtension;

        // Load default settings.
        loadDefaultSettings();

        // Load settings from project file.
        if( !loadSettings() )
            return false;

        // Override with command options.
        processArgs();

        // Add source paths to import paths
        importPaths = (sourcePaths ~ importPaths).uniq().array();
        sourcePaths = sourcePaths.uniq().array();

        foreach( ref path; sourcePaths )
            path = projectRoot.buildNormalizedPath( path );
        foreach( ref path; importPaths )
            path = projectRoot.buildNormalizedPath( path );

        // Make paths absolute.
        buildPath = projectRoot.buildNormalizedPath( buildPath );
        intermediatePath = buildPath.buildNormalizedPath( intermediatePath );
        aggregateFile = buildPath.buildNormalizedPath( aggregateFile ).setExtension( intermediateExt );

        trace( "Settings: \nsourcePaths: ", sourcePaths, "\nimportPaths: ", importPaths, "\nint: ", intermediatePath, "\nff: ", fileFinder.name );

        return true;
    }
}
