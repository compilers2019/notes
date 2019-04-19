#include <chrono>
int foo(int x);
int fred(int x)
{
    auto t1 = std::chrono::high_resolution_clock::now();
    int y = foo(x);
    auto t2 = std::chrono::high_resolution_clock::now();
    return y;
}
