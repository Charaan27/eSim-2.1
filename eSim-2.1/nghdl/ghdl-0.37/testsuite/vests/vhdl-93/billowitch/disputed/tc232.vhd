
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
-- $Id: tc232.vhd,v 1.2 2001-10-26 16:30:04 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

ENTITY c03s01b02x00p02n01i00232ent IS
END c03s01b02x00p02n01i00232ent;

ARCHITECTURE c03s01b02x00p02n01i00232arch OF c03s01b02x00p02n01i00232ent IS
  type a is range (1+1) to (1 ms/1 ns);
BEGIN
  TESTING: PROCESS
    variable k : a := 3;
  BEGIN
    k := 5;
    assert NOT(k=5) 
      report "***PASSED TEST: c03s01b02x00p02n01i00232" 
      severity NOTE;
    assert (k=5) 
      report "***FAILED TEST: c03s01b02x00p02n01i00232 - The right bound in the range constraint is not a locally static expression of type integer." 
      severity ERROR;
    wait;
  END PROCESS TESTING;

END c03s01b02x00p02n01i00232arch;
