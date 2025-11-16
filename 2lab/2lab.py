import math
import numpy as np
import matplotlib.pyplot as plt

TxPowerBS = 46 # дБм
Sectors = 3 
TxPowerUE = 24 # дБм
AntGainBS = 21 # дБи 
PenetrationM = 15 # дБ
IM = 1 # дБ
f = 1800 # МГц
BW_UL = 10 * 10**6 # Гц
BW_DL = 20 * 10**6 # Гц
NoiseFigure_BS = 2.4 # дБ
NoiseFigure_UE = 6 # дБ
RequiredSINR_DL = 2 # дБ
RequiredSINR_UL = 4 # дБ
FeederLoss = 2 + 0.4 + 0.5 # дБ
MIMO_Gain = 3 # дБ

# 1. Расчет бюджета восходящего канала

ThermalNoise_UL = -174 + 10 * math.log10(BW_UL)
RxSensBS = NoiseFigure_BS + ThermalNoise_UL + RequiredSINR_UL

# Восходящего сигнала
MAPL_UL = TxPowerUE - FeederLoss + AntGainBS + MIMO_Gain - IM - PenetrationM - RxSensBS 

print(f"Максимально допустимые потери Uplink: {MAPL_UL:.4f} дБ")

# 2. Расчет бюджета нисходящего канала

ThermalNoise_DL = -174 + 10 * math.log10(BW_DL)
RxSensUL = NoiseFigure_UE + ThermalNoise_DL + RequiredSINR_DL

# Восходящего сигнала
MAPL_DL = TxPowerBS - FeederLoss + AntGainBS + MIMO_Gain - IM - PenetrationM - RxSensUL 
print(f"Максимально допустимые потери Downlink: {MAPL_DL:.4f} дБ")

# 3. Модели распростронения сигнала
d = np.linspace(10, 5000, 500) # метров
d_km = d / 1000 # в некоторых формулах нужны км

# Модель UMiNLOS (Urban Micro Non-Line-of-Sight)
f_GHz = f / 1000  # переводим в ГГцы
PL_UMiNLOS = 26 * np.log10(f_GHz) + 22.7 + 36.7 * np.log10(d)

# Модель Окумура-Хата и ее модификация COST231
h_BS = 50 # высота БС, м
h_MS = 1 # высота абоненского утройства, м

A = 46.3 # частота между 1500-2000 Мгц
B = 33.9

Lclutter = 0 # для городской среды

a = 3.2 * (math.log10(11.75 * h_MS))**2 - 4.97
s = 44.9 - 6.55 * math.log10(f)

PL_COST231= A + B * math.log10(f) - 13.82 * math.log10(h_BS) - a + s * np.log10(d_km) + Lclutter

# Модель Walfish-Ikegami

# При прямой видимости
L_los = 42.6 + 20 * math.log10(f) + 26 *  np.log10(d_km)

# При отсутствии прямой видимости

h_b = 20  # высота зданий
w = 20     # ширина улиц
b = 50  # среднее расстояние между зданиями
phi = 45          # угол между направлением сигнала и улицей

# L0 - потери в свободном пространстве
L0 = 32.44 + 20 * np.log10(f) + 20 * np.log10(d_km)

# L2 - потери от дифракции на крышах
delta_h = h_b - h_MS # разность между высотой зданий и абонентом
L2 = -16.9 - 10 * np.log10(w) + 10 * np.log10(f) + 20 * np.log10(delta_h)

if 0 <= phi < 35:
    L_phi = -10 + 0.354 * phi
elif 35 <= phi < 55:
    L_phi = 2.5 + 0.075 * (phi - 35)
elif 55 <= phi < 90:
    L_phi = 4.0 - 0.114 * (phi - 55)

L2 += L_phi

# L1 - потери от отражений от стен
if h_BS > h_b:
    L11 = -18 * np.log10(1 + h_BS - h_b)
else:
    L11 = 0

# k_a 
k_a = np.where(h_BS > delta_h, 
               54,
               np.where(d_km > 0.5, 
                        54 - 0.8 * (h_BS - delta_h),
                        54 - 0.8 * (h_BS - delta_h) * (d_km / 0.5)))

# k_d 
k_d = np.where(h_BS > delta_h,
               18,
               18 - 15 * (h_BS - delta_h) / delta_h)

k_f = -4 + 0.7 * (f/925 - 1)

L1 = L11 + k_a + k_d * np.log10(d_km) + k_f * np.log10(f) - 9 * np.log10(b)

# Итоговые потери Walfish-Ikegami NLOS
L1_plus_L2 = L1 + L2
PL_Walfish_NLOS = np.where(L1_plus_L2 > 0, L0 + L1 + L2, L0)

# Построение графиков
plt.figure(figsize=(10, 6))
plt.plot(d, PL_COST231, 'b-', label='COST 231 Hata', linewidth=2)
plt.plot(d, PL_UMiNLOS, 'purple', label='UMiNLOS', linewidth=2)
plt.plot(d, PL_Walfish_NLOS, 'green', label='Walfish-Ikegami NLOS', linewidth=2) 
plt.plot(d, L_los, 'orange', label='Walfish-Ikegami LOS', linewidth=2) 
plt.axhline(y=MAPL_UL, color='red', linestyle='--', label=f'MAPL_UL = {MAPL_UL:.1f} дБ')
plt.axhline(y=MAPL_DL, color='pink', linestyle='--', label=f'MAPL_DL = {MAPL_DL:.1f} дБ')

plt.xlabel('Расстояние (м)')  
plt.ylabel('Потери (дБ)')
plt.title('Сравнение моделей распространения сигнала')
plt.grid(True)
plt.legend()
plt.show()


# 4. Расчет радиусов покрытия и количества БС
def find_distance(PL_model, d, MAPL_value):
    if MAPL_value < np.min(PL_model) or MAPL_value > np.max(PL_model):
        return np.nan
    return np.interp(MAPL_value, PL_model, d)

# Для микросот используем UMiNLOS модель
d_UL_UMI = find_distance(PL_UMiNLOS, d, MAPL_UL)  
d_DL_UMI = find_distance(PL_UMiNLOS, d, MAPL_DL) 


# Для макросот используем COST231 Hata
d_UL_macro = find_distance(PL_COST231, d, MAPL_UL)  
d_DL_macro = find_distance(PL_COST231, d, MAPL_DL) 

R_micro = min(d_UL_UMI, d_DL_UMI)
R_macro = min(d_UL_macro, d_DL_macro)


# Площади покрытия для 3-секторных БС
S_macro = 1.95 * (R_macro / 1000) ** 2  # км²
S_micro = 1.95 * (R_micro / 1000) ** 2  # км²

# Территории для покрытия
S_total = 100  # км² - общая территория (макросоты)
S_indoor = 4   # км² - внутренние помещения (микросоты)

# Количество БС
N_BS_macro = math.ceil(S_total / S_macro)  # внешняя территория
N_BS_micro = math.ceil(S_indoor / S_micro) # внутренние помещения


print(f"\nОграничивающий радиус COST231 Hata: {R_macro:.3f} м")
print(f"Площадь одной БС COST231 Hata: {S_macro:.3f} км²")
print(f"Необходимое количество БС = {N_BS_macro} шт.")

print(f"\nОграничивающий радиус UMiNLOS: {R_micro:.3f} м")
print(f"Площадь одной БС UMiNLOS: {S_micro:.3f} км²")
print(f"Необходимое количество БС = {N_BS_micro:} шт.")