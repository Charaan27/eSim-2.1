--  Nodes recognizer for ieee.numeric_std and ieee.numeric_bit.
--  Copyright (C) 2016 Tristan Gingold
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

with Vhdl.Std_Package;
with Std_Names; use Std_Names;
with Vhdl.Ieee.Std_Logic_1164;

package body Vhdl.Ieee.Std_Logic_Unsigned is
   type Arg_Kind is (Arg_Slv, Arg_Int, Arg_Sl);
   type Args_Kind is (Arg_Slv_Slv, Arg_Slv_Int, Arg_Int_Slv,
                      Arg_Slv_Sl, Arg_Sl_Slv);

   type Binary_Pattern_Type is array (Args_Kind) of Iir_Predefined_Functions;

   None_Patterns : constant Binary_Pattern_Type :=
     (others => Iir_Predefined_None);

   Eq_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Eq_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Unsigned_Eq_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Eq_Int_Slv,
      others => Iir_Predefined_None);

   Ne_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Ne_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Unsigned_Ne_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Ne_Int_Slv,
      others => Iir_Predefined_None);

   Lt_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Lt_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Unsigned_Lt_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Lt_Int_Slv,
      others => Iir_Predefined_None);

   Le_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Le_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Unsigned_Le_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Le_Int_Slv,
      others => Iir_Predefined_None);

   Add_Uns_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Int_Slv,
      Arg_Slv_Sl  => Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Slv_Sl,
      Arg_Sl_Slv  => Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Sl_Slv);

   Sub_Uns_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Int_Slv,
      Arg_Slv_Sl  => Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Slv_Sl,
      Arg_Sl_Slv  => Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Sl_Slv);

   Add_Sgn_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Signed_Add_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Signed_Add_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Signed_Add_Int_Slv,
      Arg_Slv_Sl  => Iir_Predefined_Ieee_Std_Logic_Signed_Add_Slv_Sl,
      Arg_Sl_Slv  => Iir_Predefined_Ieee_Std_Logic_Signed_Add_Sl_Slv);

   Sub_Sgn_Patterns : constant Binary_Pattern_Type :=
     (Arg_Slv_Slv => Iir_Predefined_Ieee_Std_Logic_Signed_Sub_Slv_Slv,
      Arg_Slv_Int => Iir_Predefined_Ieee_Std_Logic_Signed_Sub_Slv_Int,
      Arg_Int_Slv => Iir_Predefined_Ieee_Std_Logic_Signed_Sub_Int_Slv,
      Arg_Slv_Sl  => Iir_Predefined_Ieee_Std_Logic_Signed_Sub_Slv_Sl,
      Arg_Sl_Slv  => Iir_Predefined_Ieee_Std_Logic_Signed_Sub_Sl_Slv);

   Error : exception;

   procedure Extract_Declarations
     (Pkg : Iir_Package_Declaration; Sign : Sign_Kind)
   is
      procedure Classify_Arg (Arg : Iir; Kind : out Arg_Kind)
      is
         Arg_Type : constant Iir := Get_Type (Arg);
      begin
         if Arg_Type = Vhdl.Std_Package.Integer_Subtype_Definition then
            Kind := Arg_Int;
         elsif Arg_Type = Ieee.Std_Logic_1164.Std_Logic_Type then
            Kind := Arg_Sl;
         elsif Arg_Type = Ieee.Std_Logic_1164.Std_Logic_Vector_Type then
            Kind := Arg_Slv;
         else
            raise Error;
         end if;
      end Classify_Arg;

      Decl : Iir;

      Arg1, Arg2 : Iir;
      Arg1_Kind, Arg2_Kind : Arg_Kind;

      function Handle_Binary (Unsigned_Pats : Binary_Pattern_Type;
                              Signed_Pats : Binary_Pattern_Type)
                             return Iir_Predefined_Functions
      is
         Kind : Args_Kind;
      begin
         case Arg1_Kind is
            when Arg_Slv =>
               case Arg2_Kind is
                  when Arg_Slv => Kind := Arg_Slv_Slv;
                  when Arg_Sl => Kind := Arg_Slv_Sl;
                  when Arg_Int => Kind := Arg_Slv_Int;
               end case;
            when Arg_Int =>
               case Arg2_Kind is
                  when Arg_Slv => Kind := Arg_Int_Slv;
                  when Arg_Sl
                    | Arg_Int => raise Error;
               end case;
            when Arg_Sl =>
               case Arg2_Kind is
                  when Arg_Slv => Kind := Arg_Sl_Slv;
                  when Arg_Sl
                    | Arg_Int => raise Error;
               end case;
         end case;

         case Sign is
            when Pkg_Unsigned =>
               return Unsigned_Pats (Kind);
            when Pkg_Signed =>
               return Signed_Pats (Kind);
         end case;
      end Handle_Binary;

      Res : Iir_Predefined_Functions;
   begin
      Decl := Get_Declaration_Chain (Pkg);

      --  Handle functions.
      while Is_Valid (Decl) loop
         if Get_Kind (Decl) /= Iir_Kind_Function_Declaration then
            raise Error;
         end if;

         Arg1 := Get_Interface_Declaration_Chain (Decl);
         if Is_Null (Arg1) then
            raise Error;
         end if;

         Res := Iir_Predefined_None;

         Classify_Arg (Arg1, Arg1_Kind);
         Arg2 := Get_Chain (Arg1);
         if Is_Valid (Arg2) then
            --  Dyadic function.
            Classify_Arg (Arg2, Arg2_Kind);

            case Get_Identifier (Decl) is
               when Name_Op_Equality =>
                  Res := Handle_Binary (Eq_Patterns, None_Patterns);
               when Name_Op_Inequality =>
                  Res := Handle_Binary (Ne_Patterns, None_Patterns);
               when Name_Op_Less =>
                  Res := Handle_Binary (Lt_Patterns, None_Patterns);
               when Name_Op_Less_Equal =>
                  Res := Handle_Binary (Le_Patterns, None_Patterns);
               when Name_Op_Plus =>
                  Res := Handle_Binary (Add_Uns_Patterns, Add_Sgn_Patterns);
               when Name_Op_Minus =>
                  Res := Handle_Binary (Sub_Uns_Patterns, Sub_Sgn_Patterns);
               when others =>
                  null;
            end case;
         else
            --  Monadic function.
            case Get_Identifier (Decl) is
               when Name_Conv_Integer =>
                  if Sign = Pkg_Unsigned then
                     Res :=
                       Iir_Predefined_Ieee_Std_Logic_Unsigned_Conv_Integer;
                  end if;
               when others =>
                  null;
            end case;
         end if;
         Set_Implicit_Definition (Decl, Res);
         Decl := Get_Chain (Decl);
      end loop;
   end Extract_Declarations;

end Vhdl.Ieee.Std_Logic_Unsigned;
