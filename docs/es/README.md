<div align="center">

<img src="../../assets/banner.svg" alt="iPhone Duo Agent Skill — diseñar, auditar, adaptar" width="100%">

<br>

**Una Agent Skill respaldada por fuentes para construir una sola app de iPhone adaptativa que permanezca coherente en todas las posturas de iPhone Duo.**

<sub>[English](../../README.md) · Español · [한국어](../ko/README.md)</sub>

<img src="../../assets/meta.svg" alt="Licencia MIT · manifiesto de API de Apple gobernado por esquema · verificación local · iOS 27.1 · Agent Skills" width="100%">

</div>

## Principio central

No construyas una interfaz paralela solo para iPhone Duo.

```swift
if isDuo {
    DuoDashboard()
} else {
    Dashboard()
}
```

Ese enfoque crea dos productos que terminan divergiendo. La skill se apoya en una regla:

> **El layout reacciona al espacio disponible. Solo la interacción física puede reaccionar a la bisagra.**

Primero se construye una jerarquía adaptativa que funcione en todos los tamaños. Las API
exclusivas de Duo se incorporan después, únicamente cuando una capacidad física aporta valor
que el layout adaptable normal no puede expresar.

## Instalación

```bash
git clone https://github.com/eisenjimmy/iphone-duo-skill.git

mkdir -p ~/.agents/skills
ln -sfn "$PWD/iphone-duo-skill/skills/iphone-duo" ~/.agents/skills/iphone-duo
```

| Entorno | Ruta |
|---|---|
| Codex | `~/.codex/skills/iphone-duo` |
| Cursor / universal | `~/.agents/skills/iphone-duo` |

El contrato canónico está en
[`skills/iphone-duo/SKILL.md`](../../skills/iphone-duo/SKILL.md).

## Ejemplos de uso

```text
Usa la skill iphone-duo para auditar este repositorio. No cambies código todavía.
Devuelve evidencia por archivo, severidad, tier y el plan coherente más pequeño.
```

```text
Usa la skill iphone-duo para adaptar esta app a iPhone Duo.
Conserva navegación y estado durante el redimensionado. Completa Tier 1 antes de usar API exclusivas de Duo.
```

```text
Revisa esta pantalla para uso con iPhone Duo parcialmente abierto.
Comprueba interferencia del pliegue, alcance, continuidad de estado y si algo necesita realmente la bisagra.
```

## Tres tiers

| Tier | Objetivo | Ejemplos |
|---|---|---|
| **Tier 1** | Adaptación universal | size classes, `NavigationSplitView`, grids adaptativos, `ViewThatFits`, `AnyLayout`, safe areas |
| **Tier 2** | Presentación consciente de Duo | reserved regions, displacement, `ArrangementView`, barras verticales, overflow |
| **Tier 3** | Capacidad física exclusiva de Duo | hinge input, múltiples escenas, scene accessories, coordinación de cámara |

Tier 1 siempre va primero. Mencionar iPhone Duo no justifica por sí solo usar Tier 2 o Tier 3.

## Lo que la skill prohíbe

- usar identidad del dispositivo como selector de layout;
- usar el ángulo de la bisagra para decidir columnas, sidebars o navegación;
- duplicar árboles de estado compact/expanded;
- depender de `UIScreen.main` o dimensiones físicas copiadas;
- colocar contenido crítico sobre el pliegue o una oclusión;
- inventar símbolos de Apple que no estén en el manifiesto;
- tratar las pantallas interior y exterior como dos canvases independientes.

## Safe area, reserved region y hinge input no son lo mismo

```text
safe area       → protección frente a UI del sistema y bordes
reserved region → zona física/sistema dentro de la geometría utilizable
hinge input     → movimiento físico para interacción o efectos
```

El pliegue es una región de **division**. Las cámaras son regiones de **occlusion**.
La distinción determina si el contenido debe dividirse, desplazarse o simplemente mantenerse
fuera de una zona cubierta.

## ArrangementView

`ArrangementView` sirve para reorganizar **dos superficies relacionadas**, no para sustituir
la navegación de la app.

- split: ambas superficies merecen espacio dedicado;
- overlay: una superficie aparece delante de la otra.

En overlay, **la vista primary es el foreground**. Cuando el dispositivo está parcialmente
abierto, el sistema puede mover las dos superficies a regiones separadas. Primary/secondary
debe elegirse por semántica visual, no por nombres genéricos como “player” o “queue”.

## Capa factual

Todos los símbolos de Apple usados por la skill viven en
[`data/api-manifest.json`](../../skills/iphone-duo/data/api-manifest.json):

- `verified`: existe una página DocC actual de Apple;
- `apple-sourced`: el nombre procede de material de Apple pero todavía no hay una página DocC dedicada;
- `conflicted`: los propios materiales de Apple no coinciden y se debe consultar el SDK activo.

La estructura del manifiesto está definida por
[`api-manifest.schema.json`](../../skills/iphone-duo/data/api-manifest.schema.json).

## Verificación local

```bash
bash skills/iphone-duo/scripts/verify-all.sh
```

La suite offline valida estructura, contrato del manifiesto, JSON, shell, enlaces, referencias
renombradas, assets y el comportamiento básico del auditor.

Para volver a resolver también la documentación de Apple:

```bash
bash skills/iphone-duo/scripts/verify-all.sh --online
```

Para auditar una app:

```bash
bash skills/iphone-duo/scripts/audit-duo.sh ~/code/MiApp
```

El auditor es heurístico: encuentra candidatos, no demuestra por sí solo que exista un bug.

## Estructura

```text
skills/iphone-duo/
├── SKILL.md
├── data/
│   ├── api-manifest.json
│   ├── api-manifest.schema.json
│   └── patterns.json
├── scripts/
│   ├── audit-duo.sh
│   ├── verify-all.sh
│   └── verify-manifest.sh
└── references/
    ├── 01-design-and-layout.md
    ├── 02-bars-and-navigation.md
    ├── 03-fold-arrangements.md
    ├── 04-hardware-scenes-hinge.md
    ├── 05-camera.md
    ├── 06-testing-and-review.md
    ├── 07-api-cookbook.md
    └── 08-sources.md
```

La documentación técnica canónica permanece en inglés en `SKILL.md` y `references/`; esta
página es un resumen humano para reducir el riesgo de divergencia entre traducciones y API.

## Jerarquía de fuentes

Cuando las fuentes discrepan:

1. SDK/compiler activo;
2. documentación API actual de Apple;
3. HIG actual de Apple;
4. Tech Talks y sample code de Apple;
5. síntesis de este repositorio;
6. ejemplos de terceros.

La procedencia completa está en
[`references/08-sources.md`](../../skills/iphone-duo/references/08-sources.md).

[MIT](../../LICENSE) · [Security](../../SECURITY.md) · [Changelog](../../CHANGELOG.md) · [Notice](../../NOTICE.md)
