void foo(const int *);

int
bar(void)
{
    int x = 0;
    int y = 0;
    for (int i = 0; i < 10; i++) {
        foo(&x);
        y += x;  // this load not optimized out
    }
    return y;
}

