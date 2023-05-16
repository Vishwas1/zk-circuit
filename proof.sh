#!/bin/bash

cd build
snarkjs groth16 prove multiplier_0001.zkey witness.wtns proof.json public.json
