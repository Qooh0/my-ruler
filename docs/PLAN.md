# my-ruler 拡張計画（PLAN）

対象：`my-ruler`（Ruler 設定配布 + 展開ラッパ CLI）

目的：価値検証前提で「事故らずに広げる」ことを最優先に、段階的に機能を追加する。  
前提：配布元は方式A（npm パッケージにテンプレ同梱）、テンプレはディレクトリ管理。

---

## スコープ

この PLAN は、以下 1〜5 の拡張を対象とする（優先度順）。

1. `sync --dry-run / --json / --strict`
2. AGENTS の優先順位・タグ付け
3. skills の差分マージ戦略
4. CI 用の `my-ruler apply --dry-run`
5. ruler-kit 分離（横断共有）

---

## 1. `sync` の安全性・自動化オプション追加

### 目的
- 実際に書き換える前に差分が見える（dry-run）
- CI/自動化で機械可読に扱える（json）
- 失敗時の停止ポリシーを選べる（strict）

### 作業
- `my-ruler sync <target>` に以下オプションを追加
  - `--dry-run`: コピーを行わず、コピー予定/スキップ予定/エラーを表示
  - `--json`: 結果を JSON で出力（stdout）
  - `--strict`: errors が 1 件でもあれば exit code 1
- ログの整形（Copied/Skipped/Errors の整合）

### 成果物
- `src/commands/sync.ts` の拡張
- `docs/USAGE.md` の追記
- `README.md` の更新

---

## 2. AGENTS の優先順位・タグ付け

### 目的
- 複数 AGENTS を「どれをいつ使うか」明確化する
- 衝突回避（同名はコピーしない）を維持しつつ、運用の意図を表現する

### 方針（提案）
- `.ruler/agents/` 配下はファイル名規約で分類する
  - 例：`AGENTS.md`（全体）、`AGENTS.backend.md`（領域）、`AGENTS.security.p0.md`（優先度）
- my-ruler の役割は「配布」なので、タグの解釈は **README に規約として明記**し、必要なら将来 `list` コマンドで可視化する

### 作業
- README に命名規約（priority/tag）を明記
- 追加で `my-ruler agents list <target>` を導入するかは任意（価値検証後）

### 成果物
- `docs/AGENTS_CONVENTION.md`（将来）
- `templates/.ruler/agents/*` のサンプル拡張（任意）
- `README.md` 更新

---

## 3. skills の差分マージ戦略

### 目的
- 共有 skill とプロジェクト固有 skill の共存
- 共有元の更新を取り込みつつ、プロジェクト側のカスタムを壊さない

### 方針（初期）
- 既定は「上書きコピー（削除なし）」のまま
- 次段で「名前空間」と「衝突時の扱い」を明文化する
  - 例：共有は `.ruler/skills/_shared/**`、プロジェクト固有は `.ruler/skills/_local/**`
- my-ruler の責務は「ファイル配置」であり、内容マージはしない（複雑性と事故リスクが高い）

### 作業
- README に `skills` のディレクトリ規約を追記
- `sync` に `--no-overwrite-skills`（任意）または `--shared-prefix`（任意）を追加検討

### 成果物
- `docs/SKILLS_CONVENTION.md`（将来）
- `README.md` 更新

---

## 4. CI 用の `my-ruler apply --dry-run`

### 目的
- PR で「展開が失敗しない」ことを機械的に検証
- 生成ファイル差分の確認（ただし生成物のコミット要否は運用で決める）

### 方針
- my-ruler は Ruler の引数透過を維持し、CI 側で `--dry-run` を指定する
- my-ruler 自身に CI 固有ロジックを入れない（あくまでラッパ）

### 作業
- README に GitHub Actions 例（最小）を追記
- `my-ruler apply <target> -- --dry-run` の説明を明確化

### 成果物
- `docs/CI_EXAMPLE.md`（将来）
- `README.md` 更新

---

## 5. ruler-kit 分離（横断共有）

### 目的
- `my-ruler` を「配布エンジン」として固定し、テンプレ（`.ruler`）を独立パッケージにして差し替え可能にする
- 複数チーム/複数セット（例：backend向け/enterprise向け）を切り替えられる

### 方針（ベスト）
- `my-ruler` に `--from <npm:pkg|path>` を追加し、テンプレを外部指定できるようにする
- 既定は方式A（同梱テンプレ）
- kit は npm パッケージとして配布（例：`@org/my-ruler-kit-default`）

### 作業
- テンプレ解決ロジックの抽象化（`src/lib/template.ts`）
- `--from` の実装
- kit のサンプルパッケージ構造（別リポジトリ）を docs に記載

### 成果物
- `docs/KIT_SPLIT.md`（将来）
- `src/lib/template.ts` 拡張
- （将来）別リポジトリ `my-ruler-kit-*`

---

## 進め方（推奨順）

- Phase 1: (1) を最優先（安全性と自動化）
- Phase 2: (2)(3) をドキュメント中心で固める（運用規約）
- Phase 3: (4) を CI サンプルとして提供
- Phase 4: (5) を実装する（横断共有が必要になったタイミングで）
