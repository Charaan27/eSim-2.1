
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
-- $Id: tc54.vhd,v 1.2 2001-10-26 16:29:56 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

package c04s03b01x01p04n01i00054pkg is
  constant DC : STRING;               -- unconstrainted deferred constant
end c04s03b01x01p04n01i00054pkg;

package body c04s03b01x01p04n01i00054pkg is
  constant DC : STRING := "Hello";    -- constant completion
end c04s03b01x01p04n01i00054pkg;


use work.c04s03b01x01p04n01i00054pkg.all;
ENTITY c04s03b01x01p04n01i00054ent IS
END c04s03b01x01p04n01i00054ent;

ARCHITECTURE c04s03b01x01p04n01i00054arch OF c04s03b01x01p04n01i00054ent IS

BEGIN
  TESTING: PROCESS
  BEGIN
    assert NOT( DC'LENGTH = 5 and DC(1) = 'H' and DC(5) = 'o' )
      report "***PASSED TEST:c04s03b01x01p04n01i00054"
      severity NOTE;
    assert ( DC'LENGTH = 5 and DC(1) = 'H' and DC(5) = 'o' )
      report "***FAILED TEST:c04s03b01x01p04n01i00054 - A deferred constant declaration appear in a package declaration test failed."
      severity ERROR;
    wait;
  END PROCESS TESTING;

END c04s03b01x01p04n01i00054arch;
