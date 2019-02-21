/* voc 2.1.0 [2017/09/27] for gcc LP64 on funtoo xtspa */

#define SHORTINT INT8
#define INTEGER  INT16
#define LONGINT  INT32
#define SET      UINT32

#include "SYSTEM.h"




export INT16 math_add (INT16 i, INT16 j);


INT16 math_add (INT16 i, INT16 j)
{
	return i + j;
}


export void *math__init(void)
{
	__DEFMOD;
	__REGMOD("math", 0);
/* BEGIN */
	__ENDMOD;
}
