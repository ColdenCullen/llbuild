module testd;

void main()
{
    import std.stdio;
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
