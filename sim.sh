VHD="txt_util.vhd cam_pkg.vhd sim_feed.vhd sim_sink.vhd pipe_head.vhd hist_x_new.vhd bit_ram.vhd hist_y_new.vhd line_buffer.vhd window.vhd win_test.vhd translate.vhd tb_pipe.vhd"

export PATH=$PATH:/opt/model6.4/linux
export LM_LICENSE_FILE=/mnt/store/model/lic.dat

mkdir -p simu simimg
rm -f sim.dat sim.out output.tiff

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

ghdl -m --workdir=simu --work=work tb 

python tiff2dat.py  > sim.dat
#cat sim.dat sim.dat>  s.dat
#cp s.dat sim.dat
./tb --stop-time=7us 
cat sim.out | python dat2tiff.py

convert input.tiff -scale 256x256 simimg/i.tiff
convert output.tiff -scale 256x256 simimg/o.tiff
eog simimg&

#rm -R simimg