#!/bin/bash

cd build/multiplier_js
snarkjs groth16 setup ../multiplier.r1cs ../../pot12_final.ptau ../multiplier_0000.zkey
snarkjs zkey contribute ../multiplier_0000.zkey ../multiplier_0001.zkey --name="Vishwas1" -v
snarkjs zkey export verificationkey ../multiplier_0001.zkey ../verification_key.json