[y, Fs] = audioread('voice.wav');

y1 = downsample(y, 10);
Fs_down = Fs / 10;

N = length(y);
Y = fft(y);
P2_orig = abs(Y/N);
P1_orig = P2_orig(1:N/2+1);
P1_orig(2:end-1) = 2*P1_orig(2:end-1);
P1_orig_db = 20*log10(P1_orig + eps); 
f_orig = Fs*(0:(N/2))/N;

N_down = length(y1);
Y_down = fft(y1);
P2_down = abs(Y_down/N_down);
P1_down = P2_down(1:N_down/2+1);
P1_down(2:end-1) = 2*P1_down(2:end-1);
P1_down_db = 20*log10(P1_down + eps); 
f_down = Fs_down*(0:(N_down/2))/N_down;

figure('Position', [100, 100, 1200, 500]);
subplot(1,2,1);
plot(f_orig, P1_orig_db, 'b-', 'LineWidth', 1.5);
title('Амплитудный спектр исходного сигнала');
xlabel('Частота (Гц)');
ylabel('Амплитуда (дБ)');
xlim([0, Fs/2]);
grid on;

subplot(1,2,2);
plot(f_down, P1_down_db, 'r-', 'LineWidth', 1.5);
title('Амплитудный спектр прореженного сигнала');
xlabel('Частота (Гц)');
ylabel('Амплитуда (дБ)');
xlim([0, Fs_down/2]);
grid on;

max_amp_orig = max(P1_orig_db);
max_amp_down = max(P1_down_db);

threshold_db_orig = max_amp_orig - 40;
threshold_db_down = max_amp_down - 40;

significant_freqs = f_orig(P1_orig_db > threshold_db_orig);
significant_freqs_down = f_down(P1_down_db > threshold_db_down);

if ~isempty(significant_freqs)
    spectrum_width_orig = max(significant_freqs);
else
    spectrum_width_orig = 0;
end

if ~isempty(significant_freqs_down)
    spectrum_width_down = max(significant_freqs_down);
else
    spectrum_width_down = 0;
end

fprintf('Ширина спектра исходного сигнала: %.2f Гц\n', spectrum_width_orig);
fprintf('Ширина спектра прореженного сигнала: %.2f Гц\n', spectrum_width_down);

% Воспроизведение исходного сигнала
player_orig = audioplayer(y, Fs);
play(player_orig);
pause(8);
% Воспроизведение прореженного сигнала
player_down = audioplayer(y1, Fs_down);
play(player_down);
