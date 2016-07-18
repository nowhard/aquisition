library verilog;
use verilog.vl_types.all;
entity spi_slave_tb is
    generic(
        DATA_WIDTH      : integer := 16;
        BIT_CNT_WIDTH   : integer := 4
    );
end spi_slave_tb;
