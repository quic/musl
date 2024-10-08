/******************************************************************
# Copyright (c) $Date$ QUALCOMM INCORPORATED.
# All Rights Reserved.
# $Revision$
# Modified by QUALCOMM INCORPORATED on $Date$
******************************************************************/
.macro FUNCTION_BEGIN name
.text
.p2align 4
.globl \name
.type  \name, @function
\name:
.endm

.macro FUNCTION_END name
.size  \name, . - \name
.endm
FUNCTION_BEGIN fabsl
  {
    r0 = clrbit(r0, #31)
    jumpr r31
  }
FUNCTION_END fabsl
