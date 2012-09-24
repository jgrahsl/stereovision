VHD="txt_util.vhd cam_pkg.vhd  sim_feed.vhd sim_sink.vhd pipe_head.vhd bit_ram.vhd line_buffer.vhd window.vhd morph_kernel.vhd translate.vhd translate_win.vhd morph_new.vhd morph_set.vhd tb_pipe.vhd"

 hist_x_new.vhd hist_y_new.vhd win_test.vhd morph_set.vhd

export PATH=$PATH:/opt/model6.4/linux
export LM_LICENSE_FILE=/opt/model6.4/lic.dat

mkdir -p simu simimg
rm -f sim.dat sim.out output.tiff simimg

for i in $VHD; do
    ghdl -i --workdir=simu --work=work $i
    if [ $? -ne 0 ]; then
        exit;
    fi
    vcom -93 -work work $i    
    if [ $? -ne 0 ]; then
        exit;
    fi
done


./tiff2dat.py input.tiff > sim.dat

#cat sim.dat sim.dat sim.dat > sim3.dat
#cp sim3.dat sim.dat

ghdl -m --workdir=simu --work=work tb 
#./tb --stop-time=100us 
vsim -c -do sim_batch.do

cat sim.out | ./dat2tiff.py output.tiff

convert input.tiff -scale 256x256 simimg/i.tiff
convert output.tiff -scale 256x256 simimg/o.tiff
eog simimg&

