your compiler (supposedly) currently is able to generate code to

* enter the program
* exit the program
* assignment

extend already prepared compiler to deal with math expressions. deals are

* +, -, *, / (returns an integer), mod(%), parentheses.
* only 4 or 8 byte integers (depending on architecture)
* constants
* should work with declared variables, constants, and integer numbers.
* you would need to have a symbol table


hints:
on symbol table:
if you search on the internet, you get mostly trees, or hash tables. Wirth uses a linked list:
https://www.inf.ethz.ch/personal/wirth/CompilerConstruction/CompilerConstruction1.pdf (page 39).

symbol table management routines can(should?) also be moved to the separate module.

how to generate code for expressions:
https://github.com/lotabout/Let-s-build-a-compiler/
(directory 2)

to deal with consts: Programming from the ground up book has examples how to generate code for consts in .rodata section: http://mirror.rackdc.com/savannah/pgubook/ProgrammingGroundUp-1-0-lettersize.pdf

deadline:
april 21, 23:59.

link:
https://classroom.github.com/g/6Eudo9hs

