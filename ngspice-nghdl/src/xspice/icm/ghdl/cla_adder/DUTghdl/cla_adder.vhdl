library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
entity cla_adder is
port( A : in std_logic_vector(3 downto 0);
		B : in std_logic_vector(3 downto 0);
        cin : in std_logic;
        S : out std_logic_vector(3 downto 0);
        cout : out std_logic
        );
end cla_adder;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
entity cla_block is
port (
      P : in std_logic_vector(3 downto 0);
      G : in std_logic_vector(3 downto 0);
      cin : in std_logic;
	C : out std_logic_vector(4 downto 0)
    
     );
end cla_block;

architecture Behavioral of cla_block is
begin

C(0) <= cin;
C(1) <= G(0) or (P(0) and cin);
C(2) <= G(1) or (P(1) and G(0)) or (P(1) and P(0) and cin);
C(3) <= G(2) or (P(2) and G(1)) or (P(2) and P(1) and G(0)) or (P(2) and P(1) and P(0) and cin);
C(4) <= G(3) or (P(3) and G(2)) or (P(3) and P(2) and G(1)) or (P(3) and P(2) and P(1) and G(0)) or (P(3) and P(2) and P(1) and P(0) and cin);
 
end Behavioral;
architecture Behavioral of cla_adder is

signal P,G : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
signal C : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";

component cla_block is
port (
      P : in std_logic_vector(3 downto 0);
      G : in std_logic_vector(3 downto 0);
     cin : in std_logic;
	C : out std_logic_vector(4 downto 0) 
     );
end component;

begin

--first level
P <= A xor B;
G <= A and B;

--second level
gen_c : cla_block port map(P,G,C,cin);

--third level
S <= P xor C(3 downto 0);
cout <= C(4);

end Behavioral;
