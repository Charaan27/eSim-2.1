--  Nodes recognizer for ieee.std_logic_arith.
--  Copyright (C) 2019 Tristan Gingold
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
--  along with GHDL; see the file COPYING.  If not, write to the Free
--  Software Foundation, 59 Temple Place - Suite 330, Boston, MA
--  02111-1307, USA.

with Types; use Types;
with Vhdl.Std_Package;
with Std_Names; use Std_Names;
with Vhdl.Errors; use Vhdl.Errors;
with Vhdl.Ieee.Std_Logic_1164;

package body Vhdl.Ieee.Std_Logic_Arith is
   --  Unsigned and signed type definition.
   Unsigned_Type : Iir := Null_Iir;
   Signed_Type : Iir := Null_Iir;

   type Arg_Kind is (Type_Signed, Type_Unsigned, Type_Int, Type_Log, Type_Slv);

   subtype Conv_Arg_Kind is Arg_Kind range Type_Signed .. Type_Log;
   type Conv_Pattern_Type is
     array (Conv_Arg_Kind) of Iir_Predefined_Functions;

   Conv_Uns_Patterns : constant Conv_Pattern_Type :=
     (Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Unsigned_Sgn,
      Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Unsigned_Uns,
      Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Unsigned_Int,
      Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Unsigned_Log);

   Conv_Int_Patterns : constant Conv_Pattern_Type :=
     (Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Integer_Sgn,
      Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Integer_Uns,
      Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Integer_Int,
      Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Integer_Log);

   Error : exception;

   procedure Extract_Declarations (Pkg : Iir_Package_Declaration)
   is
      procedure Classify_Arg (Arg : Iir; Kind : out Arg_Kind)
      is
         Arg_Type : constant Iir := Get_Type (Arg);
      begin
         if Arg_Type = Signed_Type then
            Kind := Type_Signed;
         elsif Arg_Type = Unsigned_Type then
            Kind := Type_Unsigned;
         elsif Arg_Type = Vhdl.Std_Package.Integer_Subtype_Definition then
            Kind := Type_Int;
         elsif Arg_Type = Ieee.Std_Logic_1164.Std_Ulogic_Type then
            Kind := Type_Log;
         elsif Arg_Type = Ieee.Std_Logic_1164.Std_Logic_Vector_Type then
            Kind := Type_Slv;
         else
            raise Error;
         end if;
      end Classify_Arg;

      Decl : Iir;
      Type_Def : Iir;

      Arg1, Arg2 : Iir;
      Arg1_Kind, Arg2_Kind : Arg_Kind;

      function Handle_Conv (Pats : Conv_Pattern_Type)
                           return Iir_Predefined_Functions is
      begin
         if Arg2_Kind /= Type_Int then
            raise Error;
         end if;
         return Pats (Arg1_Kind);
      end Handle_Conv;

      Def : Iir_Predefined_Functions;
   begin
      Decl := Get_Declaration_Chain (Pkg);

      if Decl /= Null_Iir
        and then Get_Kind (Decl) = Iir_Kind_Use_Clause
      then
         --  Mentor version.  Don't extract and don't crash.
         return;
      end if;

      --  The first declaration should be type Unsigned.
      if not (Decl /= Null_Iir
                and then Get_Kind (Decl) = Iir_Kind_Type_Declaration
                and then Get_Identifier (Decl) = Name_Unsigned)
      then
         raise Error;
      end if;

      Type_Def := Get_Type_Definition (Decl);
      if Get_Kind (Type_Def) /= Iir_Kind_Array_Type_Definition then
         raise Error;
      end if;
      Unsigned_Type := Type_Def;

      --  The second declaration should be type Signed.
      Decl := Get_Chain (Decl);
      Decl := Skip_Implicit (Decl);
      if not (Decl /= Null_Iir
                and then Get_Kind (Decl) = Iir_Kind_Type_Declaration
                and then Get_Identifier (Decl) = Name_Signed)
      then
         raise Error;
      end if;

      Type_Def := Get_Type_Definition (Decl);
      if Get_Kind (Type_Def) /= Iir_Kind_Array_Type_Definition then
         raise Error;
      end if;
      Signed_Type := Type_Def;

      --  Skip subtypes
      Decl := Get_Chain (Decl);
      Decl := Skip_Implicit (Decl);
      while Is_Valid (Decl) loop
         exit when Get_Kind (Decl) /= Iir_Kind_Subtype_Declaration;
         Decl := Get_Chain (Decl);
      end loop;

      --  Handle functions.
      while Is_Valid (Decl) loop
         Def := Iir_Predefined_None;

         case Get_Kind (Decl) is
            when Iir_Kind_Function_Declaration =>
               Arg1 := Get_Interface_Declaration_Chain (Decl);
               if Is_Null (Arg1) then
                  raise Error;
               end if;

               Classify_Arg (Arg1, Arg1_Kind);
               Arg2 := Get_Chain (Arg1);
               if Is_Valid (Arg2) then
                  --  Dyadic function.
                  Classify_Arg (Arg2, Arg2_Kind);

                  case Get_Identifier (Decl) is
                     when Name_Conv_Unsigned =>
                        Def := Handle_Conv (Conv_Uns_Patterns);
                     when others =>
                        null;
                  end case;
               else
                  --  Monadic function.
                  case Get_Identifier (Decl) is
                     when Name_Conv_Integer =>
                        Def := Conv_Int_Patterns (Arg1_Kind);
                     when others =>
                        null;
                  end case;
               end if;

            when Iir_Kind_Non_Object_Alias_Declaration
              | Iir_Kind_Procedure_Declaration =>
               null;

            when others =>
               raise Error;
         end case;
         Set_Implicit_Definition (Decl, Def);

         Decl := Get_Chain (Decl);
      end loop;
   exception
      when Error =>
         Error_Msg_Sem (+Pkg, "package ieee.std_logic_arith is ill-formed");
   end Extract_Declarations;
end Vhdl.Ieee.Std_Logic_Arith;
