%===========Control Flags=========%
N_bits = 100;               %Number of bits per realization
N_realizations = 500;       %Number of realizations;
Pw = 0.07;         %Pulse width of the bit
Ts = 0.01;         % Time sample
L = Pw / Ts;

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
%Transmitter%
Tx_RZ= (2*data -1)*A;   %Mapping

pulse_RZ = [ones(1 , floor(L/2)) , zeros(1 , ceil(L/2))]; %Creating pulse shape

ensample_RZ = kron(Tx_RZ , pulse_RZ);    %upsampling







%Receiver(Mean, Autocorrelation, Ergodicity, BW)%




%Results%








