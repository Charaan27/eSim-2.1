--  Create declarations for synthesis.
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

with Types; use Types;

with Grt.Types; use Grt.Types;
with Grt.Files_Operations; use Grt.Files_Operations;

with Vhdl.Annotations;

with Synth.Expr; use Synth.Expr;
with Synth.Errors; use Synth.Errors;

package body Synth.Files_Operations is

   --  Representation of file name compatible with C (so NUL terminated).
   subtype C_File_Name is String (1 .. 1025);

   procedure File_Error (Loc : Node; Status : Op_Status);
   pragma No_Return (File_Error);

   procedure File_Error (Loc : Node; Status : Op_Status) is
   begin
      pragma Assert (Status /= Op_Ok);
      Error_Msg_Synth (+Loc, "file operation failed");
      raise File_Execution_Error;
   end File_Error;

   --  VAL represents a string, so an array of characters.
   procedure Convert_String (Val : Value_Acc; Res : out String)
   is
      Vtyp : constant Type_Acc := Val.Typ;
   begin
      pragma Assert (Vtyp.Kind = Type_Array);
      pragma Assert (Vtyp.Arr_El.Kind = Type_Discrete);
      pragma Assert (Vtyp.Arr_El.W in 7 .. 8); --  Could be 7 in vhdl87
      pragma Assert (Vtyp.Abounds.Len = 1);
      pragma Assert (Vtyp.Abounds.D (1).Len = Res'Length);

      for I in Val.Arr.V'Range loop
         Res (Res'First + Natural (I - 1)) :=
           Character'Val (Val.Arr.V (I).Scal);
      end loop;
   end Convert_String;

   --  Convert filename VAL to RES + LEN.
   procedure Convert_File_Name (Val : Value_Acc;
                                Res : out C_File_Name;
                                Len : out Natural;
                                Status : out Op_Status) is
   begin
      Len := Natural (Val.Arr.Len);

      if Len >= Res'Length - 1 then
         Status := Op_Filename_Error;
         return;
      end if;

      Convert_String (Val, Res (1 .. Len));
      Res (Len + 1) := Grt.Types.NUL;

      Status := Op_Ok;
   end Convert_File_Name;

   function Elaborate_File_Declaration
     (Syn_Inst : Synth_Instance_Acc; Decl : Node) return File_Index
   is
      File_Type : constant Node := Get_Type (Decl);
      External_Name : constant Node := Get_File_Logical_Name (Decl);
      Open_Kind : constant Node := Get_File_Open_Kind (Decl);
      File_Name : Value_Acc;
      C_Name : C_File_Name;
      C_Name_Len : Natural;
      Mode : Value_Acc;
      F : File_Index;
      File_Mode : Ghdl_I32;
      Status : Op_Status;
   begin
      if Get_Text_File_Flag (File_Type) then
         F := Ghdl_Text_File_Elaborate;
      else
         declare
            Sig : constant String_Acc :=
              Vhdl.Annotations.Get_Info (File_Type).File_Signature;
            Cstr : Ghdl_C_String;
         begin
            if Sig = null then
               Cstr := null;
            else
               Cstr := To_Ghdl_C_String (Sig.all'Address);
            end if;
            F := Ghdl_File_Elaborate (Cstr);
         end;
      end if;

      --  LRM93 4.3.1.4
      --  If file open information is not included in a given file declaration,
      --  then the file declared by the declaration is not opened when the file
      --  declaration is elaborated.
      if External_Name = Null_Node then
         return F;
      end if;

      File_Name := Synth_Expression_With_Basetype (Syn_Inst, External_Name);

      if Open_Kind /= Null_Node then
         Mode := Synth_Expression (Syn_Inst, Open_Kind);
         File_Mode := Ghdl_I32 (Mode.Scal);
      else
         case Get_Mode (Decl) is
            when Iir_In_Mode =>
               File_Mode := Read_Mode;
            when Iir_Out_Mode =>
               File_Mode := Write_Mode;
            when others =>
               raise Internal_Error;
         end case;
      end if;

      Convert_File_Name (File_Name, C_Name, C_Name_Len, Status);
      if Status = Op_Ok then
         if Get_Text_File_Flag (File_Type) then
            Ghdl_Text_File_Open
              (F, File_Mode, To_Ghdl_C_String (C_Name'Address), Status);
         else
            Ghdl_File_Open
              (F, File_Mode, To_Ghdl_C_String (C_Name'Address), Status);
         end if;
      end if;

      if Status /= Op_Ok then
         if Status = Op_Name_Error then
            Error_Msg_Synth
              (+Decl, "cannot open file: " & C_Name (1 .. C_Name_Len));
            raise File_Execution_Error;
         else
            File_Error (Decl, Status);
         end if;
      end if;

      return F;
   end Elaborate_File_Declaration;

   function Endfile (F : File_Index; Loc : Syn_Src) return Boolean
   is
      Status : Op_Status;
   begin
      Ghdl_File_Endfile (F, Status);

      if Status = Op_Ok then
         return False;
      elsif Status = Op_End_Of_File then
         return True;
      else
         File_Error (Loc, Status);
      end if;
   end Endfile;

   --  Declaration
   --  procedure FILE_OPEN (file F : FT;
   --                       External_Name : String;
   --                       Open_Kind : File_Open_Kind);
   procedure Synth_File_Open
     (Syn_Inst : Synth_Instance_Acc; Imp : Node; Loc : Node)
   is
      Inters : constant Node := Get_Interface_Declaration_Chain (Imp);
      F : constant File_Index := Get_Value (Syn_Inst, Inters).File;
      Param2 : constant Node := Get_Chain (Inters);
      File_Name : constant Value_Acc := Get_Value (Syn_Inst, Param2);
      Param3 : constant Node := Get_Chain (Param2);
      Open_Kind : constant Value_Acc := Get_Value (Syn_Inst, Param3);
      C_Name : C_File_Name;
      C_Name_Len : Natural;
      File_Mode : Ghdl_I32;
      Status : Op_Status;
   begin
      Convert_File_Name (File_Name, C_Name, C_Name_Len, Status);
      if Status = Op_Ok then
         File_Mode := Ghdl_I32 (Open_Kind.Scal);
         if Get_Text_File_Flag (Get_Type (Inters)) then
            Ghdl_Text_File_Open
              (F, File_Mode, To_Ghdl_C_String (C_Name'Address), Status);
         else
            Ghdl_File_Open
              (F, File_Mode, To_Ghdl_C_String (C_Name'Address), Status);
         end if;
      end if;

      if Status /= Op_Ok then
         if Status = Op_Name_Error then
            Error_Msg_Synth
              (+Loc, "cannot open file: " & C_Name (1 .. C_Name_Len));
            raise File_Execution_Error;
         else
            File_Error (Loc, Status);
         end if;
      end if;
   end Synth_File_Open;

   --  Declaration
   --  procedure FILE_CLOSE (file F : FT);
   procedure Synth_File_Close
     (Syn_Inst : Synth_Instance_Acc; Imp : Node; Loc : Node)
   is
      Inters : constant Node := Get_Interface_Declaration_Chain (Imp);
      F : constant File_Index := Get_Value (Syn_Inst, Inters).File;
      Status : Op_Status;
   begin
      if Get_Text_File_Flag (Get_Type (Inters)) then
         Ghdl_Text_File_Close (F, Status);
      else
         Ghdl_File_Close (F, Status);
      end if;

      if Status /= Op_Ok then
         File_Error (Loc, Status);
      end if;
   end Synth_File_Close;

   --  Declaration:
   --  procedure untruncated_text_read                              --!V87
   --    (file f : text; str : out string; len : out natural);      --!V87
   procedure Synth_Untruncated_Text_Read (Syn_Inst : Synth_Instance_Acc;
                                          Imp : Node;
                                          Loc : Node)
   is
      Inters : constant Node := Get_Interface_Declaration_Chain (Imp);
      File : constant File_Index := Get_Value (Syn_Inst, Inters).File;
      Param2 : constant Node := Get_Chain (Inters);
      Str : constant Value_Acc := Get_Value (Syn_Inst, Param2);
      Param3 : constant Node := Get_Chain (Param2);
      Param_Len : constant Value_Acc := Get_Value (Syn_Inst, Param3);
      Buf : String (1 .. Natural (Str.Arr.Len));
      Len : Std_Integer;
      Status : Op_Status;
   begin
      Len := Std_Integer (Buf'Last);
      Ghdl_Untruncated_Text_Read
        (File, To_Ghdl_C_String (Buf'Address), Len, Status);
      if Status /= Op_Ok then
         File_Error (Loc, Status);
      end if;

      for I in 1 .. Natural (Len) loop
         Str.Arr.V (Iir_Index32 (I)).Scal := Character'Pos (Buf (I));
      end loop;

      Param_Len.Scal := Int64 (Len);
   end Synth_Untruncated_Text_Read;

end Synth.Files_Operations;
