TESTS="morph/test1 morph/test2 win_8/test1 win_8/test2 win_8/test3"

for i in $TESTS; do
    ./sim.sh $i 2&>1 /dev/null
    if [ $? -ne 0 ]; then
        echo "$i ERR"
    else
        echo "$i OK"
    fi
done
