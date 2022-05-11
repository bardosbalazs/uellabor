library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------
entity acu_mmio_edac_protected_shared_ram is
	generic (
		metastable_filter_bypass_master:				boolean;
		metastable_filter_bypass_slave:					boolean;
		metastable_filter_bypass_reset_error_flags_n:	boolean;
		metastable_filter_bypass_recover_fsm_n:			boolean;
		edac_latency:									integer range 1 to 10;
		memory_model:									string;
		prot_bram_scrubber_present:						boolean;
		prot_bram_scrb_prescaler_width:					integer range 1 to 18;
		prot_bram_scrb_timer_width:						integer range 1 to 24;
		init_from_file:									boolean;
		initfile_path:									string;
		initfile_format:								string;
		address_width:									integer range 3 to 16;
		data_width:										integer range 4 to 16;

		address_word_low:								integer range 0 to 65565;
		address_word_high:								integer range 0 to 65565;

		address_key_low:								integer range 0 to 65565;
		address_key_high:								integer range 0 to 65565;

		address_cipher_low:								integer range 0 to 65565;
		address_cipher_high:							integer range 0 to 65565;

		address_sbox_low:								integer range 0 to 65565;
		address_sbox_high:								integer range 0 to 65565
	);
	
	port (
		clk:						in	std_logic;
		raw_reset_n:				in	std_logic;
		
		-- ACU memory-mapped I/O (master) interface
		read_strobe_master:			in	std_logic;
		write_strobe_master:		in	std_logic;
		ready_2_master:				out	std_logic;
		address_from_master:		in	std_logic_vector (15 downto 0);
		data_from_master:			in	std_logic_vector (15 downto 0);
		data_2_master:				out	std_logic_vector (15 downto 0);
		
		-- Slave interface
		read_strobe_slave:			in	std_logic;
		write_strobe_slave:			in	std_logic;
		ready_2_slave:				out	std_logic;
		address_from_slave:			in	std_logic_vector (address_width-1 downto 0);
		data_from_slave:			in	std_logic_vector (data_width-1 downto 0);
		data_2_slave:				out	std_logic_vector (data_width-1 downto 0);
		
		-- FSM error interface
		invalid_state_error:		out	std_logic;
		recover_fsm_n:				in	std_logic;
		recover_fsm_n_ack:			out	std_logic;
		
		-- EDAC error interface
		reset_error_flags_n:		in	std_logic;
		reset_error_flags_n_ack:	out	std_logic;
		uncorrectable_error:		out	std_logic
	);
end entity acu_mmio_edac_protected_shared_ram;
---------------------------------------------------------------------------------------------------
architecture rtl of acu_mmio_edac_protected_shared_ram is

	-- Reset synchronizer resources
	signal ff_reset_n:						std_logic;
	signal as_reset_n:						std_logic;
		
	-- Metastable filter resources	
	signal ff_recover_fsm_n:				std_logic;
	signal recover_fsm_n_filtered:			std_logic;
	signal recover_fsm_n_internal:			std_logic;
	signal ff_read_strobe_master:			std_logic;
	signal read_strobe_master_filtered:		std_logic;
	signal read_strobe_master_internal:		std_logic;
	signal ff_write_strobe_master:			std_logic;
	signal write_strobe_master_filtered:	std_logic;
	signal write_strobe_master_internal:	std_logic;
	signal ff_read_strobe_slave:			std_logic;
	signal read_strobe_slave_filtered:		std_logic;
	signal read_strobe_slave_internal:		std_logic;
	signal ff_write_strobe_slave:			std_logic;
	signal write_strobe_slave_filtered:		std_logic;
	signal write_strobe_slave_internal:		std_logic;
	signal ff_reset_error_flags_n:			std_logic;
	signal reset_error_flags_n_filtered:	std_logic;
	signal reset_error_flags_n_internal:	std_logic;
	
	type state_t is (
		idle,
		master_write_1,	master_write_2,	master_write_3,	master_write_4,
		master_read_1, master_read_2, master_read_3,
		slave_write_1, slave_write_2,
		slave_read_1, slave_read_2, slave_read_3,
		edac_read_latency, edac_write_latency,
		wait_for_deassert_master_strobes, wait_for_deassert_slave_strobes,
		error
	);
	signal state: state_t;
	attribute syn_preserve: boolean;
	attribute syn_preserve of state:signal is true;
	signal return_state: state_t;

	signal s_data_2_master:			std_logic_vector (data_width-1 downto 0);
	signal s_ready_2_master:		std_logic;
	signal cs:						std_logic;
	signal we_edacram:				std_logic;
	signal re_edacram:				std_logic;
	signal waddress_edacram:		std_logic_vector (address_width-1 downto 0);
	signal raddress_edacram:		std_logic_vector (address_width-1 downto 0);
	signal data_2_edacram:			std_logic_vector (data_width-1 downto 0);
	signal data_from_edacram:		std_logic_vector (data_width-1 downto 0);
	signal we_ack_edacram:			std_logic;
	signal re_ack_edacram:			std_logic;

