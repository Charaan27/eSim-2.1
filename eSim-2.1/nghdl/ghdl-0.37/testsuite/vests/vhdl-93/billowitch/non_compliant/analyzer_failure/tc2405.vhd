
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
-- $Id: tc2405.vhd,v 1.2 2001-10-26 16:30:18 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

ENTITY c07s03b02x00p08n05i02405ent IS
END c07s03b02x00p08n05i02405ent;

ARCHITECTURE c07s03b02x00p08n05i02405arch OF c07s03b02x00p08n05i02405ent IS
  type ARRAY_TYPE is array (INTEGER range <>) of BOOLEAN;
  type RECORD_TYPE is record
                        E1,E2,E3 : BOOLEAN;
                      end record;
  signal S2 : RECORD_TYPE;
BEGIN
  TESTING: PROCESS
  BEGIN
    S2 <= (E2 => TRUE, others | E1 => FALSE); -- Failure_here
    -- SEMANTIC ERROR:  "others" must be only choice in an association.
    assert FALSE 
      report "***FAILED TEST: c07s03b02x00p08n05i02405 - Only one others association is allowed."
      severity ERROR;
    wait;
  END PROCESS TESTING;

END c07s03b02x00p08n05i02405arch;
