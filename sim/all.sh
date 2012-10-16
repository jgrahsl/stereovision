TESTS="morph/test1 morph/test2 win/test1 win/test2 win/test3 win/test4 win/test5 win/test6 win_8/test1 win_8/test2 win_8/test3 win_8/test4 win_8/test5 win_8/test6 win_16/test1 win_16/test2 win_16/test3 win_16/test4 win_16/test5 win_16/test6 bi/test1 bi/test1_split bi/test2"

for i in $TESTS; do
    echo -n $i " ... "
    ./sim.sh $i 2&> /dev/null
    if [ $? -ne 0 ]; then
        echo "error"
    else
        echo "ok"
    fi
done
