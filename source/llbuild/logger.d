module llbuild.logger;

public import std.experimental.logger;

static this()
{
    stdlog = new ConsoleLogger( LogLevel.trace );
}

final class ConsoleLogger : Logger
{
    this( LogLevel lv )
    {
        super( lv );
        fatalHandler = () {};
    }

    override void writeLogMsg( ref LogEntry payload )
    {
        import std.algorithm: map, sort;
        import std.array: array;
        import std.conv: to;
        import std.stdio;
        import std.traits: EnumMembers;

        enum l = [EnumMembers!(LogLevel)].map!( m => m.to!string.length ).array.sort!"a > b".front;

        auto file = payload.logLevel > LogLevel.warning ? stderr : stdout;
        auto logLevelStr = payload.logLevel.to!string;
        auto leftOverSpacing = (l - logLevelStr.length).to!int;
        file.writefln( "[%s]%*.*s %s", logLevelStr, leftOverSpacing, leftOverSpacing, "", payload.msg );
    }
}
