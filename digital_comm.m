% =========== Control Flags ========= %
N_bits = 100;               % Number of bits per realization.
N_realizations = 500;       % Number of realizations.
Pw = 0.07;                  % Pulse width of the bit.
Ts = 0.01;                  % Time sample.
L = round(Pw / Ts);         % Number of samples per symbol period (L=7).
A = 4;                      % Amplitude.

N_fft = 1024;
Fs = 1/Ts;
freq = (-N_fft/2:N_fft/2-1) * (Fs/N_fft);

% ========== Creating Random Data ======= %
data = randi([0 1], N_realizations, N_bits);

% =========== Unipolar NRZ Ensemble ========== %
fprintf('\n========== UNIPOLAR NRZ ANALYSIS ==========\n');

% Transmitter.
ensample_unipolar = build_ensemble(data, A, ones(1,L), N_realizations, L, 'unipolar');

% Plot realizations for Unipolar NRZ.
figure;
subplot(2, 1, 1);
stairs(ensample_unipolar(1, 1:140), 'LineWidth', 1.5);
title('Unipolar NRZ - Realization #1');
ylim([-1, A+1]);
grid on;
ylabel('Voltage (V)');

subplot(2, 1, 2);
stairs(ensample_unipolar(2, 1:140), 'LineWidth', 1.5, 'Color', 'r');
title('Unipolar NRZ - Realization #2');
ylim([-1, A+1]);
grid on;
ylabel('Voltage (V)');
xlabel('Sample Index');
sgtitle('Unipolar NRZ Realizations with Random Delays');

% Mean calculations.
Ex_unipolar = manual_mean(ensample_unipolar, 1);         % Ensemble mean.
E_samp_unipolar = manual_mean(ensample_unipolar(:, 10)); % Sample 10.
fprintf('Ensemble Mean of sample 10 = %.4f V (Theoretical: %.2f V)\n', E_samp_unipolar, A/2);

% Autocorrelation - Ensemble.
[Rx_unipolar, tau_unipolar] = correlation_manual(ensample_unipolar, 100, 'ensemble');

% Ergodicity - Time means.
Ux_unipolar = manual_mean(ensample_unipolar, 2);         % Time mean for EVERY realization.
E_time_unipolar = manual_mean(ensample_unipolar(15, :)); % Time mean for ONLY ONE specific realization.
fprintf('Time Mean of realization 15 = %.4f V (Theoretical: %.2f V)\n', E_time_unipolar, A/2);

% Time autocorrelation.
[Rx_time_unipolar, lags_time_unipolar] = correlation_manual(ensample_unipolar(10, :), 100, 'time');

% Plot autocorrelation for Unipolar NRZ.
figure;
subplot(2, 1, 1);
plot(tau_unipolar*Ts, Rx_unipolar, 'LineWidth', 1.5);
grid on;
title('Unipolar NRZ - Ensemble Autocorrelation R_x(\tau)');
xlabel('\tau (seconds)');
ylabel('R_x(\tau)');
xlim([-0.75 0.75]);

subplot(2, 1, 2);
plot(lags_time_unipolar*Ts, Rx_time_unipolar, 'g', 'LineWidth', 1.5);
grid on;
title('Unipolar NRZ - Time Autocorrelation for Realization #10');
xlabel('\tau (seconds)');
ylabel('R_T(\tau)');
sgtitle('Unipolar NRZ: Ensemble vs Time Autocorrelation');

% Plot mean comparison for Unipolar NRZ.
figure;
subplot(2, 1, 1);
plot(Ex_unipolar);
ylim([-1, A+1]);
grid on;
title('Unipolar NRZ - Statistical Mean E[X(t)]');
xlabel('Sample Index (t)');
ylabel('Mean Value (V)');

subplot(2, 1, 2);
plot(Ux_unipolar);
ylim([-1, A+1]);
grid on;
title('Unipolar NRZ - Time Mean <X(t)> for Each Realization');
xlabel('Realization Number');
ylabel('Mean Value (V)');
sgtitle('Unipolar NRZ: E[x(t)] vs <x(t)>');

% Stationarity check for Unipolar NRZ.
t1 = 10;
t2 = 50;
window_size = 350;

segment1 = ensample_unipolar(:, t1:t1+window_size);
[R_t1, lags_t1] = correlation_manual(segment1, 50, 'ensemble');

segment2 = ensample_unipolar(:, t2:t2+window_size);
[R_t2, lags_t2] = correlation_manual(segment2, 50, 'ensemble');

