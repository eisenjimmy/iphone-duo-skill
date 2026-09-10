<div align="center">

<img src="../../assets/banner.svg" alt="iPhone Duo Agent Skill — 설계, 점검, 적응" width="100%">

<br>

**모든 iPhone Duo 자세와 화면 크기에서 하나의 앱이 일관되게 동작하도록 만드는 source-backed Agent Skill입니다.**

<sub>[English](../../README.md) · [Español](../es/README.md) · 한국어</sub>

<img src="../../assets/meta.svg" alt="MIT 라이선스 · schema 기반 Apple API manifest · 로컬 검증 · iOS 27.1 · Agent Skills" width="100%">

</div>

## 핵심 원칙

iPhone Duo를 위해 별도의 UI 트리를 만들지 않습니다.

```swift
if isDuo {
    DuoDashboard()
} else {
    Dashboard()
}
```

이 방식은 화면 상태가 변할수록 두 UI가 서로 다른 제품으로 갈라지기 쉽습니다.
이 스킬은 다음 한 문장을 중심으로 설계되어 있습니다.

> **레이아웃은 사용 가능한 공간에 반응한다. 물리적 상호작용만 힌지에 반응할 수 있다.**

먼저 모든 크기에서 잘 동작하는 하나의 adaptive hierarchy를 만들고, 그 다음에만
reserved region, `ArrangementView`, hinge, scene accessory 같은 Duo 고유 기능을 추가합니다.

## 설치

```bash
git clone https://github.com/eisenjimmy/iphone-duo-skill.git

mkdir -p ~/.agents/skills
ln -sfn "$PWD/iphone-duo-skill/skills/iphone-duo" ~/.agents/skills/iphone-duo
```

도구별 경로:

| 도구 | 경로 |
|---|---|
| Codex | `~/.codex/skills/iphone-duo` |
| Cursor / 범용 | `~/.agents/skills/iphone-duo` |

실제 agent contract는 [`skills/iphone-duo/SKILL.md`](../../skills/iphone-duo/SKILL.md)입니다.

## 사용 예시

```text
iphone-duo 스킬로 이 저장소를 audit해 줘. 아직 코드는 수정하지 마.
파일별 근거, severity, tier, 그리고 가장 작은 구현 계획을 반환해.
```

```text
iphone-duo 스킬로 이 앱을 iPhone Duo에 맞게 적응시켜 줘.
리사이즈 중 navigation과 view state를 유지하고 Tier 1을 먼저 끝내.
```

```text
이 화면을 partially-open iPhone Duo 기준으로 검토해 줘.
fold interference, reachability, state continuity와 실제 hinge input이 필요한지 확인해.
```

## 세 개의 Tier

| Tier | 목적 | 예시 |
|---|---|---|
| **Tier 1** | 모든 화면 크기에서 기본 구조를 adaptive하게 만들기 | size class, `NavigationSplitView`, adaptive grid, `ViewThatFits`, `AnyLayout`, safe area |
| **Tier 2** | Duo의 물리적 화면 구조에 맞게 표현 조정 | reserved region, displacement, `ArrangementView`, vertical bar, overflow |
| **Tier 3** | Duo 하드웨어 자체를 제품 기능으로 사용 | hinge input, multiple scenes, scene accessory, camera direction coordination |

Tier 1이 항상 먼저입니다. “Duo 지원”이라는 이유만으로 Tier 2/3 API를 쓰지 않습니다.

## 이 스킬이 금지하는 것

- `isDuo`, device model, display identity로 일반 레이아웃을 결정하지 않기
- hinge angle로 sidebar, column, navigation collapse를 결정하지 않기
- compact/expanded용 state tree를 따로 만들지 않기
- `UIScreen.main`이나 복사한 hardware width를 레이아웃 기준으로 사용하지 않기
- 중요한 버튼, QR code, drag handle, label을 fold/occlusion 위에 두지 않기
- manifest에 없는 Apple symbol을 그럴듯하게 만들어내지 않기
- inner/outer display를 독립적인 두 canvas처럼 직접 관리하지 않기

## Safe area, reserved region, hinge는 서로 다릅니다

```text
safe area       → system UI / edge protection
reserved region → fold나 camera처럼 usable geometry 내부의 물리적 영역
hinge input     → 실제 기기 움직임을 이용한 interaction/effect
```

fold는 **division region**, camera는 **occlusion region**입니다. 이 차이를 구분해야
content를 split할지, 조금 이동할지, 단순히 가려지지 않게 할지 올바르게 결정할 수 있습니다.

## ArrangementView

`ArrangementView`는 두 개의 관련 surface를 재배치할 때 사용합니다. 앱 navigation을
대체하는 컨테이너가 아닙니다.

- split: 두 surface가 각각 독립된 공간을 가져야 할 때
- overlay: 한 surface가 다른 surface 앞에 놓일 때

overlay에서 **primary view가 foreground**입니다. partially open 상태에서는 시스템이 두
surface를 서로 다른 영역으로 이동시킬 수 있습니다. 따라서 “player니까 primary”처럼 이름만
보고 role을 정하지 말고 실제 foreground 의미에 따라 primary/secondary를 결정해야 합니다.

## API 사실 검증

Apple symbol은 모두
[`data/api-manifest.json`](../../skills/iphone-duo/data/api-manifest.json)에 기록됩니다.

- `verified`: 현재 Apple DocC 페이지가 확인됨
- `apple-sourced`: Apple sample/chapter에서 확인됐지만 전용 DocC 페이지는 아직 없음
- `conflicted`: Apple 자료끼리 이름/표기가 충돌함 — active SDK 확인 필요

manifest 구조는
[`api-manifest.schema.json`](../../skills/iphone-duo/data/api-manifest.schema.json)이 정의합니다.

## 로컬 검증

변경 후 전체 검증:

```bash
bash skills/iphone-duo/scripts/verify-all.sh
```

Apple 문서 URL까지 다시 확인:

```bash
bash skills/iphone-duo/scripts/verify-all.sh --online
```

실제 앱 저장소 audit:

```bash
bash skills/iphone-duo/scripts/audit-duo.sh ~/code/MyApp
```

`audit-duo.sh` 결과는 heuristic입니다. grep hit 자체가 버그라는 뜻은 아니므로 agent가 실제
layout decision인지 확인해야 합니다.

## 문서 구조

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

세부 기술 규칙의 canonical source는 영어 `SKILL.md`와 `references/`입니다. 한국어 문서는
빠르게 이해하기 위한 human-facing summary로 유지합니다.

## 출처 우선순위

자료가 충돌하면 다음 순서를 따릅니다.

1. active SDK/compiler
2. 최신 Apple API documentation
3. 최신 Apple HIG
4. Apple Tech Talk / sample code
5. 이 저장소의 synthesis
6. third-party example

전체 Apple 출처는
[`references/08-sources.md`](../../skills/iphone-duo/references/08-sources.md)에 정리되어 있습니다.

[MIT](../../LICENSE) · [Security](../../SECURITY.md) · [Changelog](../../CHANGELOG.md) · [Notice](../../NOTICE.md)
