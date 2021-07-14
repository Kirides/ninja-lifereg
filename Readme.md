# Verwendete Bibliotheken

- Ikarus (Ninja-Intern)
- LeGo (Ninja-Intern)

# Build Anleitung

1. `LifeReg.vm` auf GothicVDFS ziehen.
1. Build Volume drücken.
1. ~~Sytempack 1.7+ installieren, wenn noch nicht getan.~~ *Nicht mehr zwangsweise benötigt*
1. Ninja 2+ installieren, wenn noch nicht getan.
1. Erstellte .VDF in das "Gothic2\Data"-Verzeichnis legen.
1. 0,3% Lebensregeneration jede Sekunde

# Konfiguration

Um die Standardwerte zu überschreiben,
trägt man folgendes (z.B. ans Ende) in die System\Gothic.ini ein:

```
[NINJA_LIFEREG]
TICKRATE=1000
PERMILLE=3
INFIGHT=0
```

## Erklärung

`PERMILLE`: Regenerationsmenge in Skala 1 = 0,1%, 10 = 1% pro Sekunde, ...
`TICKRATE`: Häufigkeit der Regeneration in Millisekunden  
`INFIGHT`: Gibt an, ob im Kampf auch regeneriert werden darf