begin

	assert ( memory_model = "UNPROTECTED_REG" or memory_model = "UNPROTECTED_BRAM" or memory_model = "PROTECTED_BRAM" ) report "Memory model error!" severity failure;
	assert address_high > address_low report "ACU MMIO EDAC-PROTECTED SHARED RAM ADDRESSING ERROR!" severity failure;
	assert (address_high - address_low) = 2**address_width-1 report "ACU MMIO EDAC-PROTECTED SHARED RAM ADDRESSING ERROR!" severity failure;
	
	-- Reset circuitry: Active-LOW asynchronous assert, synchronous deassert with meta-stable filter.
	L_RESET_CIRCUITRY:	process ( clk, raw_reset_n )
	begin
		if ( raw_reset_n = '0' ) then
			ff_reset_n <= '0';
			as_reset_n <= '0';
		elsif ( rising_edge(clk) ) then
			ff_reset_n <= '1';
			as_reset_n <= ff_reset_n;
		end if;
	end process;
	
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	L_METASTBLE_FILTER_BLOCK: process ( clk, as_reset_n )
	begin
		if ( as_reset_n = '0' ) then
			ff_recover_fsm_n <= '1';
			recover_fsm_n_filtered <= '1';
			ff_read_strobe_master <= '0';
			read_strobe_master_filtered <= '0';
			ff_write_strobe_master <= '0';
			write_strobe_master_filtered <= '0';
			ff_read_strobe_slave <= '0';
			read_strobe_slave_filtered <= '0';
			ff_write_strobe_slave <= '0';
			write_strobe_slave_filtered <= '0';
			ff_reset_error_flags_n <= '1';
			reset_error_flags_n_filtered <= '1';
		elsif ( rising_edge(clk) ) then
			ff_recover_fsm_n <= recover_fsm_n;
			recover_fsm_n_filtered <= ff_recover_fsm_n;
			ff_read_strobe_master <= read_strobe_master;
			read_strobe_master_filtered <= ff_read_strobe_master;
			ff_write_strobe_master <= write_strobe_master;
			write_strobe_master_filtered <= ff_write_strobe_master;
			ff_read_strobe_slave <= read_strobe_slave;
			read_strobe_slave_filtered <= ff_read_strobe_slave;
			ff_write_strobe_slave <= write_strobe_slave;
			write_strobe_slave_filtered <= ff_write_strobe_slave;
			ff_reset_error_flags_n <= reset_error_flags_n;
			reset_error_flags_n_filtered <= ff_reset_error_flags_n;
		end if;
	end process;
	
	L_METASTABLE_FILTER_BYPASS: block
	begin
		recover_fsm_n_internal <= recover_fsm_n when metastable_filter_bypass_recover_fsm_n = true else recover_fsm_n_filtered;
		read_strobe_master_internal <= read_strobe_master when metastable_filter_bypass_master = true else read_strobe_master_filtered;
		write_strobe_master_internal <= write_strobe_master when metastable_filter_bypass_master = true else write_strobe_master_filtered;
		read_strobe_slave_internal <= read_strobe_slave when metastable_filter_bypass_slave = true else read_strobe_slave_filtered;
		write_strobe_slave_internal <= write_strobe_slave when metastable_filter_bypass_slave = true else write_strobe_slave_filtered;
		reset_error_flags_n_internal <= reset_error_flags_n when metastable_filter_bypass_reset_error_flags_n = true else reset_error_flags_n_filtered;
	end block;
	
	L_METASTABLE_FILTER_ACKNOWLEDGE: block
	begin
		recover_fsm_n_ack <= recover_fsm_n_internal;
		reset_error_flags_n_ack <= reset_error_flags_n_internal;
	end block;
	
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	L_LOCAL_ADDRESS_DECODER: block
	begin
		cs <= '1' when (unsigned(address_from_master) >= address_low and unsigned(address_from_master) <= address_high) else '0';
		data_2_master(data_width-1 downto 0) <= s_data_2_master when cs = '1' else (others => '0');
		data_2_master(15 downto data_width) <= (others => '0');
		ready_2_master <= s_ready_2_master when cs = '1' else '0';
	end block;
	
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	L_ACU_2_EDACRAM_ADAPTER: process ( clk, as_reset_n )
	begin
		if ( as_reset_n = '0' ) then
			state <= idle;
			return_state <= idle;
			s_ready_2_master <= '1';
			ready_2_slave <= '1';
			s_data_2_master <= (others => '0');
			data_2_slave <= (others => '0');
			invalid_state_error <= '0';
			we_edacram <= '0';
			re_edacram <= '0';
			waddress_edacram <= (others => '0');
			raddress_edacram <= (others => '0');
			data_2_edacram <= (others => '0');
		elsif ( rising_edge(clk) ) then
			case state is
				when idle	=>	s_ready_2_master <= '1';
								ready_2_slave <= '1';
								
								if ( write_strobe_master_internal = '1' ) then
									
									if ( cs = '1' ) then
										s_ready_2_master <= '0';
										state <= master_write_1;
									end if;
									
								elsif ( read_strobe_master_internal = '1' ) then
									
									if ( cs = '1' ) then
										s_ready_2_master <= '0';
										state <= master_read_1;
									end if;
									
								elsif ( write_strobe_slave_internal = '1' ) then
									ready_2_slave <= '0';
									state <= slave_write_1;
								elsif ( read_strobe_slave_internal = '1' ) then
									ready_2_slave <= '0';
									state <= slave_read_1;
								end if;
								
				----------------------------------------------------------------------------------------------
								
				when master_write_1	=>	waddress_edacram <= std_logic_vector(unsigned(address_from_master(address_width-1 downto 0)) - address_low);
										data_2_edacram <= data_from_master(data_width-1 downto 0);
										we_edacram <= '1';
										state <= master_write_2;
										
				when master_write_2	=>	we_edacram <= '0';
										return_state <= wait_for_deassert_master_strobes;
										state <= edac_write_latency;
										
				----------------------------------------------------------------------------------------------
				
				when master_read_1	=>	raddress_edacram <= std_logic_vector(unsigned(address_from_master(address_width-1 downto 0)) - address_low);
										re_edacram <= '1';
										state <= master_read_2;
										
				when master_read_2	=>	re_edacram <= '0';
										return_state <= master_read_3;
										state <= edac_read_latency;
										
				when master_read_3	=>	s_data_2_master <= data_from_edacram;
										state <= wait_for_deassert_master_strobes;
				
				----------------------------------------------------------------------------------------------
				
				when slave_write_1	=>	waddress_edacram <= address_from_slave;
										data_2_edacram <= data_from_slave;
										we_edacram <= '1';
										state <= slave_write_2;
										
				when slave_write_2	=>	we_edacram <= '0';
										return_state <= wait_for_deassert_slave_strobes;
										state <= edac_write_latency;
										
				----------------------------------------------------------------------------------------------
										
				when slave_read_1	=>	raddress_edacram <= address_from_slave;
										re_edacram <= '1';
										state <= slave_read_2;
										
				when slave_read_2	=>	re_edacram <= '0';
										return_state <= slave_read_3;
										state <= edac_read_latency;
										
				when slave_read_3	=>	data_2_slave <= data_from_edacram;
										state <= wait_for_deassert_slave_strobes;
				
				----------------------------------------------------------------------------------------------
				
				when edac_write_latency	=>	if ( we_ack_edacram = '1' ) then
												state <= return_state;
											end if;
				
				when edac_read_latency	=>	if ( re_ack_edacram = '1' ) then
												state <= return_state;
											end if;
											
				----------------------------------------------------------------------------------------------
											
				when wait_for_deassert_master_strobes	=>	if ( read_strobe_master_internal = '0' and write_strobe_master_internal = '0' ) then
																state <= idle;
															end if;
															
				when wait_for_deassert_slave_strobes	=>	if ( read_strobe_slave_internal = '0' and write_strobe_slave_internal = '0' ) then
																state <= idle;
															end if;
				
				----------------------------------------------------------------------------------------------
				
				when error	=>	-- reset all
								return_state <= idle;
								s_ready_2_master <= '1';
								ready_2_slave <= '1';
								s_data_2_master <= (others => '0');
								data_2_slave <= (others => '0');
								we_edacram <= '0';
								re_edacram <= '0';
								waddress_edacram <= (others => '0');
								raddress_edacram <= (others => '0');
								data_2_edacram <= (others => '0');
								
								if ( recover_fsm_n_internal = '0' ) then
									invalid_state_error <= '0';
									state <= idle;
								end if;
								
				when others	=>	invalid_state_error <= '1';
								state <= error;
			end case;
		end if;
	end process;
	
	L_MEM_UNPROTECTED_REG:	if ( memory_model = "UNPROTECTED_REG" ) generate
		L_EDACRAM:	entity work.edac_protected_ram(unprotected_reg)
						generic map (
							address_width						=> address_width,
							data_width							=> data_width,
							edac_latency						=> edac_latency,
							prot_bram_registered_in				=> false,
							prot_bram_registered_out			=> true,
							prot_bram_scrubber_present			=> prot_bram_scrubber_present,
							prot_bram_scrb_prescaler_width		=> prot_bram_scrb_prescaler_width,
							prot_bram_scrb_timer_width			=> prot_bram_scrb_timer_width,
							init_from_file						=> init_from_file,
							initfile_path						=> initfile_path,
							initfile_format						=> initfile_format
						)
							
						port map (
							clk					=> clk,
							as_reset_n			=> as_reset_n,
							reset_error_flags_n	=> reset_error_flags_n_internal,
							uncorrectable_error	=> uncorrectable_error,
							correctable_error	=> open,
							we					=> we_edacram,
							we_ack				=> we_ack_edacram,
							re					=> re_edacram,
							re_ack				=> re_ack_edacram,
							write_address 		=> waddress_edacram,
							read_address		=> raddress_edacram,
							data_in				=> data_2_edacram,
							data_out			=> data_from_edacram,
							error_injection								=> "00",
							force_scrubbing								=> '0',
							scrubber_invalid_state_error				=> open,
							scrubber_recover_fsm_n						=> '1',
							dbg_scrubber_invalid_state_error_injection 	=> '0'
						);
	end generate;
	
	L_MEM_UNPROTECTED_BRAM:	if ( memory_model = "UNPROTECTED_BRAM" ) generate
		L_EDACRAM:	entity work.edac_protected_ram(unprotected_bram)
						generic map (
							address_width						=> address_width,
							data_width							=> data_width,
							edac_latency						=> edac_latency,
							prot_bram_registered_in				=> false,
							prot_bram_registered_out			=> true,
							prot_bram_scrubber_present			=> prot_bram_scrubber_present,
							prot_bram_scrb_prescaler_width		=> prot_bram_scrb_prescaler_width,
							prot_bram_scrb_timer_width			=> prot_bram_scrb_timer_width,
							init_from_file						=> init_from_file,
							initfile_path						=> initfile_path,
							initfile_format						=> initfile_format
						)
							
						port map (
							clk					=> clk,
							as_reset_n			=> as_reset_n,
							reset_error_flags_n	=> reset_error_flags_n_internal,
							uncorrectable_error	=> uncorrectable_error,
							correctable_error	=> open,
							we					=> we_edacram,
							we_ack				=> we_ack_edacram,
							re					=> re_edacram,
							re_ack				=> re_ack_edacram,
							write_address 		=> waddress_edacram,
							read_address		=> raddress_edacram,
							data_in				=> data_2_edacram,
							data_out			=> data_from_edacram,
							error_injection								=> "00",
							force_scrubbing								=> '0',
							scrubber_invalid_state_error				=> open,
							scrubber_recover_fsm_n						=> '1',
							dbg_scrubber_invalid_state_error_injection 	=> '0'
						);
	end generate;
	
	L_MEM_PROTECTED_BRAM:	if ( memory_model = "PROTECTED_BRAM" ) generate
		L_EDACRAM:	entity work.edac_protected_ram(protected_bram)
						generic map (
							address_width						=> address_width,
							data_width							=> data_width,
							edac_latency						=> edac_latency,
							prot_bram_registered_in				=> false,
							prot_bram_registered_out			=> true,
							prot_bram_scrubber_present			=> prot_bram_scrubber_present,
							prot_bram_scrb_prescaler_width		=> prot_bram_scrb_prescaler_width,
							prot_bram_scrb_timer_width			=> prot_bram_scrb_timer_width,
							init_from_file						=> init_from_file,
							initfile_path						=> initfile_path,
							initfile_format						=> initfile_format
						)
							
						port map (
							clk					=> clk,
							as_reset_n			=> as_reset_n,
							reset_error_flags_n	=> reset_error_flags_n_internal,
							uncorrectable_error	=> uncorrectable_error,
							correctable_error	=> open,
							we					=> we_edacram,
							we_ack				=> we_ack_edacram,
							re					=> re_edacram,
							re_ack				=> re_ack_edacram,
							write_address 		=> waddress_edacram,
							read_address		=> raddress_edacram,
							data_in				=> data_2_edacram,
							data_out			=> data_from_edacram,
							error_injection								=> "00",
							force_scrubbing								=> '0',
							scrubber_invalid_state_error				=> open,
							scrubber_recover_fsm_n						=> '1',
							dbg_scrubber_invalid_state_error_injection 	=> '0'
						);
	end generate;

end architecture rtl;
---------------------------------------------------------------------------------------------------