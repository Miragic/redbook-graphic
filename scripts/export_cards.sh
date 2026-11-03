#!/bin/zsh
# ---------------------------------------------------------------------------
# 把「另存为 PDF」好的小红书卡片页，切成一张张高清 PNG
#
#   用法：  ./export_cards.sh <pdf 路径> [输出目录] [期望尺寸]
#   例子：  ./export_cards.sh 小红书图文-我的主题.pdf 小红书卡片 1080x1440
#
#   原理：卡片 CSS 尺寸由模板 :root 的 --cw/--ch 决定（默认 3:4 = 540×720），
#         @page 把每页钉成同样尺寸，192dpi（96 的 2 倍）光栅化 → 输出 = CSS × 2。
#         常用预设：3:4 竖版 1080×1440 / 1:1 方形 1080×1080 /
#                   4:3 横版 1440×1080 / 9:16 全屏 1080×1920
#
#   依赖：poppler（提供 pdftoppm 和可选的 pdfinfo）——  brew install poppler
# ---------------------------------------------------------------------------
set -e
setopt NULL_GLOB 2>/dev/null || true

PDF="${1:-}"
OUT="${2:-小红书卡片}"
EXPECT="${3:-1080x1440}"

if [ -z "$PDF" ]; then
  echo "用法： ./export_cards.sh <pdf 路径> [输出目录]"
  exit 1
fi
if [ ! -f "$PDF" ]; then
  echo "找不到文件：$PDF"
  exit 1
fi

PDFTOPPM="$(command -v pdftoppm || true)"
[ -n "$PDFTOPPM" ] || PDFTOPPM="/opt/homebrew/bin/pdftoppm"
if [ ! -x "$PDFTOPPM" ]; then
  echo "找不到 pdftoppm —— 先装 poppler：brew install poppler"
  exit 1
fi

# 若有 pdfinfo，打印页数与页面尺寸，方便核对
PDFINFO="$(command -v pdfinfo || true)"
[ -n "$PDFINFO" ] || PDFINFO="/opt/homebrew/bin/pdfinfo"
if [ -x "$PDFINFO" ]; then
  "$PDFINFO" "$PDF" | grep -E 'Pages|Page size'
  echo
fi

mkdir -p "$OUT"
rm -f "$OUT"/*.png

"$PDFTOPPM" -png -r 192 "$PDF" "$OUT/卡片"

# 统一改名成 01.png / 02.png …
i=0
for f in "$OUT"/卡片-*.png; do
  [ -e "$f" ] || continue
  i=$((i + 1))
  mv "$f" "$OUT/$(printf '%02d' $i).png"
done

echo "导出完成：$OUT/    共 $i 张"
echo
for f in "$OUT"/*.png; do
  wh="$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"×"h}')"
  printf "  %-10s %s\n" "$(basename "$f")" "$wh"
done
echo
echo "核对：张数应等于 PDF 页数；每张尺寸应为 $EXPECT。"
echo "尺寸不对的话：重打 PDF，确认「边距=默认」、「页眉和页脚」的勾去掉、页面没有被拆页。"
