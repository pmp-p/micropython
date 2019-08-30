reset
echo $0
rm build/micropython.js build/firmware.*
emmake make FROZEN_DIR=modules
./node_run.sh pytest.py
