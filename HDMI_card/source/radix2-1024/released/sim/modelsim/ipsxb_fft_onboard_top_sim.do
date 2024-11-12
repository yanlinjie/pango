file delete -force work
file delete -force vsim_ipsxb_fft_onboard_top.log
vlib  work
vmap  work work
vlog -incr -sv \
E:/pango/PDS_2022.2-SP1-Lite/arch/vendor/pango/verilog/simulation/GTP_APM_E1.v \
E:/pango/PDS_2022.2-SP1-Lite/arch/vendor/pango/verilog/simulation/GTP_DRM9K.v \
E:/pango/PDS_2022.2-SP1-Lite/arch/vendor/pango/verilog/simulation/GTP_GRS.v \
-f ./ipsxb_fft_onboard_top_filelist.f -l vlog.log
vsim {-voptargs=+acc} -suppress 12110 work.ipsxe_fft_onboard_top_tb -l vsim.log
do ipsxb_fft_onboard_top_wave.do
run -all
