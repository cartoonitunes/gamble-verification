#!/bin/bash
set -e

TARGET="0xaf5558b1b834be59b9ff94e05c17bae9257c9bf1"
EXPECTED_RUNTIME="$(cat expected-runtime.hex)"
EXPECTED_CREATION="$(cat expected-creation.hex)"

echo "=== Gamble Contract Bytecode Verification ==="
echo "Contract: $TARGET"
echo ""

# Build serpent commit fd9b0b6 and compile
docker run --rm --platform linux/amd64 -v "$(pwd):/work" serpent-compiler bash -c '
cd /serpent
git checkout fd9b0b6 -f -q 2>/dev/null
rm -rf build/ dist/ *.egg-info /usr/local/lib/python2.7/dist-packages/ethereum_serpent*
python2 setup.py build_ext --inplace -q 2>/dev/null
python2 setup.py install -q 2>/dev/null
python2 -c "
import serpent, binascii
code = open(\"/work/gamble.se\").read()
r = serpent.compile(code)
open(\"/work/compiled.hex\",\"w\").write(binascii.hexlify(r).decode())
"'

COMPILED=$(cat compiled.hex)
RUNTIME=$(python3 -c "print(open('compiled.hex').read().strip()[36:])")

echo "Compiled size: $(echo ${#COMPILED} / 2 | bc) bytes"
echo "Runtime size:  $(echo ${#RUNTIME} / 2 | bc) bytes"
echo ""

if [ "$COMPILED" = "$EXPECTED_CREATION" ]; then
    echo "✅ CREATION TX MATCH: compiled == on-chain creation bytecode"
else
    echo "❌ CREATION TX MISMATCH"
fi

if [ "$RUNTIME" = "$EXPECTED_RUNTIME" ]; then
    echo "✅ RUNTIME MATCH: compiled runtime matches on-chain deployed bytecode"
else
    echo "❌ RUNTIME MISMATCH"
    echo "Checking first 1114 bytes (deployed portion only)..."
    DEPLOYED_RT=$(echo $EXPECTED_RUNTIME | cut -c1-2228)
    RT_PREFIX=$(echo $RUNTIME | cut -c1-2228)
    if [ "$DEPLOYED_RT" = "$RT_PREFIX" ]; then
        echo "✅ DEPLOYED RUNTIME MATCH: first 1114 bytes identical"
    fi
fi
