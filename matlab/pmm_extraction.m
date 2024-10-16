% PMM Feature Extraction for UAV using mmWave Radar Data
% This MATLAB script will load binary data files from the mmWave radar, 
% perform spectral analysis, and identify Periodic Micro Motions (PMM) features.

% Process data in smaller chunks to avoid memory issues
files = {'../data/drone_steady_0/master_0000_data.bin', 
    '../data/drone_steady_0/slave1_0000_data.bin', 
    '../data/drone_steady_0/slave2_0000_data.bin', 
    '../data/drone_steady_0/slave3_0000_data.bin'};
chunk_size = 1e5; % Number of samples to process at a time

% Parameters
adc_samples = 256; % Number of samples per chirp
nchirp_loops = 64; % Number of chirps per frame
sample_freq = 8e6; % Sampling frequency in Hz

% Initialize empty array for STFT results
stft_results = [];

% Loop through each file and process data in chunks
for i = 1:length(files)
    fid = fopen(files{i}, 'rb');
    while ~feof(fid)
        data_chunk = fread(fid, chunk_size, 'int16');
        if isempty(data_chunk)
            break;
        end
        % Reshape the chunk into chirps and frames if possible
        num_chirps = floor(length(data_chunk) / adc_samples);
        radar_data_chunk = reshape(data_chunk(1:num_chirps*adc_samples), adc_samples, num_chirps);
        
        % FFT parameters
        NFFT = 512; % Number of FFT points
        window = hamming(adc_samples);
        overlap = adc_samples / 2;
        
        % Doppler analysis using STFT to extract PMM features
        stft_data_chunk = stft(radar_data_chunk, 'Window', window, 'OverlapLength', overlap, 'FFTLength', NFFT, 'Centered', false);
        
        % Append STFT results
        stft_results = [stft_results, stft_data_chunk];
    end
    fclose(fid);
end

% Plot the Doppler spectrum
time_vector = (0:size(stft_results, 2)-1) * nchirp_loops / sample_freq;
freq_vector = linspace(0, sample_freq/2, NFFT/2 + 1);

figure;
imagesc(time_vector, freq_vector, abs(stft_results(1:NFFT/2+1, :)));
xlabel('Time (s)');
ylabel('Frequency (Hz)');
title('Doppler Spectrum');
colorbar;

% PMM Feature Extraction: Identification of periodic micro-motions
body_velocity_peak = max(abs(stft_results));
thresh = 0.1 * body_velocity_peak;
periodic_peaks = abs(stft_results) > thresh;

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
