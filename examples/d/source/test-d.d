module testd;

void main()
{
    func2();
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
