reset
echo $0
rm build/micropython.wasm build/firmware.*

make WASI=1 CLANG=1 SYSROOT="--sysroot /opt/sdk/wasi-sdk/share/wasi-sysroot" CROSS_COMPILE=/opt/sdk/wasi-sdk/bin/
echo
echo "-----  ./wat/wasmtime build/micropython.wasm -------"
echo
./wat/wasmtime build/micropython.wasm