figure;
plot(lags_t1 * Ts, R_t1, 'b', 'LineWidth', 1.5);
hold on;
plot(lags_t2 * Ts, R_t2, 'r--', 'LineWidth', 1.5);
grid on;
legend('R_x(\tau) at t_1', 'R_x(\tau) at t_2');
title('Unipolar NRZ - Stationarity Check');
xlabel('\tau (seconds)');
ylabel('R_x(\tau)');


% ---- PSD for Unipolar NRZ ---- %
mx_unipolar = A/2;  % Theoretical mean (A=4 -> 2).

% 1) Subtract mean^2 from every lag to isolate the AC (sinc^2) part.
Rx_ac_unipolar = Rx_unipolar - mx_unipolar^2;

% 2) Zero-pad the AC autocorrelation into an N_fft-length buffer.
Rx_padded_unipolar = zeros(1, N_fft);
center   = floor(N_fft/2) + 1;
half_len = 100;     % Max_tau used in correlation_manual.
Rx_padded_unipolar(center - half_len : center + half_len) = Rx_ac_unipolar;

% 3) FFT.
PSD_ac_unipolar = fftshift(abs(fft(ifftshift(Rx_padded_unipolar))));

% 4) Represent the DC impulse as a single raised bin (area = mx^2).
PSD_dc_unipolar = zeros(1, N_fft);
DC_spike_height = mx_unipolar^2 / (Fs / N_fft);
PSD_dc_unipolar(center) = DC_spike_height;

PSD_final_unipolar = PSD_ac_unipolar + PSD_dc_unipolar;
% S(f) = (A^2/4) * delta(f) + (A^2 * T/4) * sinc^2(fT).

figure;
plot(freq, PSD_final_unipolar, 'LineWidth', 2, 'Color', [0.8500 0.3250 0.0980]);
grid on;
title('PSD of Unipolar NRZ Signaling');
xlabel('Frequency (Hz)');
ylabel('S_x(f)  [V^2/Hz]');
xlim([-120, 120]);


% ============ Polar NRZ Ensemble ========== %
fprintf('\n========== POLAR NRZ ANALYSIS ==========\n');

% Transmitter.
ensample_polar_NRZ = build_ensemble(data, A, ones(1,L), N_realizations, L, 'polar');

% Plot realizations for Polar NRZ.
figure;
subplot(2, 1, 1);
stairs(ensample_polar_NRZ(1, 1:140), 'LineWidth', 1.5);
title('Polar NRZ - Realization #1');
ylim([-A-1, A+1]);
grid on;
ylabel('Voltage (V)');

subplot(2, 1, 2);
stairs(ensample_polar_NRZ(2, 1:140), 'LineWidth', 1.5, 'Color', 'r');
title('Polar NRZ - Realization #2');
ylim([-A-1, A+1]);
grid on;
ylabel('Voltage (V)');
xlabel('Sample Index');
sgtitle('Polar NRZ Realizations with Random Delays');

% Mean calculations.
Ex_polar_NRZ = manual_mean(ensample_polar_NRZ, 1);
E_samp_polar_NRZ = manual_mean(ensample_polar_NRZ(:, 10));
fprintf('Ensemble Mean of sample 10 = %.4f V (Theoretical: 0 V)\n', E_samp_polar_NRZ);

% Autocorrelation - Ensemble.
[Rx_polar_NRZ, tau_polar_NRZ] = correlation_manual(ensample_polar_NRZ, 100, 'ensemble');

% Time means.
Ux_polar_NRZ = manual_mean(ensample_polar_NRZ, 2);
E_time_polar_NRZ = manual_mean(ensample_polar_NRZ(15, :));
fprintf('Time Mean of realization 15 = %.4f V (Theoretical: 0 V)\n', E_time_polar_NRZ);

% Time autocorrelation.
[Rx_time_polar_NRZ, lags_time_polar_NRZ] = correlation_manual(ensample_polar_NRZ(10, :), 100, 'time');

% Plot autocorrelation for Polar NRZ.
figure;
subplot(2, 1, 1);
plot(tau_polar_NRZ*Ts, Rx_polar_NRZ, 'LineWidth', 1.5);
grid on;
title('Polar NRZ - Ensemble Autocorrelation R_x(\tau)');
xlabel('\tau (seconds)');
ylabel('R_x(\tau)');
xlim([-0.75 0.75]);

subplot(2, 1, 2);
plot(lags_time_polar_NRZ*Ts, Rx_time_polar_NRZ, 'g', 'LineWidth', 1.5);
grid on;
title('Polar NRZ - Time Autocorrelation for Realization #10');
xlabel('\tau (seconds)');
ylabel('R_T(\tau)');
sgtitle('Polar NRZ: Ensemble vs Time Autocorrelation');

