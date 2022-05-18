library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sprf_async_out is
	port (
		clk:		in	std_logic;
		we:			in	std_logic;
		addr_write:		in	std_logic_vector (15 downto 0);
		addr_read:		in	std_logic_vector (15 downto 0);
		data_in:	in	std_logic_vector (7 downto 0);
		data_out:	out std_logic_vector (7 downto 0)
);
end entity sprf_async_out;

architecture rtl of sprf_async_out is

	type content_t is array (0 to 15) of std_logic_vector (7 downto 0);
	signal content: content_t := (
		0 => X"1111",
		1 => X"0000"
	);

begin

  L_WRITE: process (clk)
  begin
    if ( rising_edge(clk) ) then
		if ( we = '1' ) then
			content(to_integer(unsigned(addr))) <= data_in;
		end if;
		data_out <= content(to_integer(unsigned(addr)));
	end if;
  end process;
  
end architecture rtl;
