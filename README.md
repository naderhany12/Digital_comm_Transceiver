# Random Process Analysis of Digital Baseband Line Codes

This repository models digital baseband communication line codes as stochastic
random processes. It simulates large ensembles of waveforms and verifies core
statistical properties including expected value, wide-sense stationarity (WSS),
ergodicity, and power spectral density (PSD).

## Repository Structure

```
Digital_comm_Transceiver/
├── Project's Document.pdf         # Final project report
├── Report.rar                     # Original report archive
├── src/                           # MATLAB source code
│   ├── digital_comm.m             # Main simulation script
│   ├── digital_comm.asv           # MATLAB auto-save backup
│   └── ExportFigures.m            # Figure export utility
├── figures/                       # Generated plots and report figures
└── docs/                          # Supplementary documentation
    ├── report.pdf                 # Compiled LaTeX report
    └── bibliography.bib           # BibTeX reference list
```

## Signaling Schemes

The simulation analyzes three primary line-coding schemes:

- **Unipolar Non-Return-to-Zero (NRZ):** Binary 0 maps to 0 V, binary 1 maps to
  +A V. Uses a full-width rectangular pulse.
- **Polar NRZ:** Binary 0 maps to -A V, binary 1 maps to +A V. Uses a full-width
  rectangular pulse.
- **Polar Return-to-Zero (RZ):** Binary 0 maps to -A V, binary 1 maps to +A V.
  The pulse returns to zero halfway through the bit period.

## Configuration

The simulation behavior is controlled by a parameter block at the top of
`src/digital_comm.m`. Key parameters include:

| Parameter       | Value  | Description                              |
| :-------------- | :----- | :--------------------------------------- |
| `N_bits`        | 100    | Number of bits per realization           |
| `N_realizations`| 500    | Total number of generated waveforms      |
| `Pw`            | 0.07 s | Pulse width of a single bit              |
| `Ts`            | 0.01 s | Time sample duration (Fs = 100 Hz)       |
| `L`             | 7      | Samples per symbol period                |
| `A`             | 4 V    | Signal amplitude                         |
| `N_fft`         | 1024   | FFT size for high-resolution PSD         |

## How To Run

1. Open `src/digital_comm.m` in MATLAB.
2. Modify the configuration parameters as needed.
3. Run the script. All plots are generated and saved automatically to the
   `figures/` directory.

## Output Figures

The `figures/` directory contains the following plots for each signaling scheme:

- **PSD (Theoretical):** Power spectral density computed analytically.
- **Realization samples:** Example waveforms from the ensemble.
- **Stationarity check:** Comparison of ensemble statistics over time.
- **Time autocorrelation:** Autocorrelation for a single realization.
- **Time mean per realization:** Time-averaged mean plotted across all
  realizations.

The compiled report (`Project's Document.pdf`) provides the full theoretical
background, methodology, and analysis of results.

## Authors

- Youssif991
- youssefteam18-boop
- naderhany12
- minawaeltanagho
- AbdelrhmanAtta
