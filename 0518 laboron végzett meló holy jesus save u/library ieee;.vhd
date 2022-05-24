library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
---------------------------------------------------------------------------------------------------
entity acu_mmio_peripheral_template is
	generic (
		metastable_filter_bypass_acu:			boolean;
		metastable_filter_bypass_recover_fsm_n:	boolean;
		generate_intr:							boolean;

		address_word_low:						integer range 0 to 65535;
		address_word_high:						integer range 0 to 65535;

		address_key_low:						integer range 0 to 65535;
		address_key_high:						integer range 0 to 65535;

		address_cipher_low:						integer range 0 to 65535;
		address_cipher_high:					integer range 0 to 65535;

		address_sbox_low:						integer range 0 to 65535;
		address_sbox_high:						integer range 0 to 65535
		
	);
	
	port (

		clk:								in	std_logic;
		raw_reset_n:							in	std_logic;
		
		-- ACU memory-mapped I/O interface
		read_strobe_from_acu:						in	std_logic;
		write_strobe_from_acu:						in	std_logic;
		ready_2_acu:							out	std_logic;
		address_from_acu:						in	std_logic_vector (15 downto 0);
		data_from_acu:							in	std_logic_vector (15 downto 0);
		data_2_acu:							out	std_logic_vector (15 downto 0);
		
		-- ACU interrupt interface
		intr_rqst:							out	std_logic;
		intr_ack:							in	std_logic;
		
		-- User logic external interface

        output_enable:                      out std_logic;
		
		-- FSM error interface
		invalid_state_error:						out	std_logic;
		recover_fsm_n:							in	std_logic;
		recover_fsm_n_ack:						out	std_logic
	);
end entity acu_mmio_peripheral_template;
---------------------------------------------------------------------------------------------------
architecture rtl of acu_mmio_peripheral_template is

	-- Reset synchronizer resources
	signal ff_reset_n:						std_logic;
	signal as_reset_n:						std_logic;
		
	-- Metastable filter resources	
	signal ff_write_strobe_from_acu:		std_logic;
	signal write_strobe_from_acu_filtered:	std_logic;
	signal write_strobe_from_acu_internal:	std_logic;
	signal ff_read_strobe_from_acu:			std_logic;
	signal read_strobe_from_acu_filtered:	std_logic;
	signal read_strobe_from_acu_internal:	std_logic;
	signal ff_recover_fsm_n:				std_logic;
	signal recover_fsm_n_filtered:			std_logic;
	signal recover_fsm_n_internal:			std_logic;
	signal ff_intr_ack:						std_logic;
	signal intr_ack_filtered:				std_logic;
	signal intr_ack_internal:				std_logic;
	
	-- Interrupt generation resources
	signal user_intr_rqst:					std_logic;
	signal user_intr_rqst_d:				std_logic;
	signal user_intr_rqst_rising:			std_logic;
	
	type state_t is ( --ÁTÍRNI
		idle,
		write_word_address, write_key, write_cipher, write_sbox,
		read_word_address, read_key, read_cipher, read_sbox,
		wait_for_deassert_strobes,
		error
	);
	signal state: state_t;
	attribute syn_preserve: boolean;
	attribute syn_preserve of state:signal is true;
	
	signal cs:								std_logic;
	signal s_data_2_acu:					std_logic_vector (15 downto 0);
	signal s_ready_2_acu:					std_logic;
	signal adapter_invalid_state_error:		std_logic;
	
	-- User logic internal interface signals
	signal user_fsm_invalid_state_error:	std_logic;
	signal user_logic_intr_output:			std_logic;
	-- ...
	-- ...
	-- ...
	
