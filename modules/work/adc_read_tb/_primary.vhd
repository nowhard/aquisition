library verilog;
use verilog.vl_types.all;
entity adc_read_tb is
    generic(
        OUTPUT_DATA_WIDTH: integer := 24
    );
end adc_read_tb;
