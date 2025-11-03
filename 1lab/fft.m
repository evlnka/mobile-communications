clear; clc; close all;

%% Ручная реализация DFT
function X = dft(x)
    N = length(x);
    X = zeros(1, N);
    for k = 0:N-1
        for n = 0:N-1
            X(k+1) = X(k+1) + x(n+1) * exp(-1j * 2 * pi * k * n / N);
        end
    end
end

%% Ярослав
function F = my_fft(samples)
    N = length(samples);
    F = zeros(N, 1);
    for k = 1 : N
        sum = 0;
        for n = 1 : N
            sum = sum + samples(n) * exp(-1i * 2 * pi * (k-1) * (n-1)/N);
        end
        F(k) = sum;
    end
end

fft_sizes = [64, 128, 256, 528, 1024];
num_tests = 100;

time_matlab_fft = zeros(length(fft_sizes), 1);
time_dft = zeros(length(fft_sizes), 1);

for i = 1:length(fft_sizes)
    N = fft_sizes(i);
    x = randn(1, N);
    
    % Matlab
    t_matlab = 0;
    for test = 1:num_tests
        tic;
        fft(x);
        t_matlab = t_matlab + toc;
    end
    time_matlab_fft(i) = t_matlab / num_tests;

    % Ярослав
    t_ya = 0;
    for test = 1:num_tests
        tic;
        my_fft(x);
        t_ya = t_ya + toc;
    end
    time_ya_fft(i) = t_ya / num_tests;
    
    % DFT
    t_dft = 0;
    for test = 1:num_tests
        tic;
        dft(x);
        t_dft = t_dft + toc;
    end
    time_dft(i) = t_dft / num_tests;
end

figure;
plot(fft_sizes, time_matlab_fft * 1000, 'b-o', 'LineWidth', 2, 'DisplayName', 'Matlab fft()');
hold on;
plot(fft_sizes, time_dft * 1000, 'r-s', 'LineWidth', 2, 'DisplayName', 'Самописная функция');
plot(fft_sizes, time_ya_fft * 1000, 'g-o', 'LineWidth', 2, 'DisplayName', 'Ярослав');
xlabel('Размер FFT');
ylabel('Время (мс)');
title('Сравнение времени выполнения (100 тестов)');
legend;
grid on;
xticks(fft_sizes)