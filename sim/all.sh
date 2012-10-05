TESTS="morph/test1 morph/test2 win_8/test1 win_8/test2 win_8/test3 bi/test2"

for i in $TESTS; do
    echo -n $i " ... "
    ./sim.sh $i 2&>1 /dev/null
    if [ $? -ne 0 ]; then
        echo "error"
    else
        echo "ok"
    fi
done
