#include <stdio.h>

void noop();
void fakeNoop();

int main()
{
    noop();
    fakeNoop();

    printf( "Dayum!\n" );

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
