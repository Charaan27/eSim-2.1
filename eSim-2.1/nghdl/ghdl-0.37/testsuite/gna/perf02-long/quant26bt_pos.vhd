library ieee;
use ieee.std_logic_1164.all;


library ieee;
use ieee.numeric_std.all;

entity quant26bt_pos is
	port (
		clk : in  std_logic;
		ra0_data : out std_logic_vector(31 downto 0);
		ra0_addr : in  std_logic_vector(4 downto 0)
	);
end quant26bt_pos;
architecture augh of quant26bt_pos is

	-- Embedded RAM

	type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
	signal ram : ram_type := ("00000000000000000000000000111101", "00000000000000000000000000111100", "00000000000000000000000000111011", "00000000000000000000000000111010", "00000000000000000000000000111001", "00000000000000000000000000111000", "00000000000000000000000000110111", "00000000000000000000000000110110", "00000000000000000000000000110101", "00000000000000000000000000110100", "00000000000000000000000000110011", "00000000000000000000000000110010", "00000000000000000000000000110001", "00000000000000000000000000110000", "00000000000000000000000000101111", "00000000000000000000000000101110", "00000000000000000000000000101101", "00000000000000000000000000101100", "00000000000000000000000000101011", "00000000000000000000000000101010", "00000000000000000000000000101001", "00000000000000000000000000101000", "00000000000000000000000000100111", "00000000000000000000000000100110", "00000000000000000000000000100101", "00000000000000000000000000100100", "00000000000000000000000000100011", "00000000000000000000000000100010", "00000000000000000000000000100001", "00000000000000000000000000100000", "00000000000000000000000000100000", "00000000000000000000000000000000");


	-- Little utility functions to make VHDL syntactically correct
	--   with the syntax to_integer(unsigned(vector)) when 'vector' is a std_logic.
	--   This happens when accessing arrays with <= 2 cells, for example.

	function to_integer(B: std_logic) return integer is
		variable V: std_logic_vector(0 to 0);
	begin
		V(0) := B;
		return to_integer(unsigned(V));
	end;

	function to_integer(V: std_logic_vector) return integer is
	begin
		return to_integer(unsigned(V));
	end;

begin

	-- The component is a ROM.
	-- There is no Write side.

	-- The Read side (the outputs)

	ra0_data <= ram( to_integer(ra0_addr) );

end architecture;
