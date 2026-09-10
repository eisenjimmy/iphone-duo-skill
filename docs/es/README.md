<div align="center">

<img src="../../assets/banner.svg" alt="iPhone Duo Agent Skill — diseñar, auditar, adaptar" width="100%">

<br>

**Enseña a tu agente de código a construir una sola app de iPhone adaptativa que se mantenga coherente en todas las posturas.**

<sub>[English](../../README.md) · Español · [한국어](../ko/README.md)</sub>

<img src="../../assets/meta.svg" alt="Licencia MIT · 59 símbolos de Apple registrados · 34 verificados en CI · iOS 27.1 · formato Agent Skills" width="100%">

</div>

<br>

<div align="center">
<img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/tile/Apple-iPhone-Duo-opening-iPhone-Duo-260909-lp.jpg.landing-big_2x.jpg" alt="iPhone Duo abriéndose, mostrando la pantalla interior" width="82%">
<br><sub>iPhone Duo · imagen © Apple Inc., servida desde apple.com — <a href="../../NOTICE.md">no redistribuida aquí</a></sub>
</div>

<br>

## El problema

iPhone Duo tiene dos pantallas, cinco posturas, una bisagra, un pliegue que atraviesa tu
layout y dos cámaras frontales. Pídele a un agente que "añada compatibilidad con iPhone
Duo" y recurrirá a la peor respuesta posible:

```swift
if isDuo { DuoDashboard() } else { Dashboard() }   // dos interfaces que divergen de inmediato
```

Esta skill lo impide. Es un **manual de reglas**, no una biblioteca: unos 3.300 tokens que se cargan siempre,
más referencias (~20.000 tokens en total) que solo entran cuando la tarea las necesita. Enseña una
sola idea:

> **El layout reacciona al espacio disponible. La interacción física puede reaccionar a la bisagra.**

<br>

<div align="center">
<img src="../../assets/poses.svg" alt="Las cinco posturas del iPhone Duo — cerrado, vertical, horizontal, apoyado y de pie — y el layout que implica cada una" width="100%">
</div>

<br>

## Inicio rápido

```bash
git clone https://github.com/eisenjimmy/iphone-duo-skill.git

# Enlace simbólico para que 'git pull' mantenga la skill al día (recomendado)
mkdir -p ~/.claude/skills
ln -sfn "$PWD/iphone-duo-skill/skills/iphone-duo" ~/.claude/skills/iphone-duo
```

<details>
<summary><b>Otros agentes y rutas de instalación</b></summary>

<br>

La skill es un directorio normal. Apunta cualquier entorno compatible con Agent Skills:

| Entorno | Ruta |
|---|---|
| Claude Code (global) | `~/.claude/skills/iphone-duo` |
| Claude Code (un proyecto) | `<tu-app>/.claude/skills/iphone-duo` ← normalmente lo que quieres |
| Codex | `~/.codex/skills/iphone-duo` |
| Cursor / universal | `~/.agents/skills/iphone-duo` |

Usa el enlace simbólico de arriba. Si prefieres copiar, **reemplaza en vez de fusionar**, o
quedarán archivos renombrados:

```bash
rm -rf ~/.claude/skills/iphone-duo
cp -R iphone-duo-skill/skills/iphone-duo ~/.claude/skills/
```

**Comprueba que cargó:** ejecuta `/skills` en Claude Code, o simplemente pregunta:
*"¿tienes la skill iphone-duo?"*

</details>

<br>

## Cómo usarla

Tres prompts cubren casi todo.

```text
Usa la skill iphone-duo para auditar este repositorio. No cambies código todavía.
Dame evidencia por archivo, un tier para cada problema y el plan más pequeño posible.
```

```text
Usa la skill iphone-duo para adaptar esta app a iPhone Duo. Conserva la navegación
y el estado de las vistas durante el redimensionado. Termina el Tier 1 antes de
usar cualquier API exclusiva de Duo.
```

```text
Revisa esta pantalla para uso con el iPhone Duo parcialmente abierto: interferencia
del pliegue, alcanzabilidad, y si algo aquí debería usar realmente la bisagra.
```

### Cómo se ve una buena ejecución

```text
[P1  ] tier 1  Device-identity layout branch  (3 hits)  <-- must be zero
         why  Layout must react to available space, not to which device it runs on.
         fix  Size classes, container geometry, ViewThatFits/AnyLayout.
           Sources/Dashboard.swift:44  if isDuo { DuoDashboard() } else { Dashboard() }

[P2  ] tier 2  Fixed grid column count  (1 hits)
         why  Apple advises an EVEN column count so content divides across the fold.
         fix  GridItem(.adaptive(minimum:)) sized to keep the count even.
           Sources/Gallery.swift:31    count: 3

VERDICT: material refactor needed — Device-identity layout branch (3)
```

> **Si tu Xcode es anterior a 27.1**, el agente marcará el trabajo exclusivo de Duo como
> `SDK-blocked` y se detendrá ahí. Eso es correcto, no un error: el Tier 1 sigue mejorando
> tu app en todos los dispositivos a los que ya das soporte.

<br>

<div align="center">
<img src="../../assets/workflow.svg" alt="Cómo trabaja el agente: escanear, clasificar, planificar, implementar Tier 1 primero, verificar en todas las posturas" width="100%">
</div>

<br>

## Qué sabe realmente

<div align="center">
<img src="../../assets/reserved-regions.svg" alt="Las tres regiones reservadas: oclusión de la cámara exterior, oclusión de la cámara interior y la región de plegado" width="100%">
</div>

<br>

El pliegue no es una línea que rodeas. El sistema recorta **regiones reservadas** de tu
lienzo — dos *oclusiones* de cámara y una *división* de plegado — y la diferencia importa:
**la oclusión tapa, la división parte.** Confundir una con otra es el error de layout más
común en Duo, y es justo el tipo de cosa que un agente hace mal en silencio.

La skill también recoge las partes de la guía de Apple que es fácil pasar por alto:

- La pantalla interior **en vertical conserva las barras horizontales**: la única excepción
  a los controles laterales.
- Las barras verticales están **alineadas con el hardware**, así que **no se invierten en
  idiomas de derecha a izquierda**.
- En Split View cada app coloca sus controles en su borde **exterior**.
- Las cuadrículas quieren un número **par** de columnas para dividirse limpiamente.
- Los juegos pueden fijar la orientación pero deben **llenar la pantalla**: cambia la
  relación de aspecto antes que recurrir al letterboxing.
- `builtInDuoCamera` es un **alias obsoleto de iOS 10 para una cámara trasera**. No tiene
  nada que ver con iPhone Duo, y es lo primero que encontrará un agente buscando "Duo".

<br>

## Tres tiers, en orden

<div align="center">
<img src="../../assets/tiers.svg" alt="Tier 1 base adaptativa universal, Tier 2 presentación consciente del Duo, Tier 3 capacidad exclusiva del Duo" width="100%">
</div>

<br>

La mayor parte del "soporte para iPhone Duo" es Tier 1: trabajo que mejora todos los
dispositivos a los que ya das soporte. Esta transformación real **no usa ninguna API de Duo**:

```diff
-        if isDuo && !isFolded {
-            LazyVGrid(columns: Array(repeating: GridItem(.fixed(200)), count: 3)) { … }
-                .environmentObject(wideVM)
-        } else {
-            List { … }.environmentObject(compactVM)
-                .frame(width: UIScreen.main.bounds.width)
-        }
+        NavigationSplitView {
+            SidebarList(model: model)
+        } detail: {
+            // 220 = ancho mínimo legible de la tarjeta. Comprueba que el número de
            // columnas resultante sea par — Apple no publica los tamaños en puntos del Duo.
+            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)]) {
+                ForEach(model.items) { ItemCell(item: $0) }
+            }
+        }
```

<br>

## Por qué puedes confiar en ella

Las skills que codifican un SDK en beta se pudren en silencio y luego le entregan al agente,
con total seguridad, un símbolo que nunca existió. Esta está construida para que eso no pueda
pasar sin avisar.

Cada símbolo de Apple vive en **[`data/api-manifest.json`](../../skills/iphone-duo/data/api-manifest.json)**
con un estado que la prosa no puede exagerar:

| Estado | Significado | Total |
|---|---|---|
| `verified` | La página de documentación de Apple responde ahora mismo | **34** |
| `apple-sourced` | Literal de un ejemplo de Apple; aún sin página (iOS 27.1) | **23** |
| `conflicted` | Los propios materiales de Apple se contradicen | **2** |

```bash
bash skills/iphone-duo/scripts/verify-manifest.sh
```

Vuelve a resolver todos los símbolos documentados contra developer.apple.com, falla si un
archivo de referencia nombra un símbolo que no está en el manifiesto, y **caduca solo** a los
45 días, para que una fecha de investigación obsoleta sea una CI en rojo y no una mentira
silenciosa. Se ejecuta semanalmente en CI.

El script de auditoría tampoco tiene patrones propios: ejecuta
[`data/patterns.json`](../../skills/iphone-duo/data/patterns.json), así que hay exactamente
un sitio donde añadir una regla:

```bash
bash skills/iphone-duo/scripts/audit-duo.sh ~/code/MiApp
```

<br>

## Fuentes

Todo aquí procede de Apple. Nada está inventado; las dos entradas `conflicted` existen
porque los propios materiales de Apple se contradicen, y la skill lo dice en vez de elegir
un ganador.

Los seis Tech Talks de lanzamiento —
[Design](https://developer.apple.com/videos/play/tech-talks/111466/) ·
[Prepare your app](https://developer.apple.com/videos/play/tech-talks/111461/) ·
[Raise the bar](https://developer.apple.com/videos/play/tech-talks/111462/) ·
[Strike a pose](https://developer.apple.com/videos/play/tech-talks/111463/) ·
[Displays and scenes](https://developer.apple.com/videos/play/tech-talks/111464/) ·
[Camera](https://developer.apple.com/videos/play/tech-talks/111465/) —
más las [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)
y el [portal para desarrolladores](https://developer.apple.com/iphone-duo/).
Procedencia completa: [`references/08-sources.md`](../../skills/iphone-duo/references/08-sources.md).

<br>

## Qué contiene

```text
skills/iphone-duo/
├── SKILL.md                   siempre cargado · ~3.300 tokens
├── data/
│   ├── api-manifest.json      ← la única autoridad sobre si un símbolo existe
│   └── patterns.json          ← la única lista de antipatrones
├── scripts/
│   ├── audit-duo.sh           ejecuta patterns.json sobre un código
│   └── verify-manifest.sh     revalida cada símbolo; caduca a los 45 días
└── references/                carga bajo demanda · ~20.000 tokens en total
```

<br>

## Lo que no es

Una biblioteca. No incluye Swift que puedas enlazar. Cambia cómo *razona* un agente sobre tu
código: el resultado es tu propio código, mejorado.

<br>

## Contribuir

La documentación de iPhone Duo de Apple todavía está publicándose. **Las correcciones son la
contribución más valiosa aquí.** Si un símbolo cambió de nombre o la HIG se actualizó, abre
una issue; lo más probable es que la CI ya te dé la razón.

[Guía de contribución](../../CONTRIBUTING.md) · [Código de conducta](../../CODE_OF_CONDUCT.md) · [Seguridad](../../SECURITY.md) · [Changelog](../../CHANGELOG.md)

<br>

<div align="center">
<sub>

[MIT](../../LICENSE) · Sin afiliación con Apple Inc. · [Marcas e imágenes](../../NOTICE.md)

Trabajo previo: [FloWritesCode/fwc-swiftui-skills](https://github.com/FloWritesCode/fwc-swiftui-skills)

</sub>
</div>
