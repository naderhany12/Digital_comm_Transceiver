%% Control Flags
N_bits         = 100;           % Number of bits per realization.
N_realizations = 500;           % Number of realizations.
Pw             = 0.07;          % Pulse width of the bit.
Ts             = 0.01;          % Time sample.
L              = round(Pw/Ts);  % Samples per symbol period (L=7).
A              = 4;             % Amplitude.
N_fft          = 1024;          % FFT size.
Fs             = 1/Ts;          % Sampling frequency.
freq           = (-N_fft/2:N_fft/2-1) * (Fs/N_fft);  % Frequency axis.
center         = floor(N_fft/2) + 1;                  % Center bin.
half_len       = 100;           % Max tau used in correlation_manual.

%% Data Generation
data = randi([0 1], N_realizations, N_bits);

%% Unipolar NRZ
fprintf('\nUnipolar NRZ\n');
pulse_unipolar  = ones(1, L);
ylim_unipolar   = [-1, A+1];
color_unipolar  = [0.8500 0.3250 0.0980];

ensample_unipolar = build_ensemble(data, A, pulse_unipolar, N_realizations, L, 'unipolar');

[Ex_unipolar, Ux_unipolar] = compute_means(ensample_unipolar, A/2);

[Rx_unipolar, tau_unipolar]            = correlation_manual(ensample_unipolar,       100, 'ensemble');
[Rx_time_unipolar, lags_time_unipolar] = correlation_manual(ensample_unipolar(10,:), 100, 'time');

plot_realizations(ensample_unipolar, 'Unipolar NRZ', ylim_unipolar);
plot_autocorr(tau_unipolar, Rx_unipolar, ...
    lags_time_unipolar, Rx_time_unipolar, 'Unipolar NRZ', Ts);
plot_means(Ex_unipolar, Ux_unipolar, 'Unipolar NRZ', ylim_unipolar);
plot_stationarity(ensample_unipolar, Ts, 'Unipolar NRZ');
compute_psd(Rx_unipolar, N_fft, center, half_len, freq, Fs, ...
    A/2, color_unipolar, 'PSD - Unipolar NRZ', 'S_x(f) [V^2/Hz]');

%% Polar NRZ
fprintf('\nPolar NRZ\n');
pulse_polar_NRZ = ones(1, L);
ylim_polar_NRZ  = [-A-1, A+1];
color_polar_NRZ = [0 0.4470 0.7410];

ensample_polar_NRZ = build_ensemble(data, A, pulse_polar_NRZ, N_realizations, L, 'polar');

[Ex_polar_NRZ, Ux_polar_NRZ] = compute_means(ensample_polar_NRZ, 0);

[Rx_polar_NRZ, tau_polar_NRZ]            = correlation_manual(ensample_polar_NRZ,       100, 'ensemble');
[Rx_time_polar_NRZ, lags_time_polar_NRZ] = correlation_manual(ensample_polar_NRZ(10,:), 100, 'time');

plot_realizations(ensample_polar_NRZ, 'Polar NRZ', ylim_polar_NRZ);
plot_autocorr(tau_polar_NRZ, Rx_polar_NRZ, ...
    lags_time_polar_NRZ, Rx_time_polar_NRZ, 'Polar NRZ', Ts);
plot_means(Ex_polar_NRZ, Ux_polar_NRZ, 'Polar NRZ', ylim_polar_NRZ);
plot_stationarity(ensample_polar_NRZ, Ts, 'Polar NRZ');
compute_psd(Rx_polar_NRZ, N_fft, center, half_len, freq, Fs, ...
    0, color_polar_NRZ, 'PSD - Polar NRZ', 'Magnitude');

%% Polar RZ
fprintf('\nPolar RZ\n');
pulse_RZ = [ones(1, floor(L/2)), zeros(1, ceil(L/2))];
ylim_RZ  = [-A-1, A+1];
color_RZ = [0.4940 0.1840 0.5560];

ensample_RZ = build_ensemble(data, A, pulse_RZ, N_realizations, L, 'polar');

[Ex_RZ, Ux_RZ] = compute_means(ensample_RZ, 0);

[Rx_RZ, tau_RZ]            = correlation_manual(ensample_RZ,       100, 'ensemble');
[Rx_time_RZ, lags_time_RZ] = correlation_manual(ensample_RZ(10,:), 100, 'time');

plot_realizations(ensample_RZ, 'Polar RZ', ylim_RZ);
plot_autocorr(tau_RZ, Rx_RZ, lags_time_RZ, Rx_time_RZ, 'Polar RZ', Ts);
plot_means(Ex_RZ, Ux_RZ, 'Polar RZ', [-1, 1]);
plot_stationarity(ensample_RZ, Ts, 'Polar RZ');
compute_psd(Rx_RZ, N_fft, center, half_len, freq, Fs, ...
    0, color_RZ, 'PSD - Polar RZ', 'Magnitude');

%% Functions

