%===========Control Flags=========%
N_bits = 100;               %Number of bits per realization
N_realizations = 500;       %Number of realizations;
Pw = 0.07;         %Pulse width of the bit
Ts = 0.01;         % Time sample
L = round(Pw / Ts);

A = 4;                  %Ampiltude


%==========Creating random_data=======%

data = randi([0 1] , N_realizations , N_bits);



%===========Unipolar Ensemble==========%
%Transmitter%






%Receiver(Mean, Autocorrelation, Ergodicity, BW)%




%Results%




%============polar NRZ Ensemble==========%
%Transmitter%






%Receiver(Mean, Autocorrelation, Ergodicity, BW)%




%Results%



%==============of polar RZ Ensemble========%
%========Transmitter%
Tx_RZ= (2*data -1)*A;   %Mapping

pulse_RZ = [ones(1 , floor(L/2)) , zeros(1 , ceil(L/2))]; %Creating pulse shape

ensample_RZ = kron(Tx_RZ , pulse_RZ);    %upsampling


Td = randi([0 , L-1] , N_realizations , 1);

for i = 1:N_realizations
    ensample_RZ( i , :) = circshift(ensample_RZ(i , :) , [0 ,Td(i)]);
end

figure;

% First realization
subplot(2, 1, 1);
stairs(ensample_RZ(1, 1:140), 'LineWidth', 1.5);
title('Realization #1');
ylim([-A-1 A+1]); grid on;
ylabel('Voltage');

% Second realization
subplot(2, 1, 2);
stairs(ensample_RZ(2, 1:140), 'LineWidth', 1.5, 'Color', 'r');
title('Realization #2');
ylim([-A-1 A+1]); grid on;
ylabel('Voltage');
xlabel('Sample Index');

sgtitle('Comparison of 2 Polar RZ Realizations with Random Delays');


%=========Receiver(Mean, Autocorrelation, Ergodicity, BW)%
% 1. Mean E(x)
Ex_RZ = mean(ensample_RZ, 1); 

E_samp_RZ = mean(ensample_RZ(: , 10));  % mean of sample 10

fprintf('Ensemble Mean of sample 10 = %f\n', E_samp_RZ);

 %2. autocorrelation function Rx(tau)
%========== Method 2: Ensemble Average (Instructor Method) %
[Rx_RZ , tau] = correlation(ensample_RZ , 100);

%Ergodicity
%1.Average over time
Ux_RZ = mean(ensample_RZ , 2);

E_time_RZ = mean(ensample_RZ(15 , :));  % avergae of realization 15    

fprintf('Time Mean of realization 15 = %f\n', E_time_RZ);

%2. autocorrelation over realizations

[Rx_time_RZ, lags_time] = xcorr(ensample_RZ(10, :), 100, 'unbiased');


%Plotting 
figure;
subplot(2 , 1 , 1);
plot(tau*Ts, Rx_RZ, 'LineWidth', 1.5);
grid on;
title('Ensemble Autocorrelation Function R_x(\tau)');
xlabel('\tau (seconds)'); ylabel('R_x(\tau)');
xlim([-0.75 0.75]);

subplot(2 , 1 , 2)
plot(lags_time * Ts, Rx_time_RZ, 'g', 'LineWidth', 1.5);
grid on;
title('Time Autocorrelation R_T(\tau) for Realization #10');
xlabel('\tau (seconds)'); 
ylabel('R_T(\tau)');


sgtitle('Rx(tau) VS <x(t) x(t+tau)>');


% Plotting mean
figure;
subplot(2 , 1 , 1);
plot(Ex_RZ); 
ylim([-1 1]); grid on;
title('Statistical Mean E[X(t)]');
xlabel('Sample Index (t)'); ylabel('Mean Value');

subplot(2 , 1 , 2);
plot(Ux_RZ); 
ylim([-1 1]); grid on;
title('Time Mean <X(t)>');
xlabel('Sample Index (t)'); ylabel('Mean Value');

sgtitle('E(x(t)) VS <x(t)>');


%check this ensamble is random process stationary or not

t1 = 10; 
t2 = 50; 

window_size = 350; 

% autocorrelation at t1 Rx(tau)
segment1 = ensample_RZ(:, t1 : t1 + window_size);
[R_t1, lags_t1] = xcorr(segment1', 50, 'unbiased');
Avg_R_t1 = mean(R_t1, 2);

% Autocorrelation at t2 Rx(tau)
segment2 = ensample_RZ(:, t2 : t2 + window_size);
[R_t2, lags_t2] = xcorr(segment2', 50, 'unbiased');
Avg_R_t2 = mean(R_t2, 2);

% plotting
figure;
plot(lags_t1*Ts, Avg_R_t1, 'b', 'LineWidth', 1.5); hold on;
plot(lags_t2*Ts, Avg_R_t2, 'r--', 'LineWidth', 1.5);
grid on;
legend('R_x(\tau) starting at t_1', 'R_x(\tau) starting at t_2');
title('Stationarity Check: R_x(\tau) is independent of t_1');
xlabel('\tau (seconds)');


%PSD

N_fft = 64; 
PSD = abs(fft(ifftshift(Rx_RZ), N_fft));
Fs = 1/Ts;
freq = (-N_fft/2 : (N_fft/2)-1) * (Fs/N_fft);

%plotting
PSD_final = fftshift(PSD);
figure;
plot(freq, PSD_final, 'LineWidth', 2, 'Color' , [0 0.4470 0.7410]);
grid on;
title(' PSD of Polar RZ');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
xlim([-120 120]); 


%covnvolution function
function [Rx , tau] = correlation(signal ,max_tau)
  tau = -max_tau:max_tau;
  Rx = zeros(1 , length(tau));
  t_index = floor(size(signal , 2) / 2);
  for i = 1 : length(tau)
      shift = tau(i);
      x_t = signal(: , t_index);
      x_t_tau = signal(: , t_index+ shift);
      Rx(i) = mean(x_t .* x_t_tau);
  end
end
