f = 4;

% Максимальная частота в спектре 
f1 = 2*pi*f/(2 * pi);
f2 = 10 * pi * f / (2 * pi);
f3 = 6 / (2 * pi); 
Fmax = max([f1,f2,f3]);
Fmin = min([f1,f2,f3]);  % Добавляем минимальную частоту

% Оригинальный аналоговый сигнал
t_analog = 0:0.001:1;
y_or = cos(2*pi*f*t_analog)+sin(10*pi*f*t_analog)+sin(6*t_analog);

% Оцифровка сигнала
fs = 2 * Fmax + 1;
t = 0:1/fs:1;
y = cos(2*pi*f*t)+sin(10*pi*f*t)+sin(6*t);

% Восстановление сигнала из отсчетов
y_v = interp1(t, y, t_analog, 'linear');

% График временных сигналов
figure;
subplot(2,1,1);
plot(t_analog, y_or, 'b-', 'LineWidth', 2);
hold on;
plot(t_analog, y_v, 'r--', 'LineWidth', 1.5);
plot(t, y, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', 'k');
hold off;

title('Сравнение оригинального и восстановленного сигналов');
xlabel('Время, с');
ylabel('Амплитуда');
legend('Оригинальный сигнал', 'Восстановленный сигнал', 'Отсчеты');
grid on;

% Амплитудный спектр
Y = fft(y);
Y_amp = abs(Y);

n = length(y);
f_axis = (0:n-1) * (fs/n);

Y_amp_normalized = Y_amp / n;
N_half = floor(n/2);
f_axis_half = f_axis(1:N_half);
Y_amp_half = Y_amp_normalized(1:N_half);

% График амплитудного спектра
subplot(2,1,2);
stem(f_axis_half, Y_amp_half, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
title('Амплитудный спектр сигнала');
xlabel('Частота, Гц');
ylabel('Амплитуда');
grid on;

spectrum_width = Fmax - Fmin; 

memory = n * 8;

fprintf('Количество отсчетов: %d\n\n', n);
fprintf('Максимальная частота: %.2f Гц\n', Fmax);
fprintf('Минимальная частота: %.2f Гц\n', Fmin);
fprintf('Ширина спектра: %.2f Гц\n', spectrum_width);
fprintf('Объем памяти: %d байт\n\n', memory);
fprintf('Результат оцифровки:\n');
fprintf('t        y\n');
for i = 1:min(10, length(t)) 
    fprintf('%.4f   %.4f\n', t(i), y(i));
end