#include <stdexcept>

constexpr int f(int a)
{
//if (a == 2) throw std::out_of_range ("aaa");
return a*a;

}

const int f2(int a)
{

return a*a;

}


//const int x = 42;
//constexpr int y = 23;

//const int z = f(2);
//const int z2 = f(2);

int main()

{

  constexpr int x = f(2);
  static int y = f2(6);
  return 0;
}

