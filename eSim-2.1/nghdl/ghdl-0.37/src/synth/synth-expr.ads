--  Expressions synthesis.
--  Copyright (C) 2017 Tristan Gingold
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

with Ada.Unchecked_Deallocation;

with Types; use Types;

with Netlists; use Netlists;
with Netlists.Utils; use Netlists.Utils;

with Synth.Source;
with Synth.Values; use Synth.Values;
with Synth.Context; use Synth.Context;
with Vhdl.Nodes; use Vhdl.Nodes;

package Synth.Expr is
   --  Perform a subtype conversion.  Check constraints.
   function Synth_Subtype_Conversion (Val : Value_Acc;
                                      Dtype : Type_Acc;
                                      Bounds : Boolean;
                                      Loc : Source.Syn_Src)
                                     return Value_Acc;

   --  For a static value V, return the value.
   function Get_Static_Discrete (V : Value_Acc) return Int64;

   --  Return True only if discrete value V is known to be positive or 0.
   --  False means either not positive or unknown.
   function Is_Positive (V : Value_Acc) return Boolean;

   --  Return the bounds of a one dimensional array/vector type and the
   --  width of the element.
   procedure Get_Onedimensional_Array_Bounds
     (Typ : Type_Acc; Bnd : out Bound_Type; El_Typ : out Type_Acc);

   --  Create an array subtype from bound BND.
   function Create_Onedimensional_Array_Subtype
     (Btyp : Type_Acc; Bnd : Bound_Type) return Type_Acc;

   procedure From_Std_Logic (Enum : Int64; Val : out Uns32; Zx : out Uns32);
   procedure From_Bit (Enum : Int64; Val : out Uns32);
   procedure To_Logic
     (Enum : Int64; Etype : Type_Acc; Val : out Uns32; Zx : out Uns32);

   --  Try to match: clk'event and clk = X
   --            or: clk = X and clk'event
   --  where X is '0' or '1'.
   function Synth_Clock_Edge
     (Syn_Inst : Synth_Instance_Acc; Left, Right : Node) return Net;

   function Bit_Extract (Val : Value_Acc; Off : Uns32; Loc : Node)
                        return Value_Acc;

   function Concat_Array (Arr : Net_Array_Acc) return Net;

   function Synth_Expression_With_Type
     (Syn_Inst : Synth_Instance_Acc; Expr : Node; Expr_Type : Type_Acc)
     return Value_Acc;

   function Synth_Expression (Syn_Inst : Synth_Instance_Acc; Expr : Node)
                             return Value_Acc;

   --  Use base type of EXPR to synthesize EXPR.  Useful when the type of
   --  EXPR is defined by itself or a range.
   function Synth_Expression_With_Basetype
     (Syn_Inst : Synth_Instance_Acc; Expr : Node) return Value_Acc;

   function Synth_Bounds_From_Range (Syn_Inst : Synth_Instance_Acc;
                                     Atype : Node) return Bound_Type;

   function Synth_Array_Bounds (Syn_Inst : Synth_Instance_Acc;
                                Atype : Node;
                                Dim : Natural) return Bound_Type;

   function Synth_Discrete_Range_Expression
     (L : Int64; R : Int64; Dir : Iir_Direction) return Discrete_Range_Type;
   function Synth_Discrete_Range_Expression
     (Syn_Inst : Synth_Instance_Acc; Rng : Node) return Discrete_Range_Type;
   function Synth_Float_Range_Expression
     (Syn_Inst : Synth_Instance_Acc; Rng : Node) return Float_Range_Type;

   procedure Synth_Discrete_Range (Syn_Inst : Synth_Instance_Acc;
                                   Bound : Node;
                                   Rng : out Discrete_Range_Type);

   procedure Synth_Slice_Suffix (Syn_Inst : Synth_Instance_Acc;
                                 Name : Node;
                                 Pfx_Bnd : Bound_Type;
                                 El_Wd : Width;
                                 Res_Bnd : out Bound_Type;
                                 Inp : out Net;
                                 Off : out Uns32;
                                 Wd : out Width);

   --  If VOFF is No_Net then OFF is valid, if VOFF is not No_Net then
   --  OFF is 0.
   procedure Synth_Indexed_Name (Syn_Inst : Synth_Instance_Acc;
                                 Name : Node;
                                 Pfx_Type : Type_Acc;
                                 Voff : out Net;
                                 Off : out Uns32;
                                 W : out Width);

   --  Conversion to logic vector.

   type Logic_32 is record
      Val : Uns32;  --  AKA aval
      Zx  : Uns32;  --  AKA bval
   end record;

   type Digit_Index is new Natural;
   type Logvec_Array is array (Digit_Index range <>) of Logic_32;
   type Logvec_Array_Acc is access Logvec_Array;

   procedure Free_Logvec_Array is new Ada.Unchecked_Deallocation
     (Logvec_Array, Logvec_Array_Acc);

   procedure Value2logvec (Val : Value_Acc;
                           Vec : in out Logvec_Array;
                           Off : in out Uns32;
                           Has_Zx : in out Boolean);
end Synth.Expr;
