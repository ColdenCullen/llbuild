module testd;

void main()
{
    func2();
    import std.stdio: writeln;
    writeln( "pass" );
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
