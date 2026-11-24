// ============================================================================
// Consultas de Verificacion Formal en UPPAAL (CTL / Timed CTL)
// Archivo companero de dron_autonomo.xml (las consultas ya vienen embebidas)
// ============================================================================

// Q1 (Ausencia de bloqueos / Deadlock-freedom)
A[] not deadlock

// Q2 (Seguridad energetica - RF1 / INV1)
A[] (energia >= E_UMBRAL and energia <= 100)

// Q3 (Integridad del sistema de propulsion - RF3 / INV3)
A[] (helices_activas >= 2 and helices_activas <= 4)

// Q4 (Seguridad critica obligatoria - RF4 / INV7 / T5-T7)
A[] ((helices_activas < 3 or alarma_critica) imply Controlador.AterrizajeEmergencia)

// Q5 (Condicion segura de operacion nominal)
A[] (Controlador.VueloNormal imply (helices_activas >= 3 and not alarma_critica))

// Q6 (Restriccion de tiempo real en maniobra evasiva)
A[] (Controlador.Evasion imply Controlador.t_ev <= T_MAX_EVASION)

// Q7 (Alcanzabilidad del modo EVASION - T1)
E<> Controlador.Evasion

// Q8 (Alcanzabilidad del modo RETORNO_BASE - T3/T4)
E<> Controlador.RetornoBase

// Q9 (Alcanzabilidad del modo ATERRIZAJE_EMERGENCIA - T5-T7)
E<> Controlador.AterrizajeEmergencia

// Q10 (Vivacidad / Leads-to: falla de 2 helices siempre lleva a AE)
Propulsion.DegradadoHelicoidal --> Controlador.AterrizajeEmergencia
