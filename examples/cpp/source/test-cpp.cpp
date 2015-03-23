#include <stdio.h>

void noop();
void fakeNoop();

int main()
{
    noop();
    fakeNoop();

    printf( "pass\n" );

    return 0;
}

void noop()
{

}

void fakeNoop()
{
    int x;
    for( int i = 0; i < 10; ++i )
        x += i;
}
