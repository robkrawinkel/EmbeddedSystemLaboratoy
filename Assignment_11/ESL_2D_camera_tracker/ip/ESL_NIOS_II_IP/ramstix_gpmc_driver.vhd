--
-- @file ramstix_gpmc_driver.vhd
-- @brief FPGA implementation of the general purpose memory controller.
-- @author Gerben Wevers, University of Twente 2013
-- @author Jan Jaap Kempenaar, Sander Grimm, University of Twente 2014
--

-- 
-- Please refer to http://www.ti.com/lit/ug/spruf98x/spruf98x.pdf for the Technical Reference Manual of 
-- the OMAP35x processor, where the GPMC interface is fully explained (Ch. 11.1).
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ramstix_gpmc_driver is
  generic(
    DATA_WIDTH           : integer := 16;
    GPMC_ADDR_WIDTH_HIGH : integer := 10;
    GPMC_ADDR_WIDTH_LOW  : integer := 1;
    -- RAM_SIZE should be a power of 2
    RAM_SIZE             : integer := 32
  );
  port(
    clk           : in    std_logic;
    -- Input (data from fpga to gumstix) at IDX 0 and IDX 1
    in_reg0 : in std_logic_vector(16 - 1 downto 0);
	 in_reg1 : in std_logic_vector(16 - 1 downto 0);

    -- Output (data from gumstix to fpga) at IDX 2 and IDX 3
    out_reg2      : out   std_logic_vector(16 - 1 downto 0);
	 out_reg3      : out   std_logic_vector(16 - 1 downto 0);

	 -- GPMC bus signals
    GPMC_DATA     : inout std_logic_vector(16 - 1 downto 0);
    GPMC_ADDR     : in    std_logic_vector(GPMC_ADDR_WIDTH_HIGH downto GPMC_ADDR_WIDTH_LOW);
    GPMC_nPWE     : in    std_logic;
    GPMC_nOE      : in    std_logic;
    GPMC_FPGA_IRQ : in    std_logic;
    GPMC_nCS6     : in    std_logic;
    GPMC_CLK      : in    std_logic
  );
end ramstix_gpmc_driver;

architecture behavior of ramstix_gpmc_driver is

  -- data_out register, which will be only active if both the chip-select and read-enable are negative
  signal gpmc_data_out : std_logic_vector(15 downto 0);

  -- register set
  type mem_type is array (0 to RAM_SIZE - 1) of std_logic_vector(16 - 1 downto 0);
  signal ram : mem_type;
  signal gpmc_data_in : std_logic_vector(16 - 1 downto 0)                             := (others => '0');
  signal gpmc_addr_in : std_logic_vector(GPMC_ADDR_WIDTH_HIGH - GPMC_ADDR_WIDTH_LOW downto 0) := (others => '0');
  signal gpmc_ncs     : std_logic                                                             := '0';
  signal gpmc_nwe     : std_logic                                                             := '0';
  signal gpmc_nre     : std_logic                                                             := '0';

begin
  process_input : process(clk)
  begin
    if (rising_edge(clk)) then
      gpmc_data_in <= GPMC_DATA;
      gpmc_addr_in <= GPMC_ADDR;
      gpmc_ncs     <= GPMC_nCS6;
      gpmc_nwe     <= GPMC_nPWE;
      gpmc_nre     <= GPMC_nOE;
    end if;
  end process process_input;

  process_gpmc : process(clk, GPMC_nCS6, GPMC_DATA, GPMC_ADDR, in_reg0, in_reg1, gpmc_addr_in)
    variable gpmc_ram_addr : integer;
  begin
    -- A negative chipselect (GPMC_nCS6) indicates a read- or write operation on the GPMC bus.
    gpmc_ram_addr := to_integer(unsigned(gpmc_addr_in));

    if (rising_edge(clk)) then
      if (gpmc_ncs = '0') then
        if (gpmc_nwe = '0') then
          if (gpmc_ram_addr < RAM_SIZE) then
            ram(gpmc_ram_addr) <= gpmc_data_in;
          end if;
        elsif (gpmc_nre = '0') then
          if (gpmc_ram_addr < RAM_SIZE) then
            gpmc_data_out <= ram(gpmc_ram_addr);
          else
            gpmc_data_out <= x"0000";
          end if;
        end if;
      end if;
		
		   -- example: you can read from idx 0 and idx 1 from gumstix to get your data from FPGA
			ram(0)   <= in_reg0(15 downto 0);
			ram(1)   <= in_reg1(15 downto 0);
			
			-- example: you can write to idx 2 and idx 3 from gumstix to send your data to FPGA
			out_reg2(15 downto 0) <= ram(2);
			out_reg3(15 downto 0) <= ram(3);

    end if;


  end process process_gpmc;

  -- Place data on the bus only if both the chip-select and read-enable are negative
  GPMC_DATA <= gpmc_data_out when (GPMC_nCS6 = '0' AND GPMC_nOE = '0') else (others => 'Z');

end;