begin
	
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
			ff_write_strobe_from_acu <= '0';
			write_strobe_from_acu_filtered <= '0';
			ff_read_strobe_from_acu <= '0';
			read_strobe_from_acu_filtered <= '0';
			ff_recover_fsm_n <= '1';
			recover_fsm_n_filtered <= '1';
			ff_intr_ack <= '0';
			intr_ack_filtered <= '0';
		elsif ( rising_edge(clk) ) then
			ff_write_strobe_from_acu <= write_strobe_from_acu;
			write_strobe_from_acu_filtered <= ff_write_strobe_from_acu;
			ff_read_strobe_from_acu <= read_strobe_from_acu;
			read_strobe_from_acu_filtered <= ff_read_strobe_from_acu;
			ff_recover_fsm_n <= recover_fsm_n;
			recover_fsm_n_filtered <= ff_recover_fsm_n;
			ff_intr_ack <= intr_ack;
			intr_ack_filtered <= ff_intr_ack;
		end if;
	end process;
	
	L_METASTABLE_FILTER_BYPASS: block
	begin
		write_strobe_from_acu_internal <= write_strobe_from_acu when metastable_filter_bypass_acu = true else write_strobe_from_acu_filtered;
		read_strobe_from_acu_internal <= read_strobe_from_acu when metastable_filter_bypass_acu = true else read_strobe_from_acu_filtered;
		recover_fsm_n_internal <= recover_fsm_n when metastable_filter_bypass_recover_fsm_n = true else recover_fsm_n_filtered;
		intr_ack_internal <= intr_ack when metastable_filter_bypass_acu = true else intr_ack_filtered;
	end block;
	
	L_METASTABLE_FILTER_ACKNOWLEDGE: block
	begin
		recover_fsm_n_ack <= recover_fsm_n_internal;
	end block;
	
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	L_INTR_GENERATION: block
	begin
		
		user_intr_rqst <= user_logic_intr_output when generate_intr = true else '0';
		
		process ( clk, as_reset_n )
		begin
			if ( as_reset_n = '0' ) then
				user_intr_rqst_d <= '0';
				intr_rqst <= '0';
			elsif ( rising_edge(clk) ) then
				user_intr_rqst_d <= user_intr_rqst;
				
				if ( intr_ack_internal = '1' ) then
					intr_rqst <= '0';
				elsif ( user_intr_rqst_rising = '1' ) then
					intr_rqst <= '1';
				end if;
				
			end if;
		end process;
		user_intr_rqst_rising <= user_intr_rqst and not user_intr_rqst_d;
		
	end block;
	
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	L_LOCAL_ADDRESS_DECODER: block
	begin
		cs <= '1' when (unsigned(address_from_acu) >= word_address_low and unsigned(address_from_acu) <= word_address_high) or

						(unsigned(address_from_acu) >= key_address_low and unsigned(address_from_acu) <= key_address_high) or

						(unsigned(address_from_acu) >= cipher_address_low and unsigned(address_from_acu) <= cipher_address_high) or

                        (unsigned(address_from_acu) >= sbox_address and unsigned(address_from_acu) <= sbox_address_high)

                        else '0';

		ready_2_acu <= s_ready_2_acu when cs = '1' else '0';
		data_2_acu <= s_data_2_acu when cs = '1' else (others => '0');
	end block;
	
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	L_ACU_MMIO_PERIPHERAL_ADAPTER: process ( clk, as_reset_n )
	begin
		if ( as_reset_n = '0' ) then
			state <= idle;
			s_ready_2_acu <= '0';
			s_data_2_acu <= (others => '0');
			adapter_invalid_state_error <= '0';
			
			-- ...
			-- ...
			-- ...
			
		elsif ( rising_edge(clk) ) then
			case state is
				when idle	=>	s_ready_2_acu <= '1';
								
								-- Handle ACU writes
								if ( write_strobe_from_acu_internal = '1' and cs = '1' ) then
									
									s_ready_2_acu <= '0';
									
									if ( unsigned(address_from_acu) >= word_address_low and unsigned(address_from_acu) <= word_address_high) then
										state <= write_word_address;
									elsif ( unsigned(address_from_acu) >= key_address_low and unsigned(address_from_acu) <= key_address_high) then
										state <= write_key;
									elsif (unsigned(address_from_acu) >= cipher_address_low and unsigned(address_from_acu) <= cipher_address_high) then
										state <= write_cipher;
									else ( unsigned(address_from_acu) >= sbox_address and unsigned(address_from_acu) <= sbox_address_high ) then
                                        state <= write_sbox;
                                    else
										state <= wait_for_deassert_strobes;
									end if;
									
								end if;
								
								-- Handle ACU reads
								if ( read_strobe_from_acu_internal = '1' and cs = '1') then
									
									s_ready_2_acu <= '0';
									
									if ( unsigned(address_from_acu) >= word_address_low and unsigned(address_from_acu) <= word_address_high ) then
										state <= read_word_address;
									elsif ( unsigned(address_from_acu) >= key_address_low and unsigned(address_from_acu) <= key_address_high) then
										state <= read_key;
									elsif ( unsigned(address_from_acu) >= cipher_address_low and unsigned(address_from_acu) <= cipher_address_high ) then
										state <= read_cipher;
                                    else (unsigned(address_from_acu) >= sbox_address and unsigned(address_from_acu) <= sbox_address_high) then
                                        state <= read_sbox;

									else
										state <= wait_for_deassert_strobes;
                                    
									end if;
									
								end if;
				
				----------------------------------------------------------------------------------------------

				when write_word_address_1	    =>      <= unsigned(address_from_acu);
                                                        write_strobe_from_acu <= 1; 
                                                        state <= write_word_address_2;

            -   when write_word_address_2	    =>		write_strobe_from_acu <= 0;
                                                        state <= wait_for_deassert_strobes;

                when write_word_data_1     		=>    	<= unsigned(data_from_acu);
                                                    	write_strobe_from_acu <= 1; 
                                                        state <= write_word_data_2;
				     
                when write_word_data_2      	=>  	state <= write_word_data_3;
				
				when write_word_data_3 			=>		write_strobe_from_acu <= 0;
														state <= wait_for_deassert_strobes;                                   
-------------------------------------------------------------------------------------------------------------------------

				when write_key_address_1	    =>      <= unsigned(address_from_acu);
                                                        write_strobe_from_acu <= 1; 
                                                        state <= write_key_address_2;

            -   when write_key_address_2	    =>		write_strobe_from_acu <= 0;
                                                        state <= wait_for_deassert_strobes;


                when write_key_data_1     		=>    	<= unsigned(data_from_acu);
                                                    	write_strobe_from_acu <= 1; 
                                                        state <= write_key_data_2;
				     
                when write_key_data_2      		=>  	state <= write_key_data_3;
				
				when write_key_data_3 			=>		write_strobe_from_acu <= 0;
														state <= wait_for_deassert_strobes;

-------------------------------------------------------------------------------------------------------------------------

				when write_cipher_address_1	    =>      <= unsigned(address_from_acu);
                                                        write_strobe_from_acu <= 1; 
                                                        state <= write_cipher_address_2;

            -   when write_cipher_address_2	    =>		write_strobe_from_acu <= 0;
                                                        state <= wait_for_deassert_strobes;


                when write_cipher_data_1     	=>    	<= unsigned(data_from_acu);
                                                    	write_strobe_from_acu <= 1; 
                                                        state <= write_cipher_data_2;
				     
                when write_cipher_data_2      	=>  	state <= write_cipher_data_3;
				
				when write_cipher_data_3 		=>		write_strobe_from_acu <= 0;
														state <= wait_for_deassert_strobes;

-------------------------------------------------------------------------------------------------------------------------

        		when write_sbox_1     => 	
                when write_sbox_2     => 	state <=wait_for_deassert_strobes;
                               			    			 --...
                               			   			  --...
				
                     --address from acubol kell majd kiszamitani a cimet                                       
			--when read_word_address_1		=> word_address <= address_from_acu;
            --                                        state <= read_word_data;
            --  when read_word_address_2	    => state <=read_word_address_3;
            -- when read_word_address_3	    =>

                when read_word_data_1 =>
                when read_word_data_2 => state <= read_word_data_3;
                when read_word_data_3 => state <=wait_for_deassert_strobes;
									
				when read_key_1	=>	-- ...
                when read_key_2	=>	state <= read_key_3;-- ...
                when read_key_3	=>	state <=wait_for_deassert_strobes;
									-- ...
									-- ...
									
				when read_cipher_1	=>	-- ...
                when read_cipher_2	=> state <= read_cipher_3;
                when read_cipher_3	=> state <=wait_for_deassert_strobes;
									-- ...
									-- ...
                
             	when read_sbox_1    => 	
                when read_sbox_2    => state <= read_sbox_3; 	--...
                when read_sbox_3    => state <=wait_for_deassert_strobes;
                           				         --...
                            					        --...
				
				----------------------------------------------------------------------------------------------
				
				when wait_for_deassert_strobes	=>	if ( read_strobe_from_acu_internal = '0' and write_strobe_from_acu_internal = '0' ) then
														state <= idle;
													end if;
													
				----------------------------------------------------------------------------------------------
				
				when error	=>	-- reset all
								s_ready_2_acu <= '0';
								s_data_2_acu <= (others => '0');
								-- ...
								-- ...
								-- ...
								
								if ( recover_fsm_n_internal = '0' ) then
									adapter_invalid_state_error <= '0';
									state <= idle;
								end if;
								
				when others	=>	adapter_invalid_state_error <= '1';
								state <= error;
			end case;
		end if;
	end process;
	


	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
L_WORD_MEMORY_MODULE: entity work.sprf_async_out(rtl) --Üzenet memóriája
                                   
                                    port map(
                                    clk => clk,
                                    we =>write_strobe_word,
                                    addr_write => address_from_acu, 
                                    addr_read => 
                                    data_in =>data_from_acu,
                                    data_out =>data_2_acu



                                    );
    
L_KEY_MEMORY_MODULE: entity work.sprf_async_out(rtl) -- Kulcs memóriája
                                   
                                    port map(
                                    clk => clk,
                                    we =>write_strobe_key,
                                    addr_write => address_from_acu,
                                    addr_read => 
                                    data_in =>data_from_acu,
                                    data_out =>data_2_acu



                                    );
                                    
L_CIPHER_MEMORY_MODULE: entity work.sprf_async_out(rtl) -- Cipher memóriája
                                   
                                    port map(
                                    clk => clk,
                                    we =>write_strobe_cipher,
                                    addr_write => address_from_acu,
                                    addr_read => 
                                    data_in =>data_from_acu,
                                    data_out =>data_2_acu



                                    );
    
L_SBOX_MEMORY_MODULE: entity work.sprf_async_out(rtl) --SBOX konstansok memóriája
                                   
                                    port map(
                                    clk => clk,
                                    we =>write_strobe_sbox,
                                    addr_write =>address_from_acu,
                                    addr_read => 
                                    data_in =>data_from_acu,
                                    data_out =>data_2_acu



                                    );
	
	--------------------------------------------------------
	--------------------------------------------------------
	--------------------------------------------------------
	
	invalid_state_error <= 	adapter_invalid_state_error or user_fsm_invalid_state_error;

end architecture rtl;
---------------------------------------------------------------------------------------------------