% Plot mean comparison for Polar NRZ.
figure;
subplot(2, 1, 1);
plot(Ex_polar_NRZ);
ylim([-A-1, A+1]);
grid on;
title('Polar NRZ - Statistical Mean E[X(t)]');
xlabel('Sample Index (t)');
ylabel('Mean Value (V)');

subplot(2, 1, 2);
plot(Ux_polar_NRZ);
ylim([-A-1, A+1]);
grid on;
title('Polar NRZ - Time Mean <X(t)> for Each Realization');
xlabel('Realization Number');
ylabel('Mean Value (V)');
sgtitle('Polar NRZ: E[x(t)] vs <x(t)>');

% Stationarity check for Polar NRZ.
t1 = 10;
t2 = 50;
window_size = 350;

segment1 = ensample_polar_NRZ(:, t1:t1+window_size);
[R_t1, lags_t1] = correlation_manual(segment1, 50, 'ensemble');

segment2 = ensample_polar_NRZ(:, t2:t2+window_size);
[R_t2, lags_t2] = correlation_manual(segment2, 50, 'ensemble');

figure;
plot(lags_t1 * Ts, R_t1, 'b', 'LineWidth', 1.5);
hold on;
plot(lags_t2 * Ts, R_t2, 'r--', 'LineWidth', 1.5);
grid on;
legend('R_x(\tau) at t_1', 'R_x(\tau) at t_2');
title('Polar NRZ - Stationarity Check');
xlabel('\tau (seconds)');
ylabel('R_x(\tau)');

% ---- PSD for Polar NRZ ---- %
Rx_padded_polar_NRZ = zeros(1, N_fft);
Rx_padded_polar_NRZ(center - half_len : center + half_len) = Rx_polar_NRZ;
PSD_final_polar_NRZ = fftshift(abs(fft(ifftshift(Rx_padded_polar_NRZ))));

figure;
plot(freq, PSD_final_polar_NRZ, 'LineWidth', 2, 'Color', [0 0.4470 0.7410]);
grid on;
title('PSD of Polar NRZ Signaling');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([-120, 120]);


% ============== Polar RZ Ensemble ======== %
fprintf('\n========== POLAR RZ ANALYSIS ==========\n');

% Transmitter.
ensample_RZ = build_ensemble(data, A, [ones(1,floor(L/2)), zeros(1,ceil(L/2))], N_realizations, L, 'polar');

% Plot realizations for Polar RZ.
figure;
subplot(2, 1, 1);
stairs(ensample_RZ(1, 1:140), 'LineWidth', 1.5);
title('Polar RZ - Realization #1');
ylim([-A-1, A+1]);
grid on;
ylabel('Voltage (V)');

subplot(2, 1, 2);
stairs(ensample_RZ(2, 1:140), 'LineWidth', 1.5, 'Color', 'r');
title('Polar RZ - Realization #2');
ylim([-A-1, A+1]);
grid on;
ylabel('Voltage (V)');
xlabel('Sample Index');
sgtitle('Polar RZ Realizations with Random Delays');

% Mean calculations.
Ex_RZ = manual_mean(ensample_RZ, 1);
E_samp_RZ = manual_mean(ensample_RZ(:, 10));
fprintf('Ensemble Mean of sample 10 = %.4f V (Theoretical: 0 V)\n', E_samp_RZ);

% Autocorrelation - Ensemble.
[Rx_RZ, tau_RZ] = correlation_manual(ensample_RZ, 100, 'ensemble');

% Time means.
Ux_RZ = manual_mean(ensample_RZ, 2);
E_time_RZ = manual_mean(ensample_RZ(15, :));
fprintf('Time Mean of realization 15 = %.4f V (Theoretical: 0 V)\n', E_time_RZ);

% Time autocorrelation.
[Rx_time_RZ, lags_time_RZ] = correlation_manual(ensample_RZ(10, :), 100, 'time');

% Plot autocorrelation for Polar RZ.
figure;
subplot(2, 1, 1);
plot(tau_RZ*Ts, Rx_RZ, 'LineWidth', 1.5);
grid on;
title('Polar RZ - Ensemble Autocorrelation R_x(\tau)');
xlabel('\tau (seconds)');
ylabel('R_x(\tau)');
xlim([-0.75 0.75]);

subplot(2, 1, 2);
plot(lags_time_RZ*Ts, Rx_time_RZ, 'g', 'LineWidth', 1.5);
grid on;
title('Polar RZ - Time Autocorrelation for Realization #10');
xlabel('\tau (seconds)');
ylabel('R_T(\tau)');
sgtitle('Polar RZ: Ensemble vs Time Autocorrelation');

