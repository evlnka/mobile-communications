f = 4;

% Максимальная частота в спектре 
f1 = 2*pi*f/(2 * pi);
f2 = 10 * pi * f / (2 * pi);
f3 = 6 / (2 * pi); 
Fmax = max([f1,f2,f3]);

% Оцифровка сигнала
fg = 2 * 4 * Fmax;
t = 0:1/fg:1;
y_original = cos(2*pi*f*t) + sin(10*pi*f*t) + sin(6*t);

% Анализ для разных разрядностей
bits_list = [3, 4, 5, 6];
n = length(y_original);

fprintf('Влияние разрядности АЦП на спектр сигнала\n\n');

for i = 1:length(bits_list)
    bits = bits_list(i);

    max_level = 2^bits - 1;
    
    y_min = min(y_original);
    y_max = max(y_original);
    
    y_scaled = (y_original - y_min) / (y_max - y_min) * max_level;

    y_quantized = round(y_scaled);
    
    y_quantized(y_quantized > max_level) = max_level;
    y_quantized(y_quantized < 0) = 0;
    
    y_quantized = y_quantized / max_level * (y_max - y_min) + y_min;
    
    error = y_quantized - y_original;
    mean_error = mean(abs(error));
    
    Y_original = fft(y_original);
    Y_quantized = fft(y_quantized);
    
    Y_amp_original = abs(Y_original);
    Y_amp_quantized = abs(Y_quantized);
    
    f_axis = (0:n-1) * (fg/n);
    
    figure;
    plot(f_axis, Y_amp_original, 'b-', 'LineWidth', 1.5);
    hold on;
    plot(f_axis, Y_amp_quantized, 'r--', 'LineWidth', 1);
    title(['Спектр сигнала: ' num2str(bits) ' бит АЦП']);
    xlabel('Частота, Гц');
    ylabel('Амплитуда');
    legend('Исходный сигнал', 'После квантования');
    grid on;
    xlim([0, fg/2]);
    
    fprintf('Разрядность АЦП: %d бит\n', bits);
    fprintf('Диапазон квантования: 0..%d\n', 2^bits - 1);
    fprintf('Средняя ошибка квантования: %.6f\n\n', mean_error);
end