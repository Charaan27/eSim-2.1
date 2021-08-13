
-- Copyright (C) 2001 Bill Billowitch.

-- Some of the work to develop this test suite was done with Air Force
-- support.  The Air Force and Bill Billowitch assume no
-- responsibilities for this software.

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
-- $Id: tc837.vhd,v 1.2 2001-10-26 16:30:00 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

entity c01s03b01x00p02n01i00837ent_a is 
end c01s03b01x00p02n01i00837ent_a;

architecture c01s03b01x00p02n01i00837arch_a of c01s03b01x00p02n01i00837ent_a is
  signal S1 : INTEGER;
begin
  A2_BLK : block
  begin
    S1 <= 2 after 10 ns;
  end block;

  TESTING: PROCESS(S1)
  BEGIN
    if (now > 1 ns) then
      assert NOT(S1 = 2) 
        report "***PASSED TEST: c01s03b01x00p02n01i00837"
        severity NOTE;
      assert (S1 = 2) 
        report "***FAILED TEST: c01s03b01x00p02n01i00837 - Configuration block syntactic error."
        severity ERROR;
    end if;
  END PROCESS TESTING;

end c01s03b01x00p02n01i00837arch_a;

ENTITY c01s03b01x00p02n01i00837ent IS
END c01s03b01x00p02n01i00837ent;

ARCHITECTURE c01s03b01x00p02n01i00837arch OF c01s03b01x00p02n01i00837ent IS

BEGIN

  DBLK : block
    component FOUR
    end component;
  begin
    LS : FOUR ;
  end block DBLK;

END c01s03b01x00p02n01i00837arch;

configuration c01s03b01x00p02n01i00837cfg of c01s03b01x00p02n01i00837ent  is
  for c01s03b01x00p02n01i00837arch
    for DBLK
      for LS : FOUR use entity work.c01s03b01x00p02n01i00837ent_a(c01s03b01x00p02n01i00837arch_a);
      end for;
    end for;
  end for;
end c01s03b01x00p02n01i00837cfg;
