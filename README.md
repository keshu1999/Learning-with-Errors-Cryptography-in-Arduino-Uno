# Learning With Errors Cryptography in Arduino Uno Assembly

## Objective
The primary goal of this project is to explore and implement a cryptographic cipher based on the Learning with Errors (LWE) problem, particularly in the context of low processing power environments such as the Arduino Uno. This project aims to delve into the fundamentals of LWE cryptography, which is grounded in lattice problems assumed to be hard in the worst case, making it a robust candidate for post-quantum cryptographic systems.

### Introduction
As quantum computing approaches reality, cryptography for AVR processors like those used in Arduino devices must evolve to meet new challenges. This project presents a solution designed with both post-quantum cryptography and the limited processing power of AVR processors in mind. The solution leverages the hardness of the Learning with Errors problem in lattice cryptography, the Number Theoretic Transform (NTT), and the Knuth-Yao sampler for generating random Gaussian distributions.

## Theory

### Learning with Errors (LWE)
The Learning with Errors (LWE) problem involves solving a series of linear equations modulo a prime number, where each equation has a small error associated with it. This error complicates the problem, making traditional methods like Gaussian Elimination ineffective. The problem can be formalized as finding a hidden polynomial `s` from samples of pairs `(a, <a, s> + e)` in a finite field, where `e` is an error term.

The LWE problem is closely related to hard lattice problems like the Shortest Vector Problem (SVP) and the Shortest Independent Vectors Problem (SIVP), making it a promising foundation for cryptographic systems, especially in the context of post-quantum cryptography.


### Number Theoretic Transform (NTT)
The NTT is a variant of the Discrete Fourier Transform (DFT) applied over a finite field, and it is used to efficiently perform polynomial multiplication in cryptographic algorithms. This transform is essential in the LWE-based cryptosystem implemented in this project, as it allows for efficient computation of polynomial operations, reducing the time complexity from `O(n^2)` to `O(n log n)`.


### Knuth-Yao Sampler
The Knuth-Yao sampler is a method for generating random samples according to a specific probability distribution, crucial for the key generation and encryption phases of the LWE cryptosystem. It operates by traversing a Decision Diagram Graph (DDG) tree based on random bits, ensuring that the samples adhere to the desired distribution while minimizing the number of random bits required.


## Methodology
The cryptosystem implemented in this project consists of the following phases:
1. **Key Generation**
    * Sample two error polynomials `r1` and `r2` using the Knuth-Yao sampler.
    * Compute `NTT(p) = NTT(r1) - NTT(a) • NTT(r2)`.
    * The public key is `(NTT(a), NTT(p))`, and the private key is `NTT(r2)`.
2. **Encryption**
    * Encode the binary message `M` into a polynomial `M'`.
    * Sample three error polynomials `e1`, `e2`, and `e3`.
    * Compute the ciphertext `(NTT(C1), NTT(C2))` as:
```
NTT(C1) = NTT(a) ⋅ NTT(e1) + NTT(e2)
NTT(C2) = NTT(p) ⋅ NTT(e1) + NTT(e3 + M')
```

3. **Decryption**
    * Recover `M'` using the inverse NTT:
```
M' = INTT(NTT(r2) ⋅ NTT(C1) + NTT(C2))
```
    * Decode `M'` to retrieve the original message `M`.


## Code and Implementation
The code for the implementation is provided in this repository. It includes both the Arduino C++ implementation and the initial assembly code that was developed during the early stages of the project.

## Conclusion
This project represents an exploration into the field of LWE cryptography within constrained environments. The successful implementation of a cipher on an 8-bit AVR processor like the Arduino Uno demonstrates the potential for secure cryptographic systems even in low-power devices.
