file delete -force work
vlib  work
vmap  work work
vlog -incr +define+IPML_HSST_SPEEDUP_SIM \
E:/pango/PDS_2022.2-SP1-Lite/ip/ipml_hsst_eval/ipml_hsst/../../../../../arch/vendor/pango/verilog/simulation/modelsim10.2c/hsst_e2_source_codes/*.vp\
E:/pango/PDS_2022.2-SP1-Lite/ip/ipml_hsst_eval/ipml_hsst/../../../../../arch/vendor/pango/verilog/simulation/GTP_HSST_E2.v \
-f ./pango_hsst_top_filelist.f -l vlog.log
vsim -novopt +define+IPML_HSST_SPEEDUP_SIM work.hsst_test_top_tb -l vsim.log
do pango_hsst_top_wave.do
run -all
