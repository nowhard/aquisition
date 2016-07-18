library verilog;
use verilog.vl_types.all;
entity logic is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        adc_cnv         : out    vl_logic;
        adc_busy        : in     vl_logic;
        analog_mux_chn  : out    vl_logic_vector(2 downto 0);
        adc_miso        : in     vl_logic;
        adc_sck         : out    vl_logic;
        dac_reg_mosi    : in     vl_logic;
        dac_reg_sck     : out    vl_logic;
        cs_dac_reg      : out    vl_logic_vector(1 downto 0);
        enable          : in     vl_logic
    );
end logic;