function plot_realizations(ensample, name, ylim_range)
figure;
subplot(2,1,1);
stairs(ensample(1, 1:140), 'LineWidth', 1.5);
title([name, ' - Realization #1']); ylim(ylim_range); grid on; ylabel('Voltage (V)');
subplot(2,1,2);
stairs(ensample(2, 1:140), 'LineWidth', 1.5, 'Color', 'r');
title([name, ' - Realization #2']); ylim(ylim_range); grid on;
ylabel('Voltage (V)'); xlabel('Sample Index');
sgtitle([name, ' Realizations']);
end

function plot_autocorr(tau, Rx_ens, lags_t, Rx_t, name, Ts)
figure;
subplot(2,1,1);
plot(tau*Ts, Rx_ens, 'LineWidth', 1.5);
title([name, ' - Ensemble R_x(\tau)']); grid on;
xlabel('\tau (s)'); ylabel('R_x(\tau)'); xlim([-0.75 0.75]);
subplot(2,1,2);
plot(lags_t*Ts, Rx_t, 'g', 'LineWidth', 1.5);
title([name, ' - Time R_x(\tau) for Realization #10']); grid on;
xlabel('\tau (s)'); ylabel('R_T(\tau)');
sgtitle([name, ': Ensemble vs Time Autocorrelation']);
end

function plot_means(Ex, Ux, name, ylim_range)
figure;
subplot(2,1,1);
plot(Ex); ylim(ylim_range); grid on;
title([name, ' - E[X(t)]']); xlabel('Sample Index'); ylabel('Mean (V)');
subplot(2,1,2);
plot(Ux); ylim(ylim_range); grid on;
title([name, ' - <X(t)> per Realization']); xlabel('Realization'); ylabel('Mean (V)');
sgtitle([name, ': E[x(t)] vs <x(t)>']);
end

function plot_stationarity(ensample, Ts, name)
t1 = 10; t2 = 50; window_size = 350;
[R_t1, lags_t1] = correlation_manual(ensample(:, t1:t1+window_size), 50, 'ensemble');
[R_t2, lags_t2] = correlation_manual(ensample(:, t2:t2+window_size), 50, 'ensemble');
figure;
plot(lags_t1*Ts, R_t1, 'b', 'LineWidth', 1.5); hold on;
plot(lags_t2*Ts, R_t2, 'r--', 'LineWidth', 1.5);
grid on; legend('R_x at t_1', 'R_x at t_2');
title([name, ' - Stationarity Check']); xlabel('\tau (s)'); ylabel('R_x(\tau)');
end

function compute_psd(Rx, N_fft, center, half_len, freq, Fs, dc_mean, color, title_str, ylabel_str)
Rx_padded = zeros(1, N_fft);
Rx_padded(center-half_len : center+half_len) = Rx - dc_mean^2;  % Subtract DC, zero-pad.
PSD = fftshift(abs(fft(ifftshift(Rx_padded))));                  % FFT to get PSD.
if dc_mean ~= 0                                                  % Add DC spike if non-zero mean.
    DC_spike = zeros(1, N_fft);
    DC_spike(center) = dc_mean^2 / (Fs/N_fft);
    PSD = PSD + DC_spike;
end
figure;
plot(freq, PSD, 'LineWidth', 2, 'Color', color);
grid on; title(title_str); xlabel('Frequency (Hz)'); ylabel(ylabel_str); xlim([-120, 120]);
end

function [Ex, Ux] = compute_means(ensample, theoretical_mean)
Ex = manual_mean(ensample, 1);   % Ensemble mean (across realizations).
Ux = manual_mean(ensample, 2);   % Time mean (across samples).
fprintf('  Sample 10 ensemble mean  = %.4f V (Theoretical: %.2f V)\n', manual_mean(ensample(:,10)),  theoretical_mean);
fprintf('  Realization 15 time mean = %.4f V (Theoretical: %.2f V)\n', manual_mean(ensample(15,:)), theoretical_mean);
end

function ensample = build_ensemble(data, A, pulse, N_realizations, L, type)
if strcmp(type, 'unipolar'), Tx = data * A;           % Map bits to {0, A}.
else,                        Tx = (2*data - 1) * A;   % Map bits to {-A, +A}.
end
ensample = kron(Tx, pulse);                           % Upsample with pulse shape.
Td = randi([0, L-1], N_realizations, 1);              % Random delay per realization.
for i = 1:N_realizations
    ensample(i,:) = circshift(ensample(i,:), [0, Td(i)]);
end
end

function mean_val = manual_mean(data, dim)
if nargin == 1,    mean_val = sum(data, 'all') / numel(data);  % All elements.
elseif dim == 1,   mean_val = sum(data, 1) / size(data, 1);    % Column-wise (ensemble).
elseif dim == 2,   mean_val = sum(data, 2) / size(data, 2);    % Row-wise (time).
end
end

function [Rx, tau] = correlation_manual(signal, max_tau, type)
tau = -max_tau:max_tau;      % Lag vector.
Rx  = zeros(1, length(tau)); % Output array.
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
elseif strcmp(type, 'time')
    if isvector(signal), signal = signal(:)'; end  % Ensure row vector.
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