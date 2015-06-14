module llbuild.project;
import llbuild.logger;
import llbuild.phases;
import llbuild.filefinders;
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
    /// Paths to look for source files in
    string[] sourcePaths;
    /// Paths to look for imported/included files in
    string[] importPaths;
    /// Paths to look for libs in
    string[] libPaths;
    /// Root of build folders
    string buildPath;
    /// Where intermediate files go
    string intermediatePath;
    /// The name of the linked aggregate file
    string aggregateFile;
    /// The name of the linked optimized aggregate file
    string aggregateOptFile;
    /// The path to the output file
    string outPath;
    /// The name of the output file
    string outFile;
    /// The root folder of the current project
    string projectRoot;
    /// The file finder to use when finding source files
    FileFinder fileFinder;
    /// Whether or not to emit IR instead of bitcode
    bool emitIR;
    /// Optimization level for final aggregated module
    OptimizationLevel finalOptimizationLevel;
    /// Optimization level for each individual compiled module
    OptimizationLevel compileOptimizationLevel;

    this()
    {
        import std.typecons: No;

        registerArgs(
            No.autoProcess,
            arg( "sourcePath|S", ( string opt, string val ) { sourcePaths ~= val; }, "Add source paths to search for code" ),
            arg( "importPath|I", ( string opt, string val ) { importPaths ~= val; }, "Add import paths to search for code and headers" ),
            arg( "libPath|L", ( string opt, string val ) { libPaths ~= val; }, "Add path to search for libs in" ),
            arg( "intermediatePath", &intermediatePath, "The intermediate artifact directory" ),
            arg( "outpath", &outPath, "The output path of the compiled file" ),
            arg( "outfile|o", &outFile, "The name of the final compiled file" ),
            arg( "filefinder", ( string opt, string val ) { fileFinder = FileFinder[ val ]; }, "Specifiy a file finder to use." ),
            arg( "emit-ir|r", &emitIR, "Emit LLVM IR instead of bitcode" ),
            arg( "opt", &finalOptimizationLevel, "LLVM level to optimize to after aggrecation" ),
            arg( "c-opt", &compileOptimizationLevel, "LLVM level to optimize to during compilation" ),
            arg( "verbose|v", { stdlog.logLevel = LogLevel.all; }, "Output more runtime information" )
        );
    }

    string intermediateExt() const
    {
        return emitIR ? "ll" : "bc";
    }

    void loadDefaultSettings()
    {
        import std.file: getcwd;

        sourcePaths = [];
        importPaths = [];

        buildPath = ".llbuild";
        intermediatePath = "int";
        aggregateFile = "app";
        aggregateOptFile = "app-opt";
        outPath = ".";
        outFile = "app";

        finalOptimizationLevel = OptimizationLevel.O3;
        compileOptimizationLevel = OptimizationLevel.O0;

        projectRoot = getcwd();
        fileFinder = FileFinder[ "filetree" ];
        emitIR = false;
    }

    bool loadSettings()
    {
        import sdl = sdlang;
        import std.algorithm: map;
        import std.array: array;
        import std.conv: to;
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
                    case "lib":
                        libPaths ~= vals;
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
                stdlog.logLevel = tag.values[ 0 ].get!string.to!LogLevel;
                break;

            case "intermediatePath":
                intermediatePath = tag.values[ 0 ].get!string;
                break;

            case "outPath":
                outPath = tag.values[ 0 ].get!string;
                break;

            case "outFile":
                outFile = tag.values[ 0 ].get!string;
                break;

            case "opt":
                finalOptimizationLevel = tag.values[ 0 ].get!string.to!OptimizationLevel;
                break;

            case "c-opt":
                compileOptimizationLevel = tag.values[ 0 ].get!string.to!OptimizationLevel;
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
        aggregateOptFile = buildPath.buildNormalizedPath( aggregateOptFile ).setExtension( intermediateExt );

        trace( "Settings: \nsourcePaths: ", sourcePaths, "\nimportPaths: ", importPaths, "\nint: ", intermediatePath, "\nff: ", fileFinder.name );

        return true;
    }
}
