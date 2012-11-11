echo "Left X offset"
cat mx1.xml | ./off.py  x  |sort -n |head -n1
cat mx1.xml | ./off.py  x  |sort -n |tail -n1
cat mx1.xml | ./off.py  x  csv > mx1.csv

echo "Left Y offset"
cat my1.xml | ./off.py  y  |sort -n |head -n1
cat my1.xml | ./off.py  y  |sort -n |tail -n1
cat my1.xml | ./off.py  y  csv > my1.csv

echo "Right X offset"
cat mx2.xml | ./off.py  x  |sort -n |head -n1
cat mx2.xml | ./off.py  x  |sort -n |tail -n1
cat mx2.xml | ./off.py  x  csv > mx2.csv

echo "Right Y offset"
cat my2.xml | ./off.py  y  |sort -n |head -n1
cat my2.xml | ./off.py  y  |sort -n |tail -n1
cat my2.xml | ./off.py  y  csv > my2.csv
