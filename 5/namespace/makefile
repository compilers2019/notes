

hello:
			csc /target:library hello.cs 


print0:
			csc /reference:hello.dll print0.cs

print1:
			csc /reference:hello.dll print1.cs

A:
			csc /target:library A.cs

print2:
			csc /reference:hello.dll,A.dll print1.cs

print3:
			csc /reference:hello.dll,A.dll print2.cs
