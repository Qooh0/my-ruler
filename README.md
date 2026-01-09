# my-ruler

`my-ruler` は、Ruler（`@intellectronica/ruler`）の運用を前提に、プロジェクト間で `.ruler/` テンプレ（skills / agents / ruler.toml）を配布し、Ruler の展開コマンド（`apply` / `revert`）をラップする CLI です。

- 方式A：テンプレは `my-ruler` npm パッケージに同梱
- テンプレ管理：ディレクトリ管理（`.ruler/skills`, `.ruler/agents`）
- 対応OS：Windows / macOS / Linux

## 目標

- `.ruler/` の初期セットアップ（SoT）を複数リポジトリに素早くコピーできる
- AGENTS の衝突（同名ファイル）があっても破壊せず、報告のみで終わる
- 最後に Ruler で展開（各AIツール用の派生ファイル生成）まで通せる

---

## インストール / 実行方法

### ローカル開発（このリポジトリ内で）

```bash
npm install
npm run build
```

実行例：

```bash
# ある target にテンプレを配布
node dist/cli.js sync ../some-repo

# target 上で ruler apply を実行（-- 以降をそのまま透過）
node dist/cli.js apply ../some-repo -- --agents claude,copilot
```

### npx 実行（publish 後を想定）

```bash
npx my-ruler sync .
npx my-ruler apply . -- --nested
```

---

## テンプレ構造（方式A）

`my-ruler` はパッケージ内にテンプレを同梱しています。

```
templates/
  .ruler/
    ruler.toml
    skills/
      ...
    agents/
      AGENTS.md
      AGENTS.backend.md
```

配布先では次のように配置されます。

```
<target>/
  .ruler/
    ruler.toml
    skills/
      ...
    agents/
      ...
```

---

## `my-ruler sync <target>` の動作

`sync` は **`.ruler/` の Source of Truth（SoT）を配布する**コマンドです。

### 何がコピーされるか（仕様 C）

- `.ruler/ruler.toml`  
  - 上書きコピー
- `.ruler/skills/**`  
  - 上書きコピー（削除はしません）
- `.ruler/agents/*.md`  
  - **同名ファイルが target に存在する場合はコピーしません**
  - その場合は **Skipped として報告**します

### 出力例

- Copied: `["ruler.toml", "skills/**", "agents/AGENTS.security.md"]`
- Skipped (exists): `["agents/AGENTS.md"]`
- Errors: `[]`

### 重要な性質

- 冪等：同じテンプレで何回 `sync` しても破壊的変更になりにくい
- 衝突回避：AGENTS は既存の同名ファイルを尊重する（上書きしない）

---

## AGENTS の運用（複数対応）

### 目的
複数の AGENTS を用意して、領域や目的ごとに指示を分割し、読みやすさと保守性を上げます。

### 配置
- `.ruler/agents/*.md`

### 命名規約（推奨）
my-ruler 自体はファイル内容を解釈しません。運用規約として、以下のような命名で整理するのが扱いやすいです。

- `AGENTS.md`：全体共通（入口）
- `AGENTS.backend.md`：領域別（backend）
- `AGENTS.frontend.md`：領域別（frontend）
- `AGENTS.security.p0.md`：優先度を表現（p0/p1/p2 など）

`sync` では「ファイル名が同じならコピーしない」ため、同名衝突を避ける設計にしてください。

---

## skills の運用

### 配置
- `.ruler/skills/**`

### 更新の基本方針（初期）
- `sync` は **上書きコピー**を行います
- 共有元から削除された skill を target 側から **削除しません**

価値検証段階で「削除同期」や「内容マージ」を入れると事故リスクが上がるため、最初はコピーのみを推奨します。

---

## Ruler の設定・展開（詳細）

my-ruler は `.ruler/` を配布した後、Ruler で各AIツール向けに展開する流れを想定しています。

### 1) `.ruler/` を配布

```bash
npx my-ruler sync <target>
```

### 2) Ruler で展開（apply）

**推奨**：my-ruler のラッパ経由で実行します（cwd を target に固定できるため）。

```bash
npx my-ruler apply <target> -- --agents claude,copilot
```

- `--` 以降は Ruler にそのまま渡されます
- 例：nested rules を有効化する場合

```bash
npx my-ruler apply <target> -- --nested
```

### 3) 取り消し（revert）

```bash
npx my-ruler revert <target> -- --agents claude
```

### 注意（ruler の実行ファイル解決）
my-ruler は `node_modules/.bin/` 配下の `ruler` を実行します。

- Windows：`node_modules/.bin/ruler.cmd`
- macOS/Linux：`node_modules/.bin/ruler`

そのため、`my-ruler` の依存として `@intellectronica/ruler` がインストールされます（ユーザーが別途インストールする必要はありません）。

---

## CI（最小例）

CI では次のように “展開が壊れていない” を確認できます（生成物をコミットするかは運用で決めてください）。

```bash
npx my-ruler sync .
npx my-ruler apply . -- --dry-run
```

---

## ドキュメント

- `docs/PLAN.md`：拡張計画（1〜5）
- `docs/SPEC.md`：仕様書（受入基準に 1〜5 を含む）
- `docs/USAGE.md`：使用方法（最短）

---

## ライセンス
TBD
