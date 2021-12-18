
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
-- $Id: tc2499.vhd,v 1.2 2001-10-26 16:29:48 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

ENTITY c07s03b03x00p05n01i02499ent IS
END c07s03b03x00p05n01i02499ent;

ARCHITECTURE c07s03b03x00p05n01i02499arch OF c07s03b03x00p05n01i02499ent IS

BEGIN
  TESTING: PROCESS
    function check (x : boolean) return boolean is
    begin
      return false;
    end;
    variable q1: boolean := true;
    variable q2: boolean ;
  BEGIN
    q2 := check (check (q1)); -- q2 should be false
    assert NOT(q2=FALSE) 
      report "***PASSED TEST: c07s03b03x00p05n01i02499" 
      severity NOTE;
    assert (q2=FALSE) 
      report "***FAILED TEST: c07s03b03x00p05n01i02499 - Actual parameter must belong to the subtype of the associated formal parameter."
      severity ERROR;
    wait;
  END PROCESS TESTING;

END c07s03b03x00p05n01i02499arch;
