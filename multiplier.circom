pragma circom  2.0.0;
template Multiplier() {
    signal input _a;
    signal input _b;
    signal output _c;
    _c <== _a*_b;
}


component main = Multiplier();

