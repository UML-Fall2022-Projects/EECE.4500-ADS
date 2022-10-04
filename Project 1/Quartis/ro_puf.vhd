library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.project_pkg.all;

entity ro_puf is
	generic (
		ro_length: positive := 13;
		ro_count: positive := 4
	);
	port (
		reset: in std_logic;
		enable: in std_logic;
		challenge: in std_logic_vector(0 to LOG(2, ro_count) - 1);
		response: out std_logic;
	);
end entity ro_puf;

architecture rtl of ro_puf is

begin

end architecture rtl;