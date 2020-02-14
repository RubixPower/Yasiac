mkdir ./compiled
python3 setup.py  build_ext --inplace
mv ./*.so ./compiled/
rm *.c
