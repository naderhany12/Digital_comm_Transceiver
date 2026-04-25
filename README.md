# 📡 Random Process Analysis — Ensemble & Ergodicity Study

## 📋 Table of Contents

### ⚙️ Setup & Configuration
- [I. Problem Description](#i-problem-description)
- [II. Introduction](#ii-introduction)
- [III. Control Flags](#iii-control-flags)
- [IV. Generation of Data](#iv-generation-of-data)

### 🔧 Ensemble Construction
- [V. Creating the Unipolar Ensemble](#v-creating-the-unipolar-ensemble)
- [VI. Creating the Polar NRZ Ensemble](#vi-creating-the-polar-nrz-ensemble)
- [VII. Creating the Polar RZ Ensemble](#vii-creating-the-polar-rz-ensemble)
- [VIII. Applying Random Initial Time Shifts](#viii-applying-random-initial-time-shifts)
- [IX. Preparing Cell Arrays for Analysis](#ix-preparing-cell-arrays-for-analysis)

### 💻 Source
- [Full MATLAB Code](#full-matlab-code)

---

## ⚙️ Setup & Configuration

### I. Problem Description
The objective of this project is to model digital baseband communication line codes as stochastic random processes. By simulating large ensembles of waveforms, we investigate and verify core statistical properties including expected values, Wide-Sense Stationarity (WSS), Ergodicity, and Power Spectral Density (PSD).

### II. Introduction
In digital communications, a transmitted signal is not deterministic; it depends on a random sequence of bits. When we combine this random data with a deterministic pulse shape and an arbitrary, random time-delay, we create an ensemble of possible transmitted waveforms. This repository statistically analyzes three primary signaling schemes: Unipolar NRZ, Polar NRZ, and Polar RZ.

### III. Control Flags
The simulation behavior is entirely driven by a centralized block of parameters:

| Parameter | Value | Description |
| :--- | :--- | :--- |
| `N_bits` | 100 | Number of bits per realization |
| `N_realizations` | 500 | Total number of generated waveforms |
| `Pw` | 0.07 s | Pulse width of the bit |
| `Ts` | 0.01 s | Time sample duration ($F_s = 100$ Hz) |
| `L` | 7 | Number of samples per symbol period |
| `A` | 4 V | Signal amplitude |
| `N_fft` | 1024 | FFT size for high-resolution PSD |

### IV. Generation of Data
The foundational data is a randomized matrix of binary digits ($0$s and $1$s) created using MATLAB's `randi` function, shaped to contain 500 rows (realizations) and 100 columns (bits).

---

## 🔧 Ensemble Construction

### V. Creating the Unipolar Ensemble
The binary data is mapped to voltage levels where $0 \rightarrow 0$ V and $1 \rightarrow A$ V. We apply a full-width rectangular pulse shape (`ones(1, L)`) and upsample the data using the Kronecker tensor product (`kron`).

### VI. Creating the Polar NRZ Ensemble
The binary data is mapped symmetrically where $0 \rightarrow -A$ V and $1 \rightarrow A$ V. Similar to Unipolar, a full-width non-return-to-zero pulse is applied.

### VII. Creating the Polar RZ Ensemble
The data is mapped to $-A$ V and $A$ V. However, the pulse shape is modified to return to zero halfway through the bit period (`[ones(1, floor(L/2)), zeros(1, ceil(L/2))]`).

### VIII. Applying Random Initial Time Shifts
To transition the simulation from a synchronized (cyclostationary) model to a realistic asynchronous (stationary) model, an independent, uniformly distributed random time delay $T_d \in [0, L-1]$ is injected into every realization using `circshift`.

### IX. Preparing Cell Arrays for Analysis
Data structures and plotting arguments are modularized to allow for a clean, unified plotting wrapper (`draw_plot`), avoiding redundant code when visualizing the ensembles.

---

## 💻 Source

### Full MATLAB Code
The completely modular MATLAB implementation containing all control flags, sequence generation, from-scratch mathematical functions, and automated plotting logic can be found in the main script here: 

👉 **[digital_comm.m](./digital_comm.m)**
