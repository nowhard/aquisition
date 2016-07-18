library verilog;
use verilog.vl_types.all;
entity adc_read is
    generic(
        OUTPUT_DATA_WIDTH: integer := 18
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        sample_adc      : in     vl_logic;
        start_cycle_conv: in     vl_logic;
        halfcycle       : in     vl_logic;
        read_diapason   : in     vl_logic;
        complete        : out    vl_logic;
        data_out_1      : out    vl_logic_vector;
        data_out_2      : out    vl_logic_vector;
        cnv             : out    vl_logic;
        adc_busy        : in     vl_logic;
        miso            : in     vl_logic;
        sck             : out    vl_logic
    );
end adc_read;
