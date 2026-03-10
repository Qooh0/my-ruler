# my-ruler 仕様書（SPEC）

## 1. 概要

`my-ruler` は、Ruler（`@intellectronica/ruler`）の運用を前提に、プロジェクト間で `.ruler/` テンプレを配布し、Ruler の展開（`apply`/`revert`）をラップする CLI である。

- 配布元：方式A（npm パッケージにテンプレを同梱）
- テンプレ管理：ディレクトリ管理
- 対応OS：Windows / macOS / Linux

---

## 2. ゴール

- どのOSでも同一コマンドで `.ruler/` を配布できる
- AGENTS の衝突時に破壊的変更を行わず、報告のみで完了する
- Ruler の `apply`/`revert` を target フォルダ上で確実に実行できる（cwd を target に固定）
- CI など自動化に耐える（将来：dry-run/json/strict）

---

## 3. 非ゴール

- ルール本文（skills/agents）の内容品質を保証すること
- skills/agents の “内容マージ” を実装すること（事故リスクが高いため）
- Ruler の内部APIへ直接依存すること（CLI spawn を基本とする）

---

## 4. 用語

- **Template**：`my-ruler` が同梱する `.ruler/` 雛形
- **Target**：配布先プロジェクト（フォルダ）
- **SoT (Source of Truth)**：配布の正（canonical）となる `.ruler/` 資産
- **Derived artifacts**：`ruler apply` により生成される各AIツール向け設定ファイル群

---

## 5. ディレクトリ仕様

### 5.1 Template 側（my-ruler package）

```
templates/
  .ruler/
    ruler.toml
    skills/**        # 共有 skill
    agents/*.md      # AGENTS 群（複数対応）
```

### 5.2 Target 側（各リポジトリ）

```
<target>/
  .ruler/
    ruler.toml
    skills/**
    agents/*.md
```

---

## 6. コマンド仕様

### 6.1 `my-ruler sync <target>`

#### 目的
Template を Target にコピーし、`.ruler/` を配布する。

#### 入力
- `target`：配布先フォルダパス（相対・絶対いずれも可）

#### 出力（現状）
- stdout に Copied / Skipped / Errors のサマリを出力する

#### コピー規約（C）
- `.ruler/ruler.toml`：上書きコピー
- `.ruler/skills/**`：上書きコピー（削除はしない）
- `.ruler/agents/*.md`：**同名ファイルが Target に存在する場合はコピーしない**（報告のみ）

#### 期待する性質
- 冪等：同一テンプレで複数回実行しても壊れない
- 破壊防止：AGENTS は既存を上書きしない

---

### 6.2 `my-ruler apply <target> -- <ruler args...>`

#### 目的
Target 上で `ruler apply` を実行し、派生ファイルを生成する。

#### 実装要件
- 実行時の `cwd` を Target に固定する
- `--` 以降の引数をそのまま Ruler に透過する
- Ruler 実行ファイルは `node_modules/.bin/` から解決する
  - Windows: `ruler.cmd`
  - Unix: `ruler`

---

### 6.3 `my-ruler revert <target> -- <ruler args...>`

`apply` と同様に、Target 上で `ruler revert` を実行する。

---

## 7. エラー処理

- `sync`：例外を捕捉し errors に積み、サマリを出力する
  - 将来 `--strict` で exit code 1 を返せるようにする
- `apply`/`revert`：Ruler の exit code をそのまま返す

---

## 8. セキュリティ/安全性

- symlink を使用しない（OS差・権限差で壊れやすいため）
- 自動で git 操作はしない（commit/push 等はしない）
- `postinstall` での任意コード実行はしない

---

## 9. 互換性方針

- my-ruler は Ruler の CLI を spawn するため、Ruler の CLI 互換性に追随する
- 重大な破壊的変更が出た場合は my-ruler 側でバージョン固定または互換対応を検討する

---

## 10. 受入基準（5まで）

1) `sync --dry-run/json/strict` が追加され、挙動が文書化されている  
2) AGENTS の命名規約（優先度/タグ）が文書化されている  
3) skills の共存・衝突・更新の方針が文書化されている  
4) CI で `my-ruler apply` を実行する手順が文書化されている  
5) kit 分離方針（`--from`）の設計が文書化され、実装着手できる粒度になっている  
