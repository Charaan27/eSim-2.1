--  Operations synthesis.
--  Copyright (C) 2019 Tristan Gingold
--
--  This file is part of GHDL.
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
--  MA 02110-1301, USA.

with Types; use Types;
with Types_Utils; use Types_Utils;
with Mutils;

with Vhdl.Ieee.Std_Logic_1164; use Vhdl.Ieee.Std_Logic_1164;
with Vhdl.Std_Package;
with Vhdl.Errors; use Vhdl.Errors;
with Vhdl.Utils; use Vhdl.Utils;

with Areapools;

with Netlists; use Netlists;
with Netlists.Gates; use Netlists.Gates;
with Netlists.Builders; use Netlists.Builders;
with Netlists.Folds; use Netlists.Folds;
with Netlists.Utils;

with Synth.Errors; use Synth.Errors;
with Synth.Stmts; use Synth.Stmts;
with Synth.Expr; use Synth.Expr;
with Synth.Source;
with Synth.Static_Oper; use Synth.Static_Oper;

package body Synth.Oper is
   procedure Set_Location (N : Net; Loc : Node)
     renames Synth.Source.Set_Location;

   function Synth_Uresize (N : Net; W : Width; Loc : Node) return Net is
   begin
      return Build2_Uresize (Build_Context, N, W, Get_Location (Loc));
   end Synth_Uresize;

   function Synth_Uresize (Val : Value_Acc; W : Width; Loc : Node) return Net
   is
      Res : Net;
   begin
      if Is_Static (Val) and then Val.Typ.Kind = Type_Discrete then
         if Val.Typ.Drange.Is_Signed and then Val.Scal < 0 then
            --  TODO.
            raise Internal_Error;
         else
            Res := Build2_Const_Uns (Build_Context, To_Uns64 (Val.Scal), W);
         end if;
         Set_Location (Res, Loc);
         return Res;
      end if;
      return Synth_Uresize (Get_Net (Val), W, Loc);
   end Synth_Uresize;

   function Synth_Sresize (Val : Value_Acc; W : Width; Loc : Node) return Net
   is
      Res : Net;
   begin
      if Is_Static (Val) and then Val.Typ.Kind = Type_Discrete then
         if Val.Typ.Drange.Is_Signed then
            Res := Build2_Const_Int (Build_Context, Val.Scal, W);
         else
            --  TODO.
            raise Internal_Error;
         end if;
         Set_Location (Res, Loc);
         return Res;
      end if;
      return Build2_Sresize (Build_Context, Get_Net (Val), W,
                             Get_Location (Loc));
   end Synth_Sresize;

   function Synth_Bit_Eq_Const (Cst : Value_Acc; Expr : Value_Acc; Loc : Node)
                               return Value_Acc
   is
      Val : Uns32;
      Zx : Uns32;
      N : Net;
   begin
      if Is_Static (Expr) then
         return Create_Value_Discrete (Boolean'Pos (Cst.Scal = Expr.Scal),
                                       Boolean_Type);
      end if;

      To_Logic (Cst.Scal, Cst.Typ, Val, Zx);
      if Zx /= 0 then
         --  Equal unknown -> return X
         N := Build_Const_UL32 (Build_Context, 0, 1, 1);
         Set_Location (N, Loc);
         return Create_Value_Net (N, Boolean_Type);
      elsif Val = 1 then
         --  The result type is a boolean; convert if needed.
         if Expr.Typ.Kind = Type_Logic then
            return Create_Value_Net (Get_Net (Expr), Boolean_Type);
         else
            pragma Assert (Expr.Typ.Kind = Type_Bit);
            return Expr;
         end if;
      else
         pragma Assert (Val = 0);
         N := Build_Monadic (Build_Context, Id_Not, Get_Net (Expr));
         Set_Location (N, Loc);
         return Create_Value_Net (N, Boolean_Type);
      end if;
   end Synth_Bit_Eq_Const;

   --  Create the result range of an operator.  According to the ieee standard,
   --  the range is LEN-1 downto 0.
   function Create_Res_Bound (Prev : Value_Acc) return Type_Acc
   is
      Res : Type_Acc;
   begin
      Res := Prev.Typ;

      if Res.Vbound.Dir = Iir_Downto
        and then Res.Vbound.Right = 0
      then
         --  Normalized range
         return Res;
      end if;

      return Create_Vec_Type_By_Length (Res.W, Res.Vec_El);
   end Create_Res_Bound;

   function Create_Bounds_From_Length
     (Syn_Inst : Synth_Instance_Acc; Atype : Iir; Len : Iir_Index32)
     return Bound_Type
   is
      Res : Bound_Type;
      Index_Bounds : Discrete_Range_Type;
   begin
      Synth_Discrete_Range (Syn_Inst, Atype, Index_Bounds);

      Res := (Left => Int32 (Index_Bounds.Left),
              Right => 0,
              Dir => Index_Bounds.Dir,
              Len => Uns32 (Len));

      if Len = 0 then
         --  Special case.
         Res.Right := Res.Left;
         case Index_Bounds.Dir is
            when Iir_To =>
               Res.Left := Res.Right + 1;
            when Iir_Downto =>
               Res.Left := Res.Right - 1;
         end case;
      else
         case Index_Bounds.Dir is
            when Iir_To =>
               Res.Right := Res.Left + Int32 (Len - 1);
            when Iir_Downto =>
               Res.Right := Res.Left - Int32 (Len - 1);
         end case;
      end if;
      return Res;
   end Create_Bounds_From_Length;

   function Synth_Dyadic_Operation (Syn_Inst : Synth_Instance_Acc;
                                    Imp : Node;
                                    Left_Expr : Node;
                                    Right_Expr : Node;
                                    Expr : Node) return Value_Acc
   is
      Ctxt : constant Context_Acc := Get_Build (Syn_Inst);
      Def : constant Iir_Predefined_Functions :=
        Get_Implicit_Definition (Imp);
      Inter_Chain : constant Node :=
        Get_Interface_Declaration_Chain (Imp);
      Expr_Type : constant Node := Get_Type (Expr);
      Left_Type : constant Node := Get_Type (Inter_Chain);
      Right_Type : constant Node := Get_Type (Get_Chain (Inter_Chain));
      Left_Typ : constant Type_Acc := Get_Value_Type (Syn_Inst, Left_Type);
      Right_Typ : constant Type_Acc := Get_Value_Type (Syn_Inst, Right_Type);
      Expr_Typ : constant Type_Acc := Get_Value_Type (Syn_Inst, Expr_Type);
      Left : Value_Acc;
      Right : Value_Acc;

      function Synth_Bit_Dyadic (Id : Dyadic_Module_Id) return Value_Acc
      is
         N : Net;
      begin
         N := Build_Dyadic (Build_Context, Id,
                            Get_Net (Left), Get_Net (Right));
         Set_Location (N, Expr);
         return Create_Value_Net (N, Left.Typ);
      end Synth_Bit_Dyadic;

      function Synth_Compare (Id : Compare_Module_Id; Res_Type : Type_Acc)
                             return Value_Acc
      is
         N : Net;
      begin
         pragma Assert (Left_Type = Right_Type);
         N := Build_Compare
           (Build_Context, Id, Get_Net (Left), Get_Net (Right));
         Set_Location (N, Expr);
         return Create_Value_Net (N, Res_Type);
      end Synth_Compare;

      function Synth_Compare_Array (Id, Id_Eq : Compare_Module_Id;
                                    Res_Type : Type_Acc) return Value_Acc
      is
         pragma Unreferenced (Id_Eq);
         N : Net;
      begin
         if Left.Typ.Kind = Type_Vector then
            Warning_Msg_Synth
              (+Expr, "comparing non-numeric vector is unexpected");
            if Left.Typ.W = Right.Typ.W then
               N := Build_Compare
                 (Get_Build (Syn_Inst), Id, Get_Net (Left), Get_Net (Right));
               Set_Location (N, Expr);
               return Create_Value_Net (N, Res_Type);
            elsif Left.Typ.W < Right.Typ.W then
               --  TODO: truncate right, compare using id_eq.
               raise Internal_Error;
            else
               --  TODO: truncate left, compare using id.
               raise Internal_Error;
            end if;
         else
            raise Internal_Error;
         end if;
      end Synth_Compare_Array;

      function Synth_Compare_Uns_Nat
        (Id : Compare_Module_Id; Res_Type : Type_Acc) return Value_Acc
      is
         N : Net;
      begin
         N := Synth_Uresize (Right, Left.Typ.W, Expr);
         N := Build_Compare (Build_Context, Id, Get_Net (Left), N);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Res_Type);
      end Synth_Compare_Uns_Nat;

      function Synth_Compare_Nat_Uns
        (Id : Compare_Module_Id; Res_Type : Type_Acc) return Value_Acc
      is
         N : Net;
      begin
         N := Synth_Uresize (Left, Right.Typ.W, Expr);
         N := Build_Compare (Build_Context, Id, Get_Net (Right), N);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Res_Type);
      end Synth_Compare_Nat_Uns;

      function Synth_Compare_Sgn_Int
        (Id : Compare_Module_Id; Res_Typ : Type_Acc) return Value_Acc
      is
         N : Net;
      begin
         N := Synth_Sresize (Right, Left.Typ.W, Expr);
         N := Build_Compare (Build_Context, Id, Get_Net (Left), N);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Res_Typ);
      end Synth_Compare_Sgn_Int;

      function Synth_Compare_Int_Sgn
        (Id : Compare_Module_Id; Res_Typ : Type_Acc) return Value_Acc
      is
         N : Net;
      begin
         N := Synth_Sresize (Left, Right.Typ.W, Expr);
         N := Build_Compare (Build_Context, Id, N, Get_Net (Right));
         Set_Location (N, Expr);
         return Create_Value_Net (N, Res_Typ);
      end Synth_Compare_Int_Sgn;

      function Synth_Vec_Dyadic (Id : Dyadic_Module_Id) return Value_Acc
      is
         N : Net;
      begin
         --  FIXME: check same length.
         N := Build_Dyadic (Build_Context, Id,
                            Get_Net (Left), Get_Net (Right));
         Set_Location (N, Expr);
         return Create_Value_Net (N, Create_Res_Bound (Left));
      end Synth_Vec_Dyadic;

      function Synth_Int_Dyadic (Id : Dyadic_Module_Id) return Value_Acc
      is
         Etype : constant Type_Acc := Get_Value_Type (Syn_Inst, Expr_Type);
         N : Net;
      begin
         N := Build_Dyadic
           (Build_Context, Id, Get_Net (Left), Get_Net (Right));
         Set_Location (N, Expr);
         return Create_Value_Net (N, Etype);
      end Synth_Int_Dyadic;

      function Synth_Dyadic_Uns (Id : Dyadic_Module_Id; Is_Res_Vec : Boolean)
                                return Value_Acc
      is
         W : constant Width := Width'Max (Left.Typ.W, Right.Typ.W);
         Rtype : Type_Acc;
         L1, R1 : Net;
         N : Net;
      begin
         if Is_Res_Vec then
            Rtype := Create_Vec_Type_By_Length (W, Left.Typ.Vec_El);
         else
            Rtype := Left.Typ;
         end if;
         L1 := Synth_Uresize (Left, W, Expr);
         R1 := Synth_Uresize (Right, W, Expr);
         N := Build_Dyadic (Build_Context, Id, L1, R1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Rtype);
      end Synth_Dyadic_Uns;

      function Synth_Dyadic_Sgn (Id : Dyadic_Module_Id; Is_Res_Vec : Boolean)
                                return Value_Acc
      is
         W : constant Width := Width'Max (Left.Typ.W, Right.Typ.W);
         Rtype : Type_Acc;
         L1, R1 : Net;
         N : Net;
      begin
         Rtype := Left.Typ;
         if Rtype.Kind = Type_Vector then
            Rtype := Rtype.Vec_El;
         end if;

         if Is_Res_Vec then
            Rtype := Create_Vec_Type_By_Length (W, Rtype);
         end if;
         L1 := Synth_Sresize (Left, W, Expr);
         R1 := Synth_Sresize (Right, W, Expr);
         N := Build_Dyadic (Build_Context, Id, L1, R1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Rtype);
      end Synth_Dyadic_Sgn;

      function Synth_Compare_Uns_Uns
        (Id : Compare_Module_Id; Res_Type : Type_Acc) return Value_Acc
      is
         W : constant Width := Width'Max (Left.Typ.W, Right.Typ.W);
         L1, R1 : Net;
         N : Net;
      begin
         L1 := Synth_Uresize (Left, W, Expr);
         R1 := Synth_Uresize (Right, W, Expr);
         N := Build_Compare (Build_Context, Id, L1, R1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Res_Type);
      end Synth_Compare_Uns_Uns;

      function Synth_Dyadic_Uns_Nat (Id : Dyadic_Module_Id) return Value_Acc
      is
         L : constant Net := Get_Net (Left);
         R1 : Net;
         N : Net;
      begin
         R1 := Synth_Uresize (Right, Left.Typ.W, Expr);
         N := Build_Dyadic (Build_Context, Id, L, R1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Create_Res_Bound (Left));
      end Synth_Dyadic_Uns_Nat;

      function Synth_Dyadic_Nat_Uns (Id : Dyadic_Module_Id) return Value_Acc
      is
         R : constant Net := Get_Net (Right);
         L1 : Net;
         N : Net;
      begin
         L1 := Synth_Uresize (Left, Right.Typ.W, Expr);
         N := Build_Dyadic (Build_Context, Id, L1, R);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Create_Res_Bound (Right));
      end Synth_Dyadic_Nat_Uns;

      function Synth_Dyadic_Sgn_Int (Id : Dyadic_Module_Id) return Value_Acc
      is
         L : constant Net := Get_Net (Left);
         R1 : Net;
         N : Net;
      begin
         R1 := Synth_Sresize (Right, Left.Typ.W, Expr);
         N := Build_Dyadic (Build_Context, Id, L, R1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Create_Res_Bound (Left));
      end Synth_Dyadic_Sgn_Int;

      function Synth_Dyadic_Int_Sgn (Id : Dyadic_Module_Id) return Value_Acc
      is
         R : constant Net := Get_Net (Right);
         L1 : Net;
         N : Net;
      begin
         L1 := Synth_Sresize (Left, Right.Typ.W, Expr);
         N := Build_Dyadic (Build_Context, Id, R, L1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Create_Res_Bound (Right));
      end Synth_Dyadic_Int_Sgn;

      function Synth_Compare_Sgn_Sgn
        (Id : Compare_Module_Id; Res_Typ : Type_Acc) return Value_Acc
      is
         W : constant Width := Width'Max (Left.Typ.W, Right.Typ.W);
         L1, R1 : Net;
         N : Net;
      begin
         L1 := Synth_Sresize (Left, W, Expr);
         R1 := Synth_Sresize (Right, W, Expr);
         N := Build_Compare (Build_Context, Id, L1, R1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Res_Typ);
      end Synth_Compare_Sgn_Sgn;

      function Synth_Shift (Id_Pos : Module_Id; Id_Neg : Module_Id)
                           return Value_Acc
      is
         pragma Unreferenced (Id_Neg);
         L1, R1 : Net;
         N : Net;
         Is_Pos : Boolean;
      begin
         Is_Pos := Is_Positive (Right);

         L1 := Get_Net (Left);
         R1 := Get_Net (Right);
         if Is_Pos then
            N := Build_Shift_Rotate (Ctxt, Id_Pos, L1, R1);
         else
            raise Internal_Error;
         end if;
         Set_Location (N, Expr);
         return Create_Value_Net (N, Create_Res_Bound (Left));
      end Synth_Shift;

      function Synth_Rotation (Id : Module_Id) return Value_Acc
      is
         Amt : Int64;
         Ww : Width;
         L1, R1 : Net;
         N : Net;
      begin
         if Is_Static_Val (Right) then
            Amt := Get_Static_Discrete (Right);
            if Amt < 0 then
               raise Internal_Error;
            end if;
            Amt := Amt mod Int64 (Left.Typ.W);
            R1 := Build_Const_UB32 (Ctxt, Uns32 (Amt), Right.Typ.W);
            Set_Location (R1, Right_Expr);
         elsif not Is_Positive (Right) then
            Error_Msg_Synth (+Expr, "rotation quantity must be unsigned");
            return Left;
         else
            R1 := Get_Net (Right);
            Ww := Netlists.Utils.Clog2 (Left.Typ.W);
            if Right.Typ.W >= Ww then
               if Mutils.Is_Power2 (Uns64 (Left.Typ.W)) then
                  R1 := Build2_Trunc (Ctxt, Id_Utrunc, R1, Ww, +Expr);
               else
                  Error_Msg_Synth
                    (+Expr, "vector length of rotation must be a power of 2");
                  return Left;
               end if;
            end if;
         end if;
         L1 := Get_Net (Left);
         N := Build_Shift_Rotate (Ctxt, Id, L1, R1);
         Set_Location (N, Expr);
         return Create_Value_Net (N, Create_Res_Bound (Left));
      end Synth_Rotation;
   begin
      Left := Synth_Expression_With_Type (Syn_Inst, Left_Expr, Left_Typ);
      Left := Synth_Subtype_Conversion (Left, Left_Typ, False, Expr);
      Strip_Const (Left);
      Right := Synth_Expression_With_Type (Syn_Inst, Right_Expr, Right_Typ);
      Right := Synth_Subtype_Conversion (Right, Right_Typ, False, Expr);
      Strip_Const (Right);

      if Is_Static_Val (Left) and Is_Static_Val (Right) then
         return Synth_Static_Dyadic_Predefined
           (Syn_Inst, Imp, Left, Right, Expr);
      end if;

      case Def is
         when Iir_Predefined_Error =>
            return null;

         when Iir_Predefined_Bit_And
           | Iir_Predefined_Boolean_And
           | Iir_Predefined_Ieee_1164_Scalar_And =>
            return Synth_Bit_Dyadic (Id_And);
         when Iir_Predefined_Bit_Xor
           | Iir_Predefined_Ieee_1164_Scalar_Xor =>
            return Synth_Bit_Dyadic (Id_Xor);
         when Iir_Predefined_Bit_Or
           | Iir_Predefined_Boolean_Or
           | Iir_Predefined_Ieee_1164_Scalar_Or =>
            return Synth_Bit_Dyadic (Id_Or);
         when Iir_Predefined_Bit_Nor
           | Iir_Predefined_Ieee_1164_Scalar_Nor =>
            return Synth_Bit_Dyadic (Id_Nor);
         when Iir_Predefined_Bit_Nand
           | Iir_Predefined_Boolean_Nand
           | Iir_Predefined_Ieee_1164_Scalar_Nand =>
            return Synth_Bit_Dyadic (Id_Nand);
         when Iir_Predefined_Bit_Xnor
           | Iir_Predefined_Ieee_1164_Scalar_Xnor =>
            return Synth_Bit_Dyadic (Id_Xnor);

         when Iir_Predefined_Ieee_1164_Vector_And
            | Iir_Predefined_Ieee_Numeric_Std_And_Uns_Uns
            | Iir_Predefined_Ieee_Numeric_Std_And_Sgn_Sgn =>
            return Synth_Vec_Dyadic (Id_And);
         when Iir_Predefined_Ieee_1164_Vector_Or
            | Iir_Predefined_Ieee_Numeric_Std_Or_Uns_Uns
            | Iir_Predefined_Ieee_Numeric_Std_Or_Sgn_Sgn =>
            return Synth_Vec_Dyadic (Id_Or);
         when Iir_Predefined_Ieee_1164_Vector_Nand
            | Iir_Predefined_Ieee_Numeric_Std_Nand_Uns_Uns
            | Iir_Predefined_Ieee_Numeric_Std_Nand_Sgn_Sgn =>
            return Synth_Vec_Dyadic (Id_Nand);
         when Iir_Predefined_Ieee_1164_Vector_Nor
            | Iir_Predefined_Ieee_Numeric_Std_Nor_Uns_Uns
            | Iir_Predefined_Ieee_Numeric_Std_Nor_Sgn_Sgn =>
            return Synth_Vec_Dyadic (Id_Nor);
         when Iir_Predefined_TF_Array_Xor
           | Iir_Predefined_Ieee_1164_Vector_Xor
           | Iir_Predefined_Ieee_Numeric_Std_Xor_Uns_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Xor_Sgn_Sgn =>
            return Synth_Vec_Dyadic (Id_Xor);
         when Iir_Predefined_Ieee_1164_Vector_Xnor
            | Iir_Predefined_Ieee_Numeric_Std_Xnor_Uns_Uns
            | Iir_Predefined_Ieee_Numeric_Std_Xnor_Sgn_Sgn =>
            return Synth_Vec_Dyadic (Id_Xnor);

         when Iir_Predefined_Enum_Equality =>
            if Left_Typ = Bit_Type
              or else Left_Typ = Logic_Type
            then
               if Is_Static (Left) then
                  return Synth_Bit_Eq_Const (Left, Right, Expr);
               elsif Is_Static (Right) then
                  return Synth_Bit_Eq_Const (Right, Left, Expr);
               end if;
            end if;
            return Synth_Compare (Id_Eq, Boolean_Type);
         when Iir_Predefined_Enum_Inequality =>
            --  TODO: Optimize ?
            return Synth_Compare (Id_Ne, Boolean_Type);
         when Iir_Predefined_Enum_Less_Equal =>
            return Synth_Compare (Id_Ult, Boolean_Type);

         when Iir_Predefined_Std_Ulogic_Match_Equality =>
            return Synth_Compare (Id_Eq, Logic_Type);
         when Iir_Predefined_Std_Ulogic_Match_Inequality =>
            return Synth_Compare (Id_Ne, Logic_Type);
         when Iir_Predefined_Std_Ulogic_Match_Less =>
            return Synth_Compare (Id_Ult, Logic_Type);
         when Iir_Predefined_Std_Ulogic_Match_Less_Equal =>
            return Synth_Compare (Id_Ule, Logic_Type);
         when Iir_Predefined_Std_Ulogic_Match_Greater =>
            return Synth_Compare (Id_Ugt, Logic_Type);
         when Iir_Predefined_Std_Ulogic_Match_Greater_Equal =>
            return Synth_Compare (Id_Uge, Logic_Type);

         when Iir_Predefined_Array_Equality
           | Iir_Predefined_Record_Equality =>
            if not Is_Matching_Bounds (Left.Typ, Right.Typ) then
               Warning_Msg_Synth
                 (+Expr,
                  "length of '=' operands doesn't match, result is false");
               return Create_Value_Discrete (0, Boolean_Type);
            end if;
            return Synth_Compare (Id_Eq, Boolean_Type);
         when Iir_Predefined_Std_Ulogic_Array_Match_Equality =>
            if not Is_Matching_Bounds (Left.Typ, Right.Typ) then
               Warning_Msg_Synth
                 (+Expr,
                  "length of '?=' operands doesn't match, result is '0'");
               return Create_Value_Discrete (0, Logic_Type);
            end if;
            return Synth_Compare (Id_Eq, Logic_Type);
         when Iir_Predefined_Array_Inequality
            | Iir_Predefined_Record_Inequality =>
            if not Is_Matching_Bounds (Left.Typ, Right.Typ) then
               Warning_Msg_Synth
                 (+Expr,
                  "length of '/=' operands doesn't match, result is true");
               return Create_Value_Discrete (1, Boolean_Type);
            end if;
            return Synth_Compare (Id_Ne, Boolean_Type);
         when Iir_Predefined_Std_Ulogic_Array_Match_Inequality =>
            if not Is_Matching_Bounds (Left.Typ, Right.Typ) then
               Warning_Msg_Synth
                 (+Expr,
                  "length of '/=' operands doesn't match, result is '1'");
               return Create_Value_Discrete (1, Logic_Type);
            end if;
            return Synth_Compare (Id_Ne, Logic_Type);
         when Iir_Predefined_Array_Greater =>
            return Synth_Compare_Array (Id_Ugt, Id_Uge, Boolean_Type);
         when Iir_Predefined_Array_Less =>
            return Synth_Compare_Array (Id_Ult, Id_Ule, Boolean_Type);

         when Iir_Predefined_Ieee_Numeric_Std_Add_Uns_Nat
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Slv_Int =>
            --  "+" (Unsigned, Natural)
            return Synth_Dyadic_Uns_Nat (Id_Add);
         when Iir_Predefined_Ieee_Numeric_Std_Add_Nat_Uns =>
            --  "+" (Natural, Unsigned)
            return Synth_Dyadic_Nat_Uns (Id_Add);
         when Iir_Predefined_Ieee_Numeric_Std_Add_Uns_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Add_Uns_Log
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Slv_Sl
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Add_Slv_Slv =>
            --  "+" (Unsigned, Unsigned)
            return Synth_Dyadic_Uns (Id_Add, True);
         when Iir_Predefined_Ieee_Numeric_Std_Add_Sgn_Int =>
            --  "+" (Signed, Integer)
            return Synth_Dyadic_Sgn_Int (Id_Add);
         when Iir_Predefined_Ieee_Numeric_Std_Add_Int_Sgn =>
            --  "+" (Integer, Signed)
            return Synth_Dyadic_Int_Sgn (Id_Add);
         when Iir_Predefined_Ieee_Numeric_Std_Add_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Add_Sgn_Log
           | Iir_Predefined_Ieee_Numeric_Std_Add_Log_Sgn =>
            --  "+" (Signed, Signed)
            return Synth_Dyadic_Sgn (Id_Add, True);

         when Iir_Predefined_Ieee_Numeric_Std_Sub_Uns_Nat
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Slv_Int =>
            --  "-" (Unsigned, Natural)
            return Synth_Dyadic_Uns_Nat (Id_Sub);
         when Iir_Predefined_Ieee_Numeric_Std_Sub_Uns_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Slv_Slv
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Sub_Slv_Sl =>
            --  "-" (Unsigned, Unsigned)
            return Synth_Dyadic_Uns (Id_Sub, True);
         when Iir_Predefined_Ieee_Numeric_Std_Sub_Sgn_Int
           | Iir_Predefined_Ieee_Std_Logic_Signed_Sub_Slv_Int =>
            --  "-" (Signed, Integer)
            return Synth_Dyadic_Sgn_Int (Id_Sub);
         when Iir_Predefined_Ieee_Numeric_Std_Sub_Int_Sgn =>
            --  "-" (Integer, Signed)
            return Synth_Dyadic_Int_Sgn (Id_Sub);
         when Iir_Predefined_Ieee_Numeric_Std_Sub_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Sub_Sgn_Log
           | Iir_Predefined_Ieee_Numeric_Std_Sub_Log_Sgn =>
            --  "-" (Signed, Signed)
            return Synth_Dyadic_Sgn (Id_Sub, True);

         when Iir_Predefined_Ieee_Numeric_Std_Mul_Sgn_Sgn =>
            declare
               W : constant Width := Left.Typ.W + Right.Typ.W;
               L, R : Net;
               N : Net;
            begin
               L := Synth_Sresize (Left, W, Left_Expr);
               R := Synth_Sresize (Right, W, Right_Expr);
               N := Build_Dyadic (Build_Context, Id_Smul, L, R);
               Set_Location (N, Expr);
               return Create_Value_Net
                 (N, Create_Vec_Type_By_Length (W, Left.Typ.Vec_El));
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Mul_Uns_Uns =>
            declare
               W : constant Width := Left.Typ.W + Right.Typ.W;
               L, R : Net;
               N : Net;
            begin
               L := Synth_Uresize (Left, W, Left_Expr);
               R := Synth_Uresize (Right, W, Right_Expr);
               N := Build_Dyadic (Build_Context, Id_Umul, L, R);
               Set_Location (N, Expr);
               return Create_Value_Net
                 (N, Create_Vec_Type_By_Length (W, Left.Typ.Vec_El));
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Mul_Uns_Nat =>
            declare
               Lw : constant Width := Left.Typ.W;
               W : constant Width := 2 * Lw;
               L1, R1 : Net;
               Rtype : Type_Acc;
               N : Net;
            begin
               L1 := Synth_Uresize (Left, W, Expr);
               R1 := Synth_Uresize (Right, W, Expr);
               Rtype := Create_Vec_Type_By_Length (W, Left.Typ.Vec_El);
               N := Build_Dyadic (Ctxt, Id_Umul, L1, R1);
               Set_Location (N, Expr);
               return Create_Value_Net (N, Rtype);
            end;

         when Iir_Predefined_Ieee_Numeric_Std_Div_Uns_Nat =>
            declare
               Lw : constant Width := Left.Typ.W;
               W : constant Width := Width'Max (Lw, Right.Typ.W);
               L1, R1 : Net;
               Rtype : Type_Acc;
               N : Net;
            begin
               L1 := Synth_Uresize (Left, W, Expr);
               R1 := Synth_Uresize (Right, W, Expr);
               Rtype := Create_Vec_Type_By_Length (Lw, Left.Typ.Vec_El);
               N := Build_Dyadic (Ctxt, Id_Udiv, L1, R1);
               Set_Location (N, Expr);
               N := Build2_Uresize (Ctxt, N, Lw, Get_Location (Expr));
               return Create_Value_Net (N, Rtype);
            end;

         when Iir_Predefined_Ieee_Numeric_Std_Div_Sgn_Int =>
            declare
               Lw : constant Width := Left.Typ.W;
               W : constant Width := Width'Max (Lw, Right.Typ.W);
               L1, R1 : Net;
               Rtype : Type_Acc;
               N : Net;
            begin
               L1 := Synth_Sresize (Left, W, Expr);
               R1 := Synth_Sresize (Right, W, Expr);
               Rtype := Create_Vec_Type_By_Length (Lw, Left.Typ.Vec_El);
               N := Build_Dyadic (Build_Context, Id_Udiv, L1, R1);
               Set_Location (N, Expr);
               N := Build2_Sresize (Ctxt, N, Lw, Get_Location (Expr));
               return Create_Value_Net (N, Rtype);
            end;

         when Iir_Predefined_Ieee_Numeric_Std_Eq_Uns_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Eq_Slv_Slv
           | Iir_Predefined_Ieee_Numeric_Std_Match_Eq_Uns_Uns =>
            --  "=" (Unsigned, Unsigned) [resize]
            return Synth_Compare_Uns_Uns (Id_Eq, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Eq_Uns_Nat
           | Iir_Predefined_Ieee_Numeric_Std_Match_Eq_Uns_Nat =>
            --  "=" (Unsigned, Natural)
            return Synth_Compare_Uns_Nat (Id_Eq, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Eq_Nat_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Match_Eq_Nat_Uns =>
            --  "=" (Natural, Unsigned) [resize]
            return Synth_Compare_Nat_Uns (Id_Eq, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Eq_Sgn_Int
           | Iir_Predefined_Ieee_Numeric_Std_Match_Eq_Sgn_Int =>
            --  "=" (Signed, Integer)
            return Synth_Compare_Sgn_Int (Id_Eq, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Eq_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Eq_Sgn_Sgn =>
            --  "=" (Signed, Signed) [resize]
            return Synth_Compare_Sgn_Sgn (Id_Eq, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Eq_Int_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Eq_Int_Sgn =>
            --  "=" (Integer, Signed)
            return Synth_Compare_Int_Sgn (Id_Eq, Expr_Typ);

         when Iir_Predefined_Ieee_Numeric_Std_Ne_Uns_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Ne_Slv_Slv
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ne_Uns_Uns =>
            --  "/=" (Unsigned, Unsigned) [resize]
            return Synth_Compare_Uns_Uns (Id_Ne, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ne_Uns_Nat
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ne_Uns_Nat =>
            --  "/=" (Unsigned, Natural)
            return Synth_Compare_Uns_Nat (Id_Ne, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ne_Nat_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ne_Nat_Uns =>
            --  "/=" (Natural, Unsigned) [resize]
            return Synth_Compare_Nat_Uns (Id_Ne, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ne_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ne_Sgn_Sgn =>
            --  "/=" (Signed, Signed) [resize]
            return Synth_Compare_Sgn_Sgn (Id_Ne, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ne_Sgn_Int
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ne_Sgn_Int =>
            --  "/=" (Signed, Integer)
            return Synth_Compare_Sgn_Int (Id_Ne, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ne_Int_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ne_Int_Sgn =>
            --  "/=" (Integer, Signed)
            return Synth_Compare_Int_Sgn (Id_Ne, Expr_Typ);

         when Iir_Predefined_Ieee_Numeric_Std_Lt_Uns_Nat
           | Iir_Predefined_Ieee_Numeric_Std_Match_Lt_Uns_Nat =>
            --  "<" (Unsigned, Natural)
            if Is_Static (Right) and then Right.Scal = 0 then
               --  Always false.
               return Create_Value_Discrete (0, Expr_Typ);
            end if;
            return Synth_Compare_Uns_Nat (Id_Ult, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Lt_Uns_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Lt_Slv_Slv
           | Iir_Predefined_Ieee_Numeric_Std_Match_Lt_Uns_Uns =>
            --  "<" (Unsigned, Unsigned) [resize]
            return Synth_Compare_Uns_Uns (Id_Ult, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Lt_Nat_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Match_Lt_Nat_Uns =>
            --  "<" (Natural, Unsigned) [resize]
            return Synth_Compare_Nat_Uns (Id_Ult, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Lt_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Lt_Sgn_Sgn =>
            --  "<" (Signed, Signed) [resize]
            return Synth_Compare_Sgn_Sgn (Id_Slt, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Lt_Sgn_Int
           | Iir_Predefined_Ieee_Numeric_Std_Match_Lt_Sgn_Int =>
            --  "<" (Signed, Integer)
            return Synth_Compare_Sgn_Int (Id_Slt, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Lt_Int_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Lt_Int_Sgn =>
            --  "<" (Integer, Signed)
            return Synth_Compare_Int_Sgn (Id_Slt, Expr_Typ);

         when Iir_Predefined_Ieee_Numeric_Std_Le_Uns_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Le_Slv_Slv
           | Iir_Predefined_Ieee_Numeric_Std_Match_Le_Uns_Uns =>
            --  "<=" (Unsigned, Unsigned) [resize]
            return Synth_Compare_Uns_Uns (Id_Ule, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Le_Uns_Nat
           | Iir_Predefined_Ieee_Numeric_Std_Match_Le_Uns_Nat =>
            --  "<=" (Unsigned, Natural)
            return Synth_Compare_Uns_Nat (Id_Ule, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Le_Nat_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Match_Le_Nat_Uns =>
            --  "<=" (Natural, Unsigned) [resize]
            return Synth_Compare_Nat_Uns (Id_Ule, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Le_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Le_Sgn_Sgn =>
            --  "<=" (Signed, Signed)
            return Synth_Compare_Sgn_Sgn (Id_Sle, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Le_Sgn_Int
           | Iir_Predefined_Ieee_Numeric_Std_Match_Le_Sgn_Int =>
            --  "<=" (Signed, Integer)
            return Synth_Compare_Sgn_Int (Id_Sle, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Le_Int_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Le_Int_Sgn =>
            --  "<=" (Integer, Signed)
            return Synth_Compare_Int_Sgn (Id_Sle, Expr_Typ);

         when Iir_Predefined_Ieee_Numeric_Std_Gt_Uns_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Gt_Slv_Slv
           | Iir_Predefined_Ieee_Numeric_Std_Match_Gt_Uns_Uns =>
            --  ">" (Unsigned, Unsigned) [resize]
            return Synth_Compare_Uns_Uns (Id_Ugt, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Gt_Uns_Nat
           | Iir_Predefined_Ieee_Numeric_Std_Match_Gt_Uns_Nat =>
            --  ">" (Unsigned, Natural)
            return Synth_Compare_Uns_Nat (Id_Ugt, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Gt_Nat_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Match_Gt_Nat_Uns =>
            --  ">" (Natural, Unsigned) [resize]
            return Synth_Compare_Nat_Uns (Id_Ugt, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Gt_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Gt_Sgn_Sgn =>
            --  ">" (Signed, Signed) [resize]
            return Synth_Compare_Sgn_Sgn (Id_Sgt, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Gt_Sgn_Int
           | Iir_Predefined_Ieee_Numeric_Std_Match_Gt_Sgn_Int =>
            --  ">" (Signed, Integer)
            return Synth_Compare_Sgn_Int (Id_Sgt, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Gt_Int_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Gt_Int_Sgn =>
            --  ">" (Integer, Signed)
            return Synth_Compare_Int_Sgn (Id_Sgt, Expr_Typ);

         when Iir_Predefined_Ieee_Numeric_Std_Ge_Uns_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Ge_Slv_Slv
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ge_Uns_Uns =>
            --  ">=" (Unsigned, Unsigned) [resize]
            return Synth_Compare_Uns_Uns (Id_Uge, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ge_Nat_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ge_Nat_Uns =>
            --  ">=" (Natural, Unsigned) [resize]
            return Synth_Compare_Nat_Uns (Id_Uge, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ge_Uns_Nat
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ge_Uns_Nat =>
            --  ">=" (Unsigned, Natural)
            return Synth_Compare_Uns_Nat (Id_Uge, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ge_Sgn_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ge_Sgn_Sgn =>
            --  ">=" (Signed, Signed) [resize]
            return Synth_Compare_Sgn_Sgn (Id_Sge, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ge_Sgn_Int
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ge_Sgn_Int =>
            --  ">=" (Signed, Integer)
            return Synth_Compare_Sgn_Int (Id_Sge, Expr_Typ);
         when Iir_Predefined_Ieee_Numeric_Std_Ge_Int_Sgn
           | Iir_Predefined_Ieee_Numeric_Std_Match_Ge_Int_Sgn =>
            --  ">=" (Integer, Signed)
            return Synth_Compare_Int_Sgn (Id_Sge, Expr_Typ);

         when Iir_Predefined_Array_Element_Concat =>
            declare
               L : constant Net := Get_Net (Left);
               Bnd : Bound_Type;
               N : Net;
            begin
               N := Build_Concat2 (Build_Context, L, Get_Net (Right));
               Set_Location (N, Expr);
               Bnd := Create_Bounds_From_Length
                 (Syn_Inst,
                  Get_Index_Type (Get_Type (Expr), 0),
                  Iir_Index32 (Get_Width (L) + 1));

               return Create_Value_Net
                 (N, Create_Onedimensional_Array_Subtype (Left_Typ, Bnd));
            end;
         when Iir_Predefined_Element_Array_Concat =>
            declare
               R : constant Net := Get_Net (Right);
               Bnd : Bound_Type;
               N : Net;
            begin
               N := Build_Concat2 (Build_Context, Get_Net (Left), R);
               Set_Location (N, Expr);
               Bnd := Create_Bounds_From_Length
                 (Syn_Inst,
                  Get_Index_Type (Get_Type (Expr), 0),
                  Iir_Index32 (Get_Width (R) + 1));

               return Create_Value_Net
                 (N, Create_Onedimensional_Array_Subtype (Right_Typ, Bnd));
            end;
         when Iir_Predefined_Element_Element_Concat =>
            declare
               Ret_Typ : constant Type_Acc :=
                 Get_Value_Type (Syn_Inst, Get_Return_Type (Imp));
               N : Net;
               Bnd : Bound_Type;
            begin
               N := Build_Concat2
                 (Build_Context, Get_Net (Left), Get_Net (Right));
               Set_Location (N, Expr);
               Bnd := Create_Bounds_From_Length
                 (Syn_Inst, Get_Index_Type (Get_Type (Expr), 0), 2);
               return Create_Value_Net
                 (N, Create_Onedimensional_Array_Subtype (Ret_Typ, Bnd));
            end;
         when Iir_Predefined_Array_Array_Concat =>
            declare
               L : constant Net := Get_Net (Left);
               R : constant Net := Get_Net (Right);
               Bnd : Bound_Type;
               N : Net;
            begin
               N := Build_Concat2 (Build_Context, L, R);
               Set_Location (N, Expr);
               Bnd := Create_Bounds_From_Length
                 (Syn_Inst,
                  Get_Index_Type (Get_Type (Expr), 0),
                  Iir_Index32 (Get_Width (L) + Get_Width (R)));

               return Create_Value_Net
                 (N, Create_Vector_Type (Bnd, Get_Array_Element (Left.Typ)));
            end;
         when Iir_Predefined_Integer_Plus =>
            return Synth_Int_Dyadic (Id_Add);
         when Iir_Predefined_Integer_Minus =>
            return Synth_Int_Dyadic (Id_Sub);
         when Iir_Predefined_Integer_Mul =>
            return Synth_Int_Dyadic (Id_Smul);
         when Iir_Predefined_Integer_Div =>
            return Synth_Int_Dyadic (Id_Sdiv);
         when Iir_Predefined_Integer_Mod =>
            if Is_Static_Val (Right) then
               --  Optimize when the divisor is a power of 2.
               declare
                  use Mutils;
                  Etype : constant Type_Acc :=
                    Get_Value_Type (Syn_Inst, Expr_Type);
                  R : constant Int64 := Get_Static_Discrete (Right);
                  Log_R : Natural;
                  N : Net;
               begin
                  if R > 0 and then Is_Power2 (Uns64 (R)) then
                     Log_R := Clog2 (Uns64 (R));
                     pragma Assert (Log_R <= Natural (Left.Typ.W));
                     N := Get_Net (Left);
                     N := Build2_Extract (Ctxt, N, 0, Width (Log_R));
                     N := Build2_Uresize (Ctxt, N, Left.Typ.W,
                                          Get_Location (Expr));
                     return Create_Value_Net (N, Etype);
                  end if;
               end;
            end if;
            return Synth_Int_Dyadic (Id_Smod);
         when Iir_Predefined_Integer_Rem =>
            return Synth_Int_Dyadic (Id_Srem);
         when Iir_Predefined_Integer_Exp =>
            Error_Msg_Synth
              (+Expr, "non-constant exponentiation not supported");
            return null;
         when Iir_Predefined_Integer_Less_Equal =>
            return Synth_Compare (Id_Sle, Boolean_Type);
         when Iir_Predefined_Integer_Less =>
            return Synth_Compare (Id_Slt, Boolean_Type);
         when Iir_Predefined_Integer_Greater_Equal =>
            return Synth_Compare (Id_Sge, Boolean_Type);
         when Iir_Predefined_Integer_Greater =>
            return Synth_Compare (Id_Sgt, Boolean_Type);
         when Iir_Predefined_Integer_Equality =>
            return Synth_Compare (Id_Eq, Boolean_Type);
         when Iir_Predefined_Integer_Inequality =>
            return Synth_Compare (Id_Ne, Boolean_Type);
         when Iir_Predefined_Physical_Physical_Div =>
            Error_Msg_Synth (+Expr, "non-constant division not supported");
            return null;

         when Iir_Predefined_Floating_Div =>
            Error_Msg_Synth (+Expr, "non-constant division not supported");
            return null;

         when Iir_Predefined_Ieee_Numeric_Std_Sra_Sgn_Int =>
            return Synth_Shift (Id_Asr, Id_None);

         when Iir_Predefined_Ieee_Numeric_Std_Sll_Uns_Int =>
            return Synth_Shift (Id_Lsl, Id_None);

         when Iir_Predefined_Ieee_1164_Vector_Ror =>
            return Synth_Rotation (Id_Ror);

         when others =>
            Error_Msg_Synth (+Expr, "synth_dyadic_operation: unhandled "
                               & Iir_Predefined_Functions'Image (Def));
            raise Internal_Error;
      end case;
   end Synth_Dyadic_Operation;

   function Synth_Monadic_Operation (Syn_Inst : Synth_Instance_Acc;
                                     Imp : Node;
                                     Operand_Expr : Node;
                                     Loc : Node) return Value_Acc
   is
      Def : constant Iir_Predefined_Functions :=
        Get_Implicit_Definition (Imp);
      Inter_Chain : constant Node :=
        Get_Interface_Declaration_Chain (Imp);
      Oper_Type : constant Node := Get_Type (Inter_Chain);
      Oper_Typ : constant Type_Acc := Get_Value_Type (Syn_Inst, Oper_Type);
      Operand : Value_Acc;

      function Synth_Bit_Monadic (Id : Monadic_Module_Id) return Value_Acc
      is
         N : Net;
      begin
         N := Build_Monadic (Build_Context, Id, Get_Net (Operand));
         Set_Location (N, Loc);
         return Create_Value_Net (N, Operand.Typ);
      end Synth_Bit_Monadic;

      function Synth_Vec_Monadic (Id : Monadic_Module_Id) return Value_Acc
      is
         Op: constant Net := Get_Net (Operand);
         N : Net;
      begin
         N := Build_Monadic (Build_Context, Id, Op);
         Set_Location (N, Loc);
         return Create_Value_Net (N, Create_Res_Bound (Operand));
      end Synth_Vec_Monadic;

      function Synth_Vec_Reduce_Monadic (Id : Reduce_Module_Id)
         return Value_Acc
      is
         Op: constant Net := Get_Net (Operand);
         N : Net;
      begin
         N := Build_Reduce (Build_Context, Id, Op);
         Set_Location (N, Loc);
         return Create_Value_Net (N, Operand.Typ.Vec_El);
      end Synth_Vec_Reduce_Monadic;
   begin
      Operand := Synth_Expression_With_Type (Syn_Inst, Operand_Expr, Oper_Typ);
      Operand := Synth_Subtype_Conversion (Operand, Oper_Typ, False, Loc);
      Strip_Const (Operand);

      if Is_Static_Val (Operand) then
         return Synth_Static_Monadic_Predefined
           (Syn_Inst, Imp, Operand, Loc);
      end if;

      case Def is
         when Iir_Predefined_Error =>
            return null;
         when Iir_Predefined_Ieee_1164_Scalar_Not =>
            return Synth_Bit_Monadic (Id_Not);
         when Iir_Predefined_Boolean_Not
           | Iir_Predefined_Bit_Not =>
            return Synth_Bit_Monadic (Id_Not);
         when Iir_Predefined_Ieee_1164_Vector_Not
            | Iir_Predefined_Ieee_Numeric_Std_Not_Uns
            | Iir_Predefined_Ieee_Numeric_Std_Not_Sgn =>
            return Synth_Vec_Monadic (Id_Not);
         when Iir_Predefined_Ieee_Numeric_Std_Neg_Uns
           | Iir_Predefined_Ieee_Numeric_Std_Neg_Sgn =>
            return Synth_Vec_Monadic (Id_Neg);
         when Iir_Predefined_Ieee_Numeric_Std_Abs_Sgn =>
            return Synth_Vec_Monadic (Id_Abs);
         when Iir_Predefined_Ieee_1164_Vector_And_Reduce =>
            return Synth_Vec_Reduce_Monadic(Id_Red_And);
         when Iir_Predefined_Ieee_1164_Vector_Or_Reduce =>
            return Synth_Vec_Reduce_Monadic(Id_Red_Or);
         when Iir_Predefined_Ieee_1164_Condition_Operator =>
            return Operand;
         when Iir_Predefined_Integer_Negation =>
            declare
               N : Net;
            begin
               N := Build_Monadic (Build_Context, Id_Neg, Get_Net (Operand));
               Set_Location (N, Loc);
               return Create_Value_Net (N, Operand.Typ);
            end;
         when others =>
            Error_Msg_Synth
              (+Loc,
               "unhandled monadic: " & Iir_Predefined_Functions'Image (Def));
            raise Internal_Error;
      end case;
   end Synth_Monadic_Operation;

   function Synth_Shift_Rotate (Id : Shift_Rotate_Module_Id;
                         Left, Right : Value_Acc;
                         Expr : Node) return Value_Acc
   is
      L : constant Net := Get_Net (Left);
      N : Net;
   begin
      N := Build_Shift_Rotate (Build_Context, Id, L, Get_Net (Right));
      Set_Location (N, Expr);
      return Create_Value_Net (N, Create_Res_Bound (Left));
   end Synth_Shift_Rotate;

   function Synth_Std_Match (Cst : Value_Acc;
                             Oper : Value_Acc;
                             Expr : Node) return Value_Acc
   is
      Wd : constant Width := Cst.Typ.W;
      Nwords : constant Natural := Natural ((Wd + 31) / 32);
      Mask : Uns32_Arr_Acc;
      Vals : Uns32_Arr_Acc;
      Boff : Natural;
      Woff : Natural;
      B : Uns32;
      M : Uns32;
      Nv : Net;
      Nm : Net;
      Res : Net;
   begin
      if Oper.Typ.W /= Wd then
         Error_Msg_Synth
           (+Expr, "operands of std_match don't have the same size");
         return Create_Value_Discrete (0, Boolean_Type);
      end if;

      pragma Assert (Wd > 0);

      --  Flatten 0/1 DC.
      Mask := new Uns32_Arr'(0 .. Nwords - 1 => 0);
      Vals := new Uns32_Arr'(0 .. Nwords - 1 => 0);

      Boff := 0;
      Woff := 0;
      for I in reverse Cst.Arr.V'Range loop
         case Cst.Arr.V (I).Scal is
            when Vhdl.Ieee.Std_Logic_1164.Std_Logic_0_Pos
              |  Vhdl.Ieee.Std_Logic_1164.Std_Logic_L_Pos =>
               B := 0;
               M := 1;
            when Vhdl.Ieee.Std_Logic_1164.Std_Logic_1_Pos
              |  Vhdl.Ieee.Std_Logic_1164.Std_Logic_H_Pos =>
               B := 1;
               M := 1;
            when Vhdl.Ieee.Std_Logic_1164.Std_Logic_U_Pos
              |  Vhdl.Ieee.Std_Logic_1164.Std_Logic_X_Pos
              |  Vhdl.Ieee.Std_Logic_1164.Std_Logic_Z_Pos
              |  Vhdl.Ieee.Std_Logic_1164.Std_Logic_W_Pos =>
               --  Never match
               --  FIXME: warning ?
               Unchecked_Deallocate (Mask);
               Unchecked_Deallocate (Vals);
               return Create_Value_Discrete (0, Boolean_Type);
            when Vhdl.Ieee.Std_Logic_1164.Std_Logic_D_Pos =>
               B := 0;
               M := 0;
            when others =>
               raise Internal_Error;
         end case;
         Mask (Woff) := Mask (Woff) or Shift_Left (M, Boff);
         Vals (Woff) := Vals (Woff) or Shift_Left (B, Boff);
         Boff := Boff + 1;
         if Boff = 32 then
            Boff := 0;
            Woff := Woff + 1;
         end if;
      end loop;

      --  Generate and + eq
      Nv := Build2_Const_Vec (Build_Context, Wd, Vals.all);
      Set_Location (Nv, Expr);
      Unchecked_Deallocate (Vals);
      Nm := Build2_Const_Vec (Build_Context, Wd, Mask.all);
      Set_Location (Nm, Expr);
      Unchecked_Deallocate (Mask);
      Res := Build_Dyadic (Build_Context, Id_And, Get_Net (Oper), Nm);
      Set_Location (Res, Expr);
      Res := Build_Compare (Build_Context, Id_Eq, Res, Nv);
      Set_Location (Res, Expr);

      return Create_Value_Net (Res, Boolean_Type);
   end Synth_Std_Match;

   function Synth_Dynamic_Predefined_Function_Call
     (Subprg_Inst : Synth_Instance_Acc; Expr : Node) return Value_Acc
   is
      Ctxt : constant Context_Acc := Get_Build (Subprg_Inst);
      Imp  : constant Node := Get_Implementation (Expr);
      Def : constant Iir_Predefined_Functions :=
        Get_Implicit_Definition (Imp);
      Inter_Chain : constant Node := Get_Interface_Declaration_Chain (Imp);
      Param1 : Node;
      Param2 : Node;
   begin
      Param1 := Inter_Chain;
      if Param1 /= Null_Node then
         Param2 := Get_Chain (Inter_Chain);
      else
         Param2 := Null_Node;
      end if;

      case Def is
         when Iir_Predefined_Ieee_1164_Rising_Edge =>
            declare
               Clk : Net;
               Edge : Net;
            begin
               Clk := Get_Net (Get_Value (Subprg_Inst, Param1));
               Edge := Build_Edge (Ctxt, Clk);
               return Create_Value_Net (Edge, Boolean_Type);
            end;
         when Iir_Predefined_Ieee_1164_Falling_Edge =>
            declare
               Clk : Net;
               Edge : Net;
            begin
               Clk := Get_Net (Get_Value (Subprg_Inst, Param1));
               Clk := Build_Monadic (Ctxt, Id_Not, Clk);
               Edge := Build_Edge (Ctxt, Clk);
               return Create_Value_Net (Edge, Boolean_Type);
            end;
         when Iir_Predefined_Ieee_1164_Scalar_Is_X
           | Iir_Predefined_Ieee_1164_Vector_Is_X =>
            --  Always false.
            return Create_Value_Discrete (0, Boolean_Type);
         when Iir_Predefined_Ieee_1164_To_Bitvector =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               R : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
               pragma Unreferenced (R);
            begin
               if Is_Static (L) then
                  raise Internal_Error;
               end if;
               return Create_Value_Net (Get_Net (L), Create_Res_Bound (L));
            end;
         when Iir_Predefined_Ieee_1164_To_Stdlogicvector_Suv
           | Iir_Predefined_Ieee_1164_To_Stdlogicvector_Bv =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
            begin
               if Is_Static (L) then
                  raise Internal_Error;
               end if;
               return Create_Value_Net (Get_Net (L), Create_Res_Bound (L));
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Touns_Nat_Nat_Uns
           | Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Unsigned_Int =>
            declare
               Arg : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               Size : Value_Acc;
               Arg_Net : Net;
            begin
               Size := Get_Value (Subprg_Inst, Param2);
               if not Is_Static (Size) then
                  Error_Msg_Synth (+Expr, "to_unsigned size must be constant");
                  return null;
               end if;
               Strip_Const (Size);
               Arg_Net := Get_Net (Arg);
               return Create_Value_Net
                 (Build2_Uresize (Ctxt, Arg_Net, Uns32 (Size.Scal),
                                  Get_Location (Expr)),
                  Create_Vec_Type_By_Length (Uns32 (Size.Scal),
                                             Logic_Type));
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Tosgn_Int_Nat_Sgn =>
            declare
               Arg : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               Size : Value_Acc;
               Arg_Net : Net;
            begin
               Size := Get_Value (Subprg_Inst, Param2);
               if not Is_Static (Size) then
                  Error_Msg_Synth (+Expr, "to_signed size must be constant");
                  return null;
               end if;
               Strip_Const (Size);
               Arg_Net := Get_Net (Arg);
               return Create_Value_Net
                 (Build2_Sresize (Ctxt, Arg_Net, Uns32 (Size.Scal),
                                  Get_Location (Expr)),
                  Create_Vec_Type_By_Length (Uns32 (Size.Scal),
                                             Logic_Type));
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Toint_Uns_Nat
           | Iir_Predefined_Ieee_Std_Logic_Arith_Conv_Integer_Uns
           | Iir_Predefined_Ieee_Std_Logic_Unsigned_Conv_Integer =>
            --  UNSIGNED to Natural.
            declare
               Int_Type : constant Type_Acc :=
                 Get_Value_Type (Subprg_Inst,
                                 Vhdl.Std_Package.Integer_Subtype_Definition);
            begin
               return Create_Value_Net
                 (Synth_Uresize (Get_Net (Get_Value (Subprg_Inst, Param1)),
                                 Int_Type.W, Expr),
                  Int_Type);
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Resize_Uns_Nat =>
            declare
               V : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               Sz : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
               W : Width;
            begin
               if not Is_Static (Sz) then
                  Error_Msg_Synth (+Expr, "size must be constant");
                  return null;
               end if;
               W := Uns32 (Sz.Scal);
               return Create_Value_Net
                 (Synth_Uresize (Get_Net (V), W, Expr),
                  Create_Vec_Type_By_Length (W, Logic_Type));
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Resize_Sgn_Nat =>
            declare
               V : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               Sz : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
               W : Width;
            begin
               if not Is_Static (Sz) then
                  Error_Msg_Synth (+Expr, "size must be constant");
                  return null;
               end if;
               W := Uns32 (Sz.Scal);
               return Create_Value_Net
                 (Build2_Sresize (Ctxt, Get_Net (V), W, Get_Location (Expr)),
                  Create_Vec_Type_By_Length (W, Logic_Type));
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Shl_Uns_Nat
           | Iir_Predefined_Ieee_Numeric_Std_Shl_Sgn_Nat =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               R : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
            begin
               return Synth_Shift_Rotate (Id_Lsl, L, R, Expr);
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Shr_Uns_Nat =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               R : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
            begin
               return Synth_Shift_Rotate (Id_Lsr, L, R, Expr);
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Shr_Sgn_Nat =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               R : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
            begin
               return Synth_Shift_Rotate (Id_Asr, L, R, Expr);
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Rol_Uns_Nat =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               R : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
            begin
               return Synth_Shift_Rotate (Id_Rol, L, R, Expr);
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Ror_Uns_Nat =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               R : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
            begin
               return Synth_Shift_Rotate (Id_Ror, L, R, Expr);
            end;
         when Iir_Predefined_Ieee_Numeric_Std_Match_Suv
            | Iir_Predefined_Ieee_Numeric_Std_Match_Slv =>
            declare
               L : constant Value_Acc := Get_Value (Subprg_Inst, Param1);
               R : constant Value_Acc := Get_Value (Subprg_Inst, Param2);
            begin
               if Is_Static (L) then
                  return Synth_Std_Match (L, R, Expr);
               elsif Is_Static (R) then
                  return Synth_Std_Match (R, L, Expr);
               else
                  Error_Msg_Synth
                    (+Expr, "one operand of std_match must be constant");
                  return null;
               end if;
            end;
         when others =>
            Error_Msg_Synth
              (+Expr,
               "unhandled function: " & Iir_Predefined_Functions'Image (Def));
            return null;
      end case;
   end Synth_Dynamic_Predefined_Function_Call;

   function Synth_Predefined_Function_Call
     (Syn_Inst : Synth_Instance_Acc; Expr : Node) return Value_Acc
   is
      Imp  : constant Node := Get_Implementation (Expr);
      Assoc_Chain : constant Node := Get_Parameter_Association_Chain (Expr);
      Inter_Chain : constant Node := Get_Interface_Declaration_Chain (Imp);
      Inter : Node;
      Subprg_Inst : Synth_Instance_Acc;
      M : Areapools.Mark_Type;
      Static : Boolean;
      Res : Value_Acc;
   begin
      Areapools.Mark (M, Instance_Pool.all);
      Subprg_Inst := Make_Instance (Syn_Inst, Imp);

      Synth_Subprogram_Association
        (Subprg_Inst, Syn_Inst, Inter_Chain, Assoc_Chain);

      --  If all operands are static, handle the call differently.
      Static := True;
      Inter := Inter_Chain;
      while Inter /= Null_Node loop
         if not Is_Static (Get_Value (Subprg_Inst, Inter)) then
            Static := False;
            exit;
         end if;
         Inter := Get_Chain (Inter);
      end loop;

      if Static then
         Res := Synth_Static_Predefined_Function_Call (Subprg_Inst, Expr);
      else
         Res := Synth_Dynamic_Predefined_Function_Call (Subprg_Inst, Expr);
      end if;

      Free_Instance (Subprg_Inst);
      Areapools.Release (M, Instance_Pool.all);

      return Res;
   end Synth_Predefined_Function_Call;
end Synth.Oper;
