#!/bin/bash
# CLAUDE.md のバッククォート内のパスが実在するかを確かめる。パスは動かした瞬間に腐り、腐った指示はエージェントを嘘の場所へ送る。
# 散文の言い換えまでは追わない(誤検知で門が鳴りっぱなしになると誰も見なくなる)。
cd "$(dirname "$0")/.." || exit 1

# 実在しなくてよい参照。理由の無い項目を足さないこと
EXEMPT='
ayakasi/Data/data.json|2026-10-10に削除したことを書いている
scripts/sync-yokai-data.sh|2026-10-10に削除したことを書いている
phihash/JSON/event3.json|GitHubリポジトリ上のパス
src/firebaseAuth.js|~/Desktop/yokai-images からの相対
wrangler.jsonc|~/Desktop/yokai-images のファイル
'

missing=0
while IFS= read -r ref; do
  # "GET /news" のようなAPI、<documentId> のような雛形、ファイル名を持たない区切り記号は対象外
  case "$ref" in *" "*|*"<"*|/*|*://*) continue ;; esac
  grep -q "^${ref}|" <<<"$EXEMPT" && continue
  if [[ "$ref" == */* ]]; then
    [ -e "${ref/#\~/$HOME}" ] && continue
  elif [[ "$ref" =~ \.(yml|yaml|md|swift|sh|json|jsonc|plist|xcconfig|sql|js|mjs)$ ]]; then
    # ファイル名だけの参照(`Constants.swift` など)は、リポジトリのどこかにあればよい。
    # 拡張子で絞るのは、`.task` や `@AppStorage` のようなコードの名前をパスとして拾わないため
    [ -n "$(find . -name "$ref" -not -path './.git/*' -print -quit)" ] && continue
  else
    continue
  fi
  echo "✖ CLAUDE.md の参照先がありません: $ref" >&2
  missing=1
done < <(grep -oE '`[^`]+`' CLAUDE.md | tr -d '`' | sort -u)

[ "$missing" -eq 0 ] && echo "✓ CLAUDE.md の参照はすべて実在します"
exit "$missing"
