# Especificación Formal (VDM++) y Verificación (NuSMV / UPPAAL) de un Dron Cuadricóptero Autónomo

Proyecto final del curso **Aspectos Formales de Especificación y Verificación** — Escuela Profesional de Ingeniería de Sistemas, **Universidad Nacional de San Agustín de Arequipa (UNSA)**, 2026.

## Integrantes del Equipo

| Apellidos y Nombres | Correo Institucional |
|---|---|
| Arce Mayhua, Leonardo Ruben | `larcem@unsa.edu.pe` |
| Basurco Casani, Jeferson Joao | `jbasurco@unsa.edu.pe` |
| Larico Rodriguez, Bryan Fernando | `blaricor@unsa.edu.pe` |
| Carrillo Villalta, Gustavo Alonso | `gcarrillov@unsa.edu.pe` |

- **Docente Asesora:** Mg. Maribel Molina Barriga

---

## Descripción General

Este repositorio contiene los modelos formales ejecutables y verificables del controlador de vuelo autónomo de un **dron cuadricóptero**, enfocado en garantizar por construcción la seguridad frente a tres amenazas críticas:

1. **RF1 — Gestión Energética Dinámica:** preserva el invariante $E_a \ge E_r + E_s$ ($E_a \le 100$, $E_s > 0$) y un historial monótono no creciente.
2. **RF2 — Evasión de Colisiones 3D:** garantiza la barrera dura de separación $d \ge 7.0\text{ m}$ ($d^2 \ge 49$) y dispara evasión preventiva al detectar un vecino dentro del radio de alerta temprana $D_{\text{alerta}} = 12.0\text{ m}$.
3. **RF3–RF4 — Tolerancia a Fallas de Propulsores y Aterrizaje de Emergencia:** monitorea las 4 hélices (`{1, 2, 3, 4}`), clasifica la propulsión en `<NORMAL>`, `<DEGRADADO_3>` y `<DEGRADADO_HELICOIDAL>` (basado en Mueller & D'Andrea, ICRA 2014) y fuerza la transición irreversible al pozo seguro `<ATERRIZAJE_EMERGENCIA>` si $n_{\text{act}} < 3$ o si se activa alarma `<CRITICO>`.
4. **RF5–RF6 — Exclusión Mutua y Determinismo:** un único modo de vuelo activo en `{<VUELO_NORMAL>, <EVASION>, <RETORNO_BASE>, <ATERRIZAJE_EMERGENCIA>}` con prioridad estricta `AE > EV > RB > VN`.

---

## Estructura del Repositorio

```text
repositorio_github/
├── README.md                          # Guía de orientación rápida
├── .gitignore
├── vdmpp/                             # Especificación Formal en VDM++ (8 clases)
│   ├── Tipos.vdmpp                    # Tipos abstractos (token, quote), Pos3D, constantes y dist2
│   ├── GestionEnergia.vdmpp           # Registro EstadoEnergia (INV1) e historial monótono (INV5)
│   ├── SistemaPropulsion.vdmpp        # Mapa de 4 hélices (INV3) y clasificación de degradación
│   ├── EspacioAereo.vdmpp             # Mapa de vecinos con separación >= 7m (INV2) y alerta < 12m
│   ├── Mision.vdmpp                   # Secuencia ordenada de waypoints sin repeticiones (INV4)
│   ├── Dron.vdmpp                     # Controlador maestro con transiciones T1..T8 (INV7)
│   ├── Flota.vdmpp                    # Mapa inyectivo IdDron -> Dron (INV6)
│   ├── Test.vdmpp                     # Suite de 8 casos de prueba (CP1..CP8) para cobertura 100%
│   └── resultados_vdmj/
│       ├── typecheck_y_pog.txt        # Salida real de verificación sintáctica, de tipos y 43 POs
│       └── ejecucion_y_cobertura.txt  # Salida real de CP1..CP8 y cobertura 100.0% en VDMJ
├── nusmv/                             # Model Checking Simbólico en NuSMV 2.7.1
│   ├── dron_autonomo.smv              # Sistema de transición M = (Q, V, q0, sigma0, T) + 15 specs
│   └── resultados_nusmv.txt           # Salida real: 15/15 propiedades TRUE, 300 estados alcanzables
└── uppaal/                            # Model Checking en Tiempo Real en UPPAAL
    ├── dron_autonomo.xml              # Red de 4 autómatas temporizados + 10 consultas embebidas
    └── propiedades.q                  # Archivo independiente con las 10 consultas CTL/TCTL
```

---

## Guía Rápida de Ejecución y Reproducibilidad

### 1. Especificación y Cobertura VDM++ (VDMJ / Overture / VDMTools)

**Opción A — CLI con VDMJ (Java 11+):**
1. Descargar `vdmj-4.6.0-P.jar` desde Maven Central (`https://repo1.maven.org/maven2/dk/au/ece/vdmj/vdmj/4.6.0-P/vdmj-4.6.0-P.jar`).
2. Ejecutar verificación de tipos estricta y generación de obligaciones de prueba (POG):
   ```bash
   java -jar vdmj-4.6.0-P.jar -vdmpp -strict -p vdmpp/
   ```
3. Ejecutar la suite de pruebas y calcular cobertura línea por línea:
   ```bash
   java -jar vdmj-4.6.0-P.jar -vdmpp -strict -i vdmpp/
   ```
   Dentro del intérprete interactivo escribir:
   ```text
   init
   print new Test().EjecutarTodas()
   coverage
   quit
   ```

**Opción B — Overture IDE / VSCode VDM:**
- Importar la carpeta `vdmpp/` como proyecto VDM++ y lanzar la configuración de depuración sobre `new Test().EjecutarTodas()` activando el reporte de cobertura.

**Resultados reales obtenidos con VDMJ 4.6.0-P (`resultados_vdmj/`):**
- **Sintaxis y Tipos (`-strict`):** 8 clases analizadas, `0` errores sintácticos, `0` errores de tipos.
- **Proof Obligations (`-p`):** `43` obligaciones de prueba generadas sin errores de análisis.
- **Suite `Test` (`CP1`–`CP8`):** `8/8` casos `true` con chequeo dinámico de invariantes (`INV1`–`INV7`), `pre` y `post` activos.
- **Cobertura Global:** **100.0%** en las 8 clases (`Tipos`, `GestionEnergia`, `SistemaPropulsion`, `EspacioAereo`, `Mision`, `Dron`, `Flota`, `Test`).

---

### 2. Model Checking Simbólico en NuSMV 2.7.1

Con [NuSMV](https://nusmv.fbk.eu/) instalado en el equipo:

```bash
NuSMV -r nusmv/dron_autonomo.smv
```

**Resultados reales obtenidos (`nusmv/resultados_nusmv.txt`):**
- **Espacio de estados explorado:** `300` estados alcanzables (`2^8.22882`) de `768` totales; diámetro del sistema = `10`.
- **Propiedades verificadas:** **15/15 verdaderas (`is true`)**, incluyendo 7 propiedades CTL (`AG`, `EF`, `EX`) y 8 propiedades LTL (`G`, `F`, `X`): seguridad energética (`INV1`), monotonicidad del consumo (`INV5`), degradación irreversible de hélices (`INV3`), activación obligatoria y terminalidad de `<ATERRIZAJE_EMERGENCIA>` (`T5–T8`), irreversibilidad de `<RETORNO_BASE>`, prioridad `EV > RB` y alcanzabilidad de todos los modos.

---

### 3. Model Checking en Tiempo Real con UPPAAL

1. Descargar UPPAAL (licencia académica gratuita) desde [https://uppaal.org/downloads/](https://uppaal.org/downloads/).
2. Abrir UPPAAL y cargar `uppaal/dron_autonomo.xml` (`File -> Open System`).
3. Pestaña **Editor:** inspeccionar los 4 autómatas temporizados (`ControladorVuelo`, `MonitorEnergia`, `SensorProximidad`, `SistemaPropulsion`), el reloj `t_ev <= 5` de acotamiento evasivo y los canales `broadcast chan`.
4. Pestaña **Simulator:** ejecutar trazas manuales o aleatorias para observar la sincronización entre procesos.
5. Pestaña **Verifier:** las 10 consultas CTL/TCTL (`Q1`–`Q10`, también disponibles en `uppaal/propiedades.q`) ya están cargadas; pulsar **Check** para verificar `A[] not deadlock`, invariantes de seguridad (`A[]`), alcanzabilidad (`E<>`) y vivacidad (`-->`).

---

## Licencia y Uso Académico

Material desarrollado con fines académicos para la Escuela Profesional de Ingeniería de Sistemas — UNSA (2026).
