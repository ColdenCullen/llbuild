module testd;

void main()
{
    import std.stdio;
    writeln( "Testing!" );
}

void func2()
{
    func();
}

void func()
{
    int i;
    foreach( int x; 0..5 )
        i += x;
}
// Link cmd:
// ld test.o /usr/local/Cellar/ldc/0.15.1/lib/libdruntime-ldc.a /usr/local/Cellar/ldc/0.15.1/lib/libphobos2-ldc.a -lpthread -lcrt1.o -macosx_version_min 10.10 -o test
