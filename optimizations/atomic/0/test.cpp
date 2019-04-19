#include <chrono>
static int foo(int x)    // 'static' or not here doesn't affect ordering.
{
    return x*2;
}
int fred(int x)
{
    auto t1 = std::chrono::high_resolution_clock::now();
    int y = foo(x);
    auto t2 = std::chrono::high_resolution_clock::now();
    return y;
}
