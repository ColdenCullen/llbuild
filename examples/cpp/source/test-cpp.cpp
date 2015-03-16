#include <iostream>

using namespace std;

void noop();
void fakeNoop();

int main()
{
    noop();
    fakeNoop();
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
