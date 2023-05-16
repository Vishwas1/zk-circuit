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
- [Rank 1 Constraint system](https://docs.circom.io/background/background/#rank-1-constraint-system) for [constraints](https://docs.circom.io/circom-language/constraint-generation/)
- wasm to generate the [witness](https://docs.circom.io/background/background/#witness) file `witness.wtns` , 
- Outputting all these in `build` director.

> **Notes**: 
> 1. Make sure to create `build` folder in root directory before running this command
> 2. The set of constraints describing the circuit is called rank-1 constraint system (R1CS). In general, circuits will >    have several constraints (typically, one per multiplicative gate). Constraint must be quadratic, linear or constant >    equations

## Computing the witness with WebAssembly 

Create a file called `withness.json`


```
cd build/multiplier_js
node generate_witness.js multiplier.wasm ../../input.json ../witness.wtns
```

## Computing the proof

What we have so far...

1. We have `.r1cs` file that contains the constraints describing the circuit
2. We have `.wtns` file that contains all the computed signals

Now we are ready to calcualte the proof (zk): 

For that we will use snarkjs... 

So what do we want to proof ? 

> We would be able to prove that we know factors of 33 (`_c`) without revealing those numbers say `_a` and `_b`

SnarkJs uses [Groth16](https://eprint.iacr.org/2016/260) zk-Snark protocol. 

### Trusted Setup

We still have some work left before generating the proof.

To use Groth16, it requires a per-circuit **trusted setup**. This trusted setup consists of 2 parts:

1. The powers of tau, which is independent of circuit 
2. The pahase 2, which depends on the circuit

#### Power of tau

Start new power of tau ceremony: 
```
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
```

The we contribute to the ceremony
```
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
```

Note: Need to explain power of tau in better way

This is going to 1 time (I believe)

#### Phase 2


```
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
```

we generate a .zkey file that will contain the **proving** and **verification** keys together

```
cd build/multiplier_js
snarkjs groth16 setup ../multiplier.r1cs ../../pot12_final.ptau ../multiplier_0000.zkey
```
Contribute to the phase 2 of the ceremony
```
snarkjs zkey contribute ../multiplier_0000.zkey ../multiplier_0001.zkey --name="1st Contributor Name" -v
```

Export the verification key

```
snarkjs zkey export verificationkey ../multiplier_0001.zkey ../verification_key.json
```


## Generating proof


Once the witness is computed and the trusted setup is already executed, we can generate a zk-proof associated to the circuit and the witness

```
cd build
snarkjs groth16 prove multiplier_0001.zkey witness.wtns proof.json public.json
```


## Verifying Proof

```
cd build
snarkjs groth16 verify verification_key.json public.json proof.json
```