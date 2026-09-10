<div align="center">

<img src="../../assets/banner.svg" alt="iPhone Duo Agent Skill — 설계, 점검, 적응" width="100%">

<br>

**하나의 적응형 iPhone 앱이 모든 자세에서 일관되게 동작하도록, 코딩 에이전트를 가르칩니다.**

<sub>[English](../../README.md) · [Español](../es/README.md) · 한국어</sub>

<img src="../../assets/meta.svg" alt="MIT 라이선스 · Apple 심볼 59개 추적 · 34개 CI 검증 · iOS 27.1 · Agent Skills 형식" width="100%">

</div>

<br>

<div align="center">
<img src="https://www.apple.com/newsroom/images/2026/09/apple-unveils-iphone-duo/tile/Apple-iPhone-Duo-opening-iPhone-Duo-260909-lp.jpg.landing-big_2x.jpg" alt="내부 디스플레이가 보이도록 펼쳐지는 iPhone Duo" width="82%">
<br><sub>iPhone Duo · 이미지 © Apple Inc., apple.com에서 직접 제공 — <a href="../../NOTICE.md">이 저장소에 재배포하지 않음</a></sub>
</div>

<br>

## 문제

iPhone Duo에는 두 개의 디스플레이, 다섯 가지 자세, 힌지, 레이아웃을 가로지르는 접힘,
그리고 두 개의 전면 카메라가 있습니다. 에이전트에게 "iPhone Duo를 지원해 줘"라고 하면
가장 나쁜 답을 내놓습니다.

```swift
if isDuo { DuoDashboard() } else { Dashboard() }   // 곧바로 벌어지는 두 개의 UI
```

이 스킬이 그것을 막습니다. 라이브러리가 아니라 **규칙서**입니다. 항상 로드되는 약 3,300
토큰과, 필요할 때만 불러오는 참조 문서(총 약 20,000 토큰)로 구성됩니다. 가르치는 것은 단 하나입니다.

> **레이아웃은 사용 가능한 공간에 반응한다. 물리적 상호작용만이 힌지에 반응할 수 있다.**

<br>

<div align="center">
<img src="../../assets/poses.svg" alt="iPhone Duo의 다섯 가지 자세 — 닫힘, 세로, 가로, 세워둠, 세움 — 과 각각이 요구하는 레이아웃" width="100%">
</div>

<br>

## 빠른 시작

```bash
git clone https://github.com/eisenjimmy/iphone-duo-skill.git

# 심볼릭 링크로 연결하면 'git pull'만으로 스킬이 최신 상태를 유지합니다 (권장)
mkdir -p ~/.claude/skills
ln -sfn "$PWD/iphone-duo-skill/skills/iphone-duo" ~/.claude/skills/iphone-duo
```

<details>
<summary><b>다른 에이전트 및 설치 경로</b></summary>

<br>

스킬은 일반 디렉터리입니다. Agent Skills를 지원하는 도구라면 어디든 연결할 수 있습니다.

| 도구 | 경로 |
|---|---|
| Claude Code (전역) | `~/.claude/skills/iphone-duo` |
| Claude Code (프로젝트 단위) | `<앱-저장소>/.claude/skills/iphone-duo` ← 보통 이쪽을 권장 |
| Codex | `~/.codex/skills/iphone-duo` |
| Cursor / 범용 | `~/.agents/skills/iphone-duo` |

위의 심볼릭 링크 방식을 권장합니다. 복사한다면 **병합이 아니라 교체**해야 합니다.
그러지 않으면 이름이 바뀐 파일이 남습니다.

```bash
rm -rf ~/.claude/skills/iphone-duo
cp -R iphone-duo-skill/skills/iphone-duo ~/.claude/skills/
```

**로드 확인:** Claude Code에서 `/skills`를 실행하거나, 그냥 물어보세요 —
*"iphone-duo 스킬 있어?"*

</details>

<br>

## 사용법

프롬프트 세 개면 대부분 해결됩니다.

```text
iphone-duo 스킬로 이 저장소를 점검해 줘. 아직 코드는 바꾸지 마.
파일별 근거, 각 이슈의 tier, 그리고 가장 작은 실행 계획을 줘.
```

```text
iphone-duo 스킬로 이 앱을 iPhone Duo에 맞게 적응시켜 줘. 크기가 바뀌는 동안
내비게이션과 뷰 상태를 유지하고, Duo 전용 API를 쓰기 전에 Tier 1을 먼저 끝내.
```

```text
이 화면을 부분적으로 펼친 iPhone Duo 기준으로 검토해 줘.
접힘 간섭, 조작 가능성, 그리고 여기서 힌지를 실제로 써야 하는 부분이 있는지.
```

### 좋은 실행 결과의 예

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

> **Xcode가 27.1 이전 버전이라면** 에이전트는 Duo 전용 작업을 `SDK-blocked`으로 표시하고
> 거기서 멈춥니다. 버그가 아니라 의도된 동작입니다. Tier 1만으로도 이미 지원 중인 모든
> 기기에서 앱이 좋아집니다.

<br>

<div align="center">
<img src="../../assets/workflow.svg" alt="에이전트의 동작 순서: 스캔, 분류, 계획, Tier 1 우선 구현, 모든 자세에서 검증" width="100%">
</div>

<br>

## 이 스킬이 실제로 아는 것

<div align="center">
<img src="../../assets/reserved-regions.svg" alt="세 가지 예약 영역: 외부 카메라 가림, 내부 카메라 가림, 그리고 접힘 분할 영역" width="100%">
</div>

<br>

접힘은 피해서 그리는 선이 아닙니다. 시스템이 캔버스에서 **예약 영역(reserved region)** 을
잘라냅니다 — 카메라 *가림(occlusion)* 두 개와 접힘 *분할(division)* 하나. 그리고 이 차이가
중요합니다. **가림은 덮고, 분할은 쪼갭니다.** 둘을 혼동하는 것이 Duo에서 가장 흔한 레이아웃
버그이며, 에이전트가 조용히 틀리기 쉬운 종류의 실수입니다.

놓치기 쉬운 Apple 지침도 함께 담고 있습니다.

- 내부 디스플레이는 **세로 방향에서 가로 바를 유지합니다** — 측면 컨트롤의 유일한 예외입니다.
- 세로 바는 **하드웨어에 정렬**되므로 **RTL 언어에서도 좌우가 바뀌지 않습니다**.
- Split View에서 각 앱은 자신의 **바깥쪽** 가장자리에 컨트롤을 둡니다.
- 그리드는 접힘을 기준으로 깔끔히 나뉘도록 **짝수** 열을 선호해야 합니다.
- 게임은 방향을 고정해도 되지만 **화면을 가득 채워야** 합니다. 레터박스보다 화면비 변경이
  우선입니다.
- `builtInDuoCamera`는 **후면 카메라를 가리키는 iOS 10의 폐기된 별칭**입니다. iPhone Duo와
  아무 관련이 없으며, "Duo"를 검색한 에이전트가 가장 먼저 발견하게 되는 함정입니다.

<br>

## 세 개의 tier, 순서대로

<div align="center">
<img src="../../assets/tiers.svg" alt="Tier 1 범용 적응 기반, Tier 2 Duo 인식 표현, Tier 3 Duo 전용 기능" width="100%">
</div>

<br>

"iPhone Duo 지원"의 대부분은 Tier 1이며, 이미 지원 중인 모든 기기를 함께 개선하는 작업입니다.
아래는 실제 변환 예시이고, **Duo API를 전혀 쓰지 않습니다.**

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
+            // 220 = 카드의 최소 가독 너비. 결과 열 개수가 짝수인지 직접 확인하세요 —
            // Apple은 Duo의 포인트 크기를 공개하지 않습니다.
+            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)]) {
+                ForEach(model.items) { ItemCell(item: $0) }
+            }
+        }
```

<br>

## 신뢰할 수 있는 이유

베타 SDK를 그대로 적어둔 스킬은 조용히 낡고, 결국 존재한 적 없는 심볼을 에이전트에게 자신
있게 건네줍니다. 이 스킬은 그런 일이 소리 없이 일어날 수 없도록 설계했습니다.

모든 Apple 심볼은 **[`data/api-manifest.json`](../../skills/iphone-duo/data/api-manifest.json)**
에 기록되며, 본문은 그 상태를 부풀려 말할 수 없습니다.

| 상태 | 의미 | 개수 |
|---|---|---|
| `verified` | Apple 문서 페이지가 지금 실제로 응답함 | **34** |
| `apple-sourced` | Apple 코드 샘플 그대로. 문서 페이지는 아직 없음 (iOS 27.1) | **23** |
| `conflicted` | Apple 자체 자료끼리 표기가 어긋남 | **2** |

```bash
bash skills/iphone-duo/scripts/verify-manifest.sh
```

문서화된 모든 심볼을 developer.apple.com에 다시 조회하고, 참조 문서가 매니페스트에 없는
심볼을 언급하면 실패하며, 45일이 지나면 **스스로 만료**됩니다. 오래된 조사 날짜가 조용한
거짓말이 아니라 빨간 CI로 드러나게 하기 위해서입니다. CI에서 매주 실행됩니다.

점검 스크립트도 자체 패턴을 갖지 않습니다.
[`data/patterns.json`](../../skills/iphone-duo/data/patterns.json)을 실행할 뿐이므로,
규칙을 추가할 곳은 정확히 한 군데입니다.

```bash
bash skills/iphone-duo/scripts/audit-duo.sh ~/code/MyApp
```

<br>

## 출처

모든 내용은 Apple 자료에서 나옵니다. 지어낸 것은 없습니다. `conflicted` 항목 두 개는 Apple
자체 자료가 서로 어긋나기 때문에 존재하며, 스킬은 임의로 한쪽을 고르지 않고 그 사실을
그대로 밝힙니다.

출시 Tech Talk 6편 —
[Design](https://developer.apple.com/videos/play/tech-talks/111466/) ·
[Prepare your app](https://developer.apple.com/videos/play/tech-talks/111461/) ·
[Raise the bar](https://developer.apple.com/videos/play/tech-talks/111462/) ·
[Strike a pose](https://developer.apple.com/videos/play/tech-talks/111463/) ·
[Displays and scenes](https://developer.apple.com/videos/play/tech-talks/111464/) ·
[Camera](https://developer.apple.com/videos/play/tech-talks/111465/) —
그리고 [휴먼 인터페이스 가이드라인](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo),
[개발자 허브](https://developer.apple.com/iphone-duo/).
전체 출처: [`references/08-sources.md`](../../skills/iphone-duo/references/08-sources.md).

<br>

## 구성

```text
skills/iphone-duo/
├── SKILL.md                   항상 로드 · 약 3,300 토큰
├── data/
│   ├── api-manifest.json      ← 심볼의 실재 여부를 판단하는 유일한 기준
│   └── patterns.json          ← 안티패턴 목록의 유일한 출처
├── scripts/
│   ├── audit-duo.sh           patterns.json을 코드베이스에 실행
│   └── verify-manifest.sh     모든 심볼 재검증 · 45일 후 만료
└── references/                필요할 때만 로드 · 총 약 20,000 토큰
```

<br>

## 이 스킬이 아닌 것

라이브러리가 아닙니다. 링크할 수 있는 Swift 코드를 제공하지 않습니다. 에이전트가 여러분의
코드를 *어떻게 판단하는지*를 바꿀 뿐이며, 결과물은 개선된 여러분의 코드베이스입니다.

<br>

## 기여

Apple의 iPhone Duo 문서는 아직 공개되는 중입니다. **여기서 가장 가치 있는 기여는 수정입니다.**
심볼 이름이 바뀌었거나 HIG가 갱신되었다면 이슈를 열어 주세요. 대개 CI가 이미 같은 결론에
도달해 있을 것입니다.

[기여 가이드](../../CONTRIBUTING.md) · [행동 강령](../../CODE_OF_CONDUCT.md) · [보안](../../SECURITY.md) · [변경 이력](../../CHANGELOG.md)

<br>

<div align="center">
<sub>

[MIT](../../LICENSE) · Apple Inc.와 제휴 관계 없음 · [상표 및 이미지 고지](../../NOTICE.md)

선행 작업: [FloWritesCode/fwc-swiftui-skills](https://github.com/FloWritesCode/fwc-swiftui-skills)

</sub>
</div>
