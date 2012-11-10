echo "Left X offset"
cat mx1.xml | ./off.py  x  |sort -n |head -n1
cat mx1.xml | ./off.py  x  |sort -n |tail -n1

echo "Left Y offset"
cat my1.xml | ./off.py  y  |sort -n |head -n1
cat my1.xml | ./off.py  y  |sort -n |tail -n1

echo "Right X offset"
cat mx2.xml | ./off.py  x  |sort -n |head -n1
cat mx2.xml | ./off.py  x  |sort -n |tail -n1

echo "Right Y offset"
cat my2.xml | ./off.py  y  |sort -n |head -n1
cat my2.xml | ./off.py  y  |sort -n |tail -n1

