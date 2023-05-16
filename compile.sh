#!/bin/bash

rm -rf build
mkdir build

## compilation
circom multiplier.circom --r1cs --wasm --sym -o build

## Computing witness
cd build/multiplier_js
node generate_witness.js multiplier.wasm ../../input.json ../witness.wtns


## 