% Plot mean comparison for Polar RZ.
figure;
subplot(2, 1, 1);
plot(Ex_RZ);
ylim([-1, 1]);
grid on;
title('Polar RZ - Statistical Mean E[X(t)]');
xlabel('Sample Index (t)');
ylabel('Mean Value (V)');

subplot(2, 1, 2);
plot(Ux_RZ);
ylim([-1, 1]);
grid on;
title('Polar RZ - Time Mean <X(t)> for Each Realization');
xlabel('Realization Number');
ylabel('Mean Value (V)');
sgtitle('Polar RZ: E[x(t)] vs <x(t)>');

% Stationarity check for Polar RZ.
t1 = 10;
t2 = 50;
window_size = 350;

segment1 = ensample_RZ(:, t1:t1+window_size);
[R_t1, lags_t1] = correlation_manual(segment1, 50, 'ensemble');

segment2 = ensample_RZ(:, t2:t2+window_size);
[R_t2, lags_t2] = correlation_manual(segment2, 50, 'ensemble');

figure;
plot(lags_t1 * Ts, R_t1, 'b', 'LineWidth', 1.5);
hold on;
plot(lags_t2 * Ts, R_t2, 'r--', 'LineWidth', 1.5);
grid on;
legend('R_x(\tau) at t_1', 'R_x(\tau) at t_2');
title('Polar RZ - Stationarity Check');
xlabel('\tau (seconds)');
ylabel('R_x(\tau)');

% ---- PSD for Polar RZ ---- %
Rx_padded_RZ = zeros(1, N_fft);
Rx_padded_RZ(center - half_len : center + half_len) = Rx_RZ;
PSD_final_RZ = fftshift(abs(fft(ifftshift(Rx_padded_RZ))));

figure;
plot(freq, PSD_final_RZ, 'LineWidth', 2, 'Color', [0.4940 0.1840 0.5560]);
grid on;
title('PSD of Polar RZ Signaling');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([-120, 120]);

%% FUNCTIONS

% BUILD ENSEMBLE
function ensample = build_ensemble(data, A, pulse, N_realizations, L, type)
    if strcmp(type, 'unipolar')
        Tx = data * A;
    else
        Tx = (2*data - 1) * A;
    end
    ensample = kron(Tx, pulse);
    Td = randi([0, L-1], N_realizations, 1);
    for i = 1:N_realizations
        ensample(i, :) = circshift(ensample(i, :), [0, Td(i)]);
    end
end

% MEAN CALCULATIONS
% manual_mean(x)          % Auto-detects vector.
% manual_mean(matrix, 1)  % Ensemble mean.
% manual_mean(matrix, 2)  % Time mean.
function mean_val = manual_mean(data, dim)
    if nargin == 1
        mean_val = sum(data, 'all') / numel(data);
    elseif dim == 1
        mean_val = sum(data, 1) / size(data, 1);
    elseif dim == 2
        mean_val = sum(data, 2) / size(data, 2);
    end
end

% CORRELATION
% One function for BOTH ensemble and time autocorrelation.
%
% INPUTS:
%   max_tau: Maximum time shift.
%   type: 'ensemble' or 'time'.
%
% OUTPUTS:
%   Rx: Autocorrelation values.
%   tau: Lag values.
function [Rx, tau] = correlation_manual(signal, max_tau, type)
    tau = -max_tau:max_tau;
    Rx  = zeros(1, length(tau));

    % CASE 1: ENSEMBLE AUTOCORRELATION.
    if strcmp(type, 'ensemble')
        [~, N_samples] = size(signal);
        for i = 1:length(tau)
            shift = tau(i);
            if shift >= 0
                Rx(i) = manual_mean(signal(:, 1:N_samples-shift) .* signal(:, 1+shift:N_samples));
            else
                Rx(i) = manual_mean(signal(:, 1-shift:N_samples) .* signal(:, 1:N_samples+shift));
            end
        end

    % CASE 2: TIME AUTOCORRELATION.
    elseif strcmp(type, 'time')
        if isvector(signal)
            signal = signal(:)';
        end
        N = length(signal);
        for i = 1:length(tau)
            lag = tau(i);
            if lag >= 0
                Rx(i) = manual_mean(signal(1:N-lag) .* signal(1+lag:N));
            else
                Rx(i) = manual_mean(signal(1-lag:N) .* signal(1:N+lag));
            end
        end
    end
end