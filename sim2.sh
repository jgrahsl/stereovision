VHD="ipcore_dir/mcb_pixel_fifo.vhd ipcore_dir/mcb_aux_fifo.vhd txt_util.vhd cam_pkg.vhd sim_feed.vhd sim_sink.vhd pipe_head.vhd hist_x_new.vhd bit_ram.vhd hist_y_new.vhd line_buffer.vhd window.vhd win_test.vhd morph_kernel.vhd translate.vhd morph.vhd morph_set.vhd mcb_feed.vhd mcb_sink.vhd tb_pipe_mcb.vhd"

export PATH=$PATH:/opt/model6.4/linux
export LM_LICENSE_FILE=/opt/model6.4/lic.dat

mkdir -p simu simimg
rm -f sim.dat sim.out output.tiff simimg
vlib work
for i in $VHD; do
echo $i
#    ghdl -i --workdir=simu --work=work $i
#    if [ $? -ne 0 ]; then
#        exit;
#    fi
    vcom -93 -work work $i    
    if [ $? -ne 0 ]; then
        exit;
    fi
done


vsim -c -do sim_batch.do
