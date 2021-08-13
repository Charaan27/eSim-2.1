
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
-- $Id: tc1463.vhd,v 1.2 2001-10-26 16:29:41 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

ENTITY c08s08b00x00p02n01i01463ent IS
END c08s08b00x00p02n01i01463ent;

ARCHITECTURE c08s08b00x00p02n01i01463arch OF c08s08b00x00p02n01i01463ent IS

BEGIN
  TESTING: PROCESS
    variable x : integer := 1;
    variable k : integer := 0;
  BEGIN
    case x is
      when 1 => k := 5;
      when 2 => NULL;
      when 3 => NULL;
      when others => NULL;
    end case;
    assert NOT( k=5 ) 
      report "***PASSED TEST: c08s08b00x00p02n01i01463" 
      severity NOTE;
    assert ( k=5 ) 
      report "***FAILED TEST: c08s08b00x00p02n01i01463 - missing reserved word 'when'"
      severity ERROR;
    wait;
  END PROCESS TESTING;

END c08s08b00x00p02n01i01463arch;
