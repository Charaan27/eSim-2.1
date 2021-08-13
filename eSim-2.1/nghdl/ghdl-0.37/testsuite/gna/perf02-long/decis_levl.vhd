library ieee;
use ieee.std_logic_1164.all;


library ieee;
use ieee.numeric_std.all;

entity decis_levl is
	port (
		clk : in  std_logic;
		ra0_data : out std_logic_vector(31 downto 0);
		ra0_addr : in  std_logic_vector(4 downto 0)
	);
end decis_levl;
architecture augh of decis_levl is

	-- Embedded RAM

	type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
	signal ram : ram_type := ("00000000000000000000000100011000", "00000000000000000000001001000000", "00000000000000000000001101110000", "00000000000000000000010010110000", "00000000000000000000010111110000", "00000000000000000000011101001000", "00000000000000000000100010100000", "00000000000000000000101000011000", "00000000000000000000101110010000", "00000000000000000000110100110000", "00000000000000000000111011001000", "00000000000000000001000010010000", "00000000000000000001001001011000", "00000000000000000001010001010000", "00000000000000000001011001010000", "00000000000000000001100010010000", "00000000000000000001101011010000", "00000000000000000001110101100000", "00000000000000000001111111111000", "00000000000000000010001100001000", "00000000000000000010011000011000", "00000000000000000010100111011000", "00000000000000000010110110010000", "00000000000000000011001001100000", "00000000000000000011011100101000", "00000000000000000011110111100000", "00000000000000000100010010011000", "00000000000000000100111111101000", "00000000000000000101101100111000", "00000000000000000111111111111111", "00000000000000000000000000000000", "00000000000000000000000000000000");


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
