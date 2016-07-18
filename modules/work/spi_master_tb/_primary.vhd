library verilog;
use verilog.vl_types.all;
entity spi_master_tb is
    generic(
        CLK_DIV         : integer := 2;
        DATA_WIDTH      : integer := 16;
        BIT_CNT_WIDTH   : integer := 4
    );
end spi_master_tb;
