# Double-Gated MoS2 FET Compact I-V Model

A highly calibrated, mathematically continuous MATLAB implementation of a compact I-V model for Double-Gated $MoS_2$ Field-Effect Transistors (FETs). This model accurately reproduces short-channel effects for 500 nm, 200 nm, and 60 nm channel lengths, resolving common mathematical discontinuities found in standard compact modeling.

## 🚀 How to Run
1. Download or clone this repository.
2. Open `MoS2_Compact_Model.m` in MATLAB.
3. Run the script.
4. The code will automatically generate four publication-ready figures mapping 1-to-1 with standard research data:
   * **Linear Transfer Characteristics** ($I_{ds}$ vs. $V_{gs}$)
   * **Log Transfer Characteristics** ($I_{ds}$ vs. $V_{gs}$)
   * **Transconductance** ($g_m$ vs. $V_{gs}$)
   * **Output Characteristics** ($I_{ds}$ vs. $V_{ds}$)

## 🧠 Key Physics & Mathematical Features

Developing this model required overcoming several classic compact modeling traps to achieve SPICE-level stability. Key structural features include:

### 1. Hyperbolic Transconductance ($g_m$) Smoothing
Standard models often use piecewise functions or `tanh` boundaries to bridge the subthreshold and saturation regimes, which results in violent, non-physical spikes or "cliffs" in the $g_m$ derivative curves. This model implements a **micro-floor hyperbolic smoothing function** for the saturation voltage:
$$V_{ds\_sat} = \sqrt{V_{sat\_raw}^2 + (1\text{ mV})^2}$$
This guarantees a 100% mathematically continuous derivative (yielding perfect $g_m$ bell curves) without artificially inflating the peak strong-inversion current.

### 2. Native Drift-Diffusion Addition
Instead of using absolute value wrappers (`abs()`) to handle electron charge—which destroys the physical continuity of the equations—the inversion charge density ($Q$) is defined mathematically as a **strictly positive magnitude**:
$$Q = C_t \cdot \alpha \cdot V_{th} \cdot \mathcal{W}\left(\frac{C_{dq}}{C_t} e^{arg}\right)$$
By keeping $Q_s$ and $Q_d$ natively positive, the drift current ($Q_s^2 - Q_d^2$) remains strictly positive, and the diffusion current seamlessly adds to the total using a native physical subtraction ($-V_{th}(Q_s - Q_d)$).

### 3. Independent Mobility Degradation ($V_{norm}$)
To accurately map the specific degradation profiles of varying channel lengths, the overdrive normalization voltage ($V_{norm}$) is parameterized per device. This prevents crossover bugs and allows individual devices (like the 200 nm channel) to flatten out at their unique physical amplitudes without detuning the rest of the array.

### 4. Ideality Factor ($\alpha$) Positioning
The subthreshold ideality factor ($\alpha$) is positioned strictly inside the exponent of the Lambert $\mathcal{W}$ argument. This correctly scales the subthreshold slope ($SS = \alpha \cdot 60$ mV/dec) without accidentally acting as a linear multiplier that would artificially inflate the velocity-saturated drift current.
