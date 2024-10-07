% PMM Feature Extraction for UAV using mmWave Radar Data
% This MATLAB script will load binary data files from the mmWave radar,
% perform spectral analysis, and identify Periodic Micro Motions (PMM) features.

% Load the binary files
master_data = load_binary_data('../data/drone_steady_0/master_0000_data.bin');
slave1_data = load_binary_data('../data/drone_steady_0/slave1_0000_data.bin');
slave2_data = load_binary_data('../data/drone_steady_0/slave2_0000_data.bin');
slave3_data = load_binary_data('../data/drone_steady_0/slave3_0000_data.bin');

% Combine the data from master and slaves
combined_data = [master_data; slave1_data; slave2_data; slave3_data];

% Parameters
adc_samples = 256; % Number of samples per chirp
nchirp_loops = 64; % Number of chirps per frame
sample_freq = 8e6; % Sampling frequency in Hz
 
% Reshape the combined data into chirps and frames
num_chirps = length(combined_data) / adc_samples;
radar_data = reshape(combined_data, adc_samples, num_chirps);

% FFT parameters
NFFT = 1024; % Number of FFT points
window = hamming(adc_samples);
overlap = adc_samples / 2;

% Doppler analysis using STFT to extract PMM features
figure;
stft_data = stft(radar_data, 'Window', window, 'OverlapLength', overlap, 'FFTLength', NFFT, 'Centered', false);

% Plot the Doppler spectrum
time_vector = (0:num_chirps-1) * nchirp_loops / sample_freq;
freq_vector = linspace(0, sample_freq/2, NFFT/2 + 1);

imagesc(time_vector, freq_vector, abs(stft_data(1:NFFT/2+1, :)));
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Doppler Spectrum');
colorbar;

% PMM Feature Extraction: Identification of periodic micro-motions
body_velocity_peak = max(abs(stft_data));
thresh = 0.1 * body_velocity_peak;
periodic_peaks = abs(stft_data) > thresh;

% Identify PMM peaks centered around body velocity peak
figure;
stem(freq_vector, periodic_peaks(1:NFFT/2+1));
xlabel('Frequency (Hz)');
ylabel('Amplitude');
title('Identified PMM Peaks');

% Function to load binary data
display('Function to load binary data');
function data = load_binary_data(filename)
    fid = fopen(filename, 'rb');
    data = fread(fid, 'int16'); % Assuming data is stored as int16
    fclose(fid);
end