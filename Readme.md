## Prerequisites

### Download Circom

```
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

### Install circom

```
git clone https://github.com/iden3/circom.git
cd circom
cargo build --release
cargo install --path circom
circom --help
```

### Install snarkjs

```
npm install -g snarkjs
```
## Writing the circuit code 

```
pragma circom  2.0.0;
template Multiplier() {
    signal input _a;
    signal input _b;
    signal output _c;
    _c <== _a*_b;
}

component main = Multiplier();
```
Store this in file called `multiplier.circom`

## Complilation

Lets compile this code 

```bash
circom multiplier.circom --r1cs --wasm --sym --c -o build
```
Here, we are compiling our circuit code into to 
- [Rank 1 Constraint system](https://docs.circom.io/background/background/#rank-1-constraint-system) for binary format
- wasm to generate the [witness](https://docs.circom.io/background/background/#witness), 
- a symbols file required for debugging
- Complied C code 
- Outputting all these in `build` director.


## Computing the witness with WebAssembly 

Create a file called `withness.json`


```
cd build/multiplier_js
node generate_witness.js multiplier.wasm ../../input.json witness.wtns
```