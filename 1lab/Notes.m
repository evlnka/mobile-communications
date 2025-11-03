%% Частоты нот (Гц)
G  = 392.00;   % Соль
D  = 293.66;   % Ре
Fs = 369.99;   % Фа-диез
A  = 440.00;   % Ля
Bb = 466.16;   % Си-бемоль

%% Мелодия
notes = [G, D, G, D, G, Fs, Fs, Fs, D, Fs, D, Fs, G, G, G, ...
         D, G, D, G, Fs, Fs, Fs, D, Fs, D, Fs, G, G, G, ...
         A, A, A, A, A, Bb, Bb, Bb, Bb, Bb, Bb, ...
         A, G, Fs, G, G, G, ...
         A, A, A, A, A, Bb, Bb, Bb, Bb, Bb, Bb, ...
         A, G, Fs, G, G];

% Длительность каждой ноты (секунды)
duration = 0.4;

%% Параметры звука
fs = 44100;

%% Создание мелодии
signal = [];

for i = 1:length(notes)
    t = (0:1/fs:duration - 1/fs)';
    note_signal = sin(2 * pi * notes(i) * t);
    signal = [signal; note_signal];
end

% Нормализация
signal = signal / max(abs(signal));

%% Создание временной оси
total_time = length(notes) * duration;
time_axis = (0:1/fs:total_time - 1/fs)';

%% График с видимыми колебаниями - первые 0.1 секунды
figure;

plot_duration = 1; % секунд
samples_to_plot = round(plot_duration * fs);

plot(time_axis(1:samples_to_plot), signal(1:samples_to_plot), 'b-', 'LineWidth', 1);
xlabel('Время (секунды)');
ylabel('Амплитуда');
title('Колебания синусоид');
grid on;

%% Воспроизведение
sound(signal, fs);


