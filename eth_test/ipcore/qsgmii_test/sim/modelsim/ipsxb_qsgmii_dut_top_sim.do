file delete -force work
vlib  work
vmap  work work
vlog -incr +define+IPM_HSST_SPEEDUP_SIM \
E:/pango/PDS_2022.2-SP1-Lite/ip/system_ip/ipsxb_qsgmii/ipsxb_qsgmii_eval/ipsxb_qsgmii/../../../../../arch/vendor/pango/verilog/simulation/modelsim10.2c/hsst_e2_source_codes/*.vp\
E:/pango/PDS_2022.2-SP1-Lite/ip/system_ip/ipsxb_qsgmii/ipsxb_qsgmii_eval/ipsxb_qsgmii/../../../../../arch/vendor/pango/verilog/simulation/GTP_GRS.v \
E:/pango/PDS_2022.2-SP1-Lite/ip/system_ip/ipsxb_qsgmii/ipsxb_qsgmii_eval/ipsxb_qsgmii/../../../../../arch/vendor/pango/verilog/simulation/GTP_HSST_E2.v \
E:/pango/PDS_2022.2-SP1-Lite/ip/system_ip/ipsxb_qsgmii/ipsxb_qsgmii_eval/ipsxb_qsgmii/../../../../../arch/vendor/pango/verilog/simulation/GTP_DRM9K.v \
E:/pango/PDS_2022.2-SP1-Lite/ip/system_ip/ipsxb_qsgmii/ipsxb_qsgmii_eval/ipsxb_qsgmii/../../../../../arch/vendor/pango/verilog/simulation/GTP_IOBUF.v
vlog -v +define+IPM_HSST_SPEEDUP_SIM+IPS_QSGMII_SPEEDUP_SIM -f ./ipsxb_qsgmii_dut_top_filelist.f -l vlog.log
vsim -novopt +define+IPM_HSST_SPEEDUP_SIM+IPS_QSGMII_SPEEDUP_SIM work.ipsxb_qsgmii_dut_top_tb -l sim.log
do ipsxb_qsgmii_dut_top_sim_wave.do
run -all
