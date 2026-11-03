# 卡片版式规范（card-spec）

写卡片 HTML 时的权威参考。SKILL.md 里是流程概览，这里放详细规范和踩坑记录。

## 模板占位符速览（template.html 里要替换的【】）

`assets/template.html` 用 `【】` 标注要替换的位置，复制后按主题逐个替换：

- `<title>` / 注释里的主题名
- `.bd` 的卡数「【N】张」、每张卡 `ck-badge` 的分子分母、`.slot-hd` 的「第 N 张」
- 封面 `.ck-h1` 标题 / `.ck-sub` 副标题 / `.ck-checks li` 卖点 / `.mock` 示意卡
- 截图位 `data-slot="x2-【图名】.png"` 与留白块里的建议命名文字
- `ALIAS` 表：期望名 → 用户可能给的名字（原名 / 去空格 / %20 编码）
- 文案区 `#c-title` / `#c-body` / `#c-tags` 三段内容
- 每张卡的 `.ck-foot .ck-mark` 水印（品牌/主题）

改卡数时，先定好「模块叙事序 chip 01..N」再定「位置 badge NN/总数」，逐张核对三者一致。

## 卡片规格

- 单卡：`width:var(--cw); height:var(--ch)`，默认 `540×720`（3:4 竖版），`overflow:hidden`，`flex:none`。
- 无圆角、无阴影 —— 截图裁切不会带进页面底色；小红书本身会加圆角。
- 卡外上方用 `.slot-hd` 放一行灰色小标签「第 N 张 · 模块」，只用来定边界，**不属于卡片**；打印/切图时它被隐藏。

### 尺寸预设（小红书常用尺寸）

切换尺寸**只改 1 处**（`:root` 的 `--cw/--ch`），@page 尺寸、JS 缩放与提示自动跟随（脚本第 0 段动态同步 @page）。切图脚本 192dpi 恒定，输出 = CSS 尺寸 × 2。

| 预设 | 比例 | `--cw/--ch` | 输出 PNG |
|---|---|---|---|
| **3:4 竖版（默认·推荐）** | 3:4 | 540×720 | 1080×1440 |
| 1:1 方形 | 1:1 | 540×540 | 1080×1080 |
| 4:3 横版 | 4:3 | 720×540 | 1440×1080 |
| 9:16 全屏竖版 | 9:16 | 540×960 | 1080×1920 |

**内容密度随尺寸调整**：1:1 / 4:3 偏矮→精简内容防溢出；9:16 偏高→补足内容，避免大片空白。

## 编号体系（改卡数时三处一起改）

| 元素 | 含义 | 例子 |
|---|---|---|
| `.ck-badge` | 位置 `NN / 总数` | `05 / 11` |
| `.ck-chip` | 模块叙事序（封面无） | `04 · 记一笔 第 2 步` |
| `.slot-hd` | 「第 N 张」= 位置 | 第 5 张 |

**坑（历史上踩过）**：增删卡片时用全局替换把分母 `/ 09` → `/ 11` 只改了分母，**尾部两张卡的分子没跟着变**（仍是 08、09）。必须回头按 chip + badge 组合单独修。改完逐张核对：`ck-badge` 的分子 == `slot-hd` 的「第 N 张」== 实际顺序。

## CSS 类清单（模板已含，按需取用）

模板 `assets/template.html` 的 body 里已内置 **5 张示例卡**：封面 `.xcard.cover`、分栏 `.ck-split`、纯文字 `.ck-rows`、分类 chips `.catg`、三件套 `.ck-kit`。复制后照着 pattern 扩卡即可。下面列出全部组件类：

- 容器：`.stage`（卡列）、`.slot`（单卡+标签）、`.slot-hd`
- 卡片：`.xcard`、`.xcard.cover`（渐变底）
- 顶部：`.ck-top`（chip+badge 行）、`.ck-chip`、`.ck-badge`
- 主体：`.ck-body`（`flex:1; justify-content:center` 吃余量）、`.ck-h1`（大标题，`.hl` 高亮）、`.ck-sub`（副标题）
- 封面：`.ck-checks`（勾选标签列表）、`.mock`（CSS 画的示意小卡）
- 编号列：`.ck-rows` / `.ck-row`（`.warn` 变体橙色）、`.ck-kit`（三件套 grid）、`.ck-note`（强调条，`.amber` 黄色）
- 分类 chips：`.catg`（`.exp` 支出橙 / `.inc` 收入绿）+ `.grp span`
- 分栏：`.ck-split`（`grid 250px 1fr` 截图+要点）、`.shotbox`（截图容器）、`.ck-points`（要点列表）
- 底部：`.ck-foot`（`.go` 引导语 + `.ck-mark` 水印）、`.ck-gate`（门槛小字）
- 留白：`.shot-ph`（虚线留白块，内含 `.ico`/`.lb`/`.fn2`）
- 文案区：`.copywrap` / `.blk` / `pre.tx` + `data-copy` 复制按钮

## 留白与自动加载（核心机制）

- 截图位：`<div class="shot-ph" data-slot="x4-付款截图.png">…建议命名提示…</div>`，**不写 `<img>`**。
- JS 读 `data-slot`，按 `ALIAS[slot]` + slot 自身顺序在 `images/` 里探测；命中则 `replaceChild` 成 `<img>`（`.mp4/.mov/.webm/.m4v` 成 `<video>`），全不中保留留白块。
- `ALIAS` 每条同时挂 原名 / 去空格 / `%20` 编码，兼容用户文件名带空格或错字。
- 图片塞进 `images/` 即生效，不用改 HTML；改名 `.bak` 可临时隐藏某张。

## 打印样式（导出链路的关键）

```css
@page{size:540px 720px; margin:0}      /* 每页钉成卡片尺寸，切图无需裁剪 */
@media print{
  .bar,.copywrap,.slot-hd{display:none}
  body{background:#fff}
  .stage{gap:0; padding:0; zoom:1 !important}  /* ★ 压掉 JS 内联缩放 */
  .slot{display:block}
  .xcard{break-after:page; break-inside:avoid}
  .xcard:last-of-type{break-after:auto}          /* 别多出空白尾页 */
}
```

## 三条 JS（模板内置）

1. 自动加载配图（上文）
2. 复制按钮：`[data-copy="id"]` 点击复制对应 `#id` 文本，成功变绿「已复制」
3. 窄窗缩放：`stage.style.zoom = clamp(0.42, avail/540, 1)`，拉宽到 1:1 时提示「截图 ≈ 1080×1440」

## 历史踩坑（务必遵守）

1. **固定尺寸卡必须预估内容高度**。初版纯排版卡只占约 400px，离 720 差 300px+ 全空白。修法：`.ck-body{flex:1; justify-content:center}` 吃余量 + 字号放大一档 + 给内容不足的卡补真实内容。
2. **配图永不裁切**：iPhone 截图是 1:2.17 竖长条，塞 3:4 只能用 `object-fit:contain`；封面干脆不放截图，用 CSS 画「示意」小卡当视觉锚点。
3. **窄窗缩放用 `zoom` 不用 `transform:scale`**（zoom 影响布局高度，不留空隙）；且必须用 `!important` 在打印时压掉 JS 内联 zoom，否则 11 张卡会被整体缩小。
4. **导出 PDF 两必选项**：勾「背景图形」（否则渐变/色块全白）、去「页眉和页脚」（否则每页多一行网址日期）。
5. **本机无法无头截图**：headless Chrome 起不来（macOS 无图形会话，`CVDisplayLinkCreateWithCGDisplay failed`）。成品图只能走「用户打印 PDF + `scripts/export_cards.sh` 切图」。不要承诺一键截图。
6. **切图脚本安全写法**：用 `mkdir -p` + `rm -f "$OUT"/*.png`，别用 `rm -rf "$OUT"`；`setopt NULL_GLOB` 防空 glob 报错；`pdftoppm` 用 `command -v` 回退 `/opt/homebrew/bin/pdftoppm`。
7. **文案 md 与 HTML 文案区要保持一致**；改金额/口径这类细节时两个文件一起 grep 核对。
8. **隐私**：如果用户配图会露出真实数据（金额、日期、账号），出图前提示一次「是否糊掉/裁掉」，由用户决定，不擅自处理。
