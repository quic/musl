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

FUNCTION_BEGIN fminf
  {
    r0 = sfmin(r0, r1)
    jumpr r31
  }
FUNCTION_END fminf
