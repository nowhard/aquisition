library verilog;
use verilog.vl_types.all;
entity spi_master is
    generic(
        CLK_DIV         : integer := 2;
        DATA_WIDTH      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        miso            : in     vl_logic;
        mosi            : out    vl_logic;
        sck             : out    vl_logic;
        start           : in     vl_logic;
        data_in         : in     vl_logic_vector;
        data_out        : out    vl_logic_vector;
        busy            : out    vl_logic;
        new_data        : out    vl_logic
    );
end spi_master;
