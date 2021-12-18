
-- Copyright (C) 1996 Morgan Kaufmann Publishers, Inc

-- This file is part of VESTs (Vhdl tESTs).

-- VESTs is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2 of the License, or (at
-- your option) any later version. 

-- VESTs is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details. 

-- You should have received a copy of the GNU General Public License
-- along with VESTs; if not, write to the Free Software Foundation,
-- Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

-- ---------------------------------------------------------------------
--
-- $Id: ch_13_fg_13_07.vhd,v 1.1.1.1 2001-08-22 18:20:48 paw Exp $
-- $Revision: 1.1.1.1 $
--
-- ---------------------------------------------------------------------

configuration counter_down_to_gate_level of counter is

  for registered

    for all : digit_register
      use configuration work.reg4_gate_level;
    end for;

    -- . . .    -- bindings for other component instances

  end for;  -- end of architecture registered

end configuration counter_down_to_gate_level;



-- not in book

entity fg_13_07 is
end entity fg_13_07;


use work.counter_types.all;

architecture test of fg_13_07 is

  signal clk, clr : bit := '0';
  signal q0, q1 : digit;

begin

  dut : configuration work.counter_down_to_gate_level
    port map ( clk => clk, clr => clr,
               q0 => q0, q1 => q1 );

  clk_gen : clk <= not clk after 20 ns;

  clr_gen : clr <= '1' after 95 ns,
		   '0' after 135 ns;

end architecture test;

-- end not in book
