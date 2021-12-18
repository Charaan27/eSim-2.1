--  X86 disassembler.
--  Copyright (C) 2006 Tristan Gingold
--
--  GHDL is free software; you can redistribute it and/or modify it under
--  the terms of the GNU General Public License as published by the Free
--  Software Foundation; either version 2, or (at your option) any later
--  version.
--
--  GHDL is distributed in the hope that it will be useful, but WITHOUT ANY
--  WARRANTY; without even the implied warranty of MERCHANTABILITY or
--  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
--  for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with GCC; see the file COPYING.  If not, write to the Free
--  Software Foundation, 59 Temple Place - Suite 330, Boston, MA
--  02111-1307, USA.
with System;
with Interfaces; use Interfaces;

package Disa_X86 is
   --  Call-back used to find a relocation symbol.
   type Symbol_Proc_Type is access procedure (Addr : System.Address;
                                              Line : in out String;
                                              Line_Len : in out Natural);

   --  Disassemble instruction at ADDR, and put the result in LINE/LINE_LEN.
   procedure Disassemble_Insn (Addr : System.Address;
                               Pc : Unsigned_32;
                               Line : in out String;
                               Line_Len : out Natural;
                               Insn_Len : out Natural;
                               Proc_Cb : Symbol_Proc_Type);
end Disa_X86;
