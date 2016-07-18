library verilog;
use verilog.vl_types.all;
entity spi_slave is
    generic(
        DATA_WIDTH      : integer := 16;
        BIT_CNT_WIDTH   : integer := 4
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ss              : in     vl_logic;
        mosi            : in     vl_logic;
        miso            : out    vl_logic;
        sck             : in     vl_logic;
        done            : out    vl_logic;
        din             : in     vl_logic_vector;
        dout            : out    vl_logic_vector
    );
end spi_slave;
