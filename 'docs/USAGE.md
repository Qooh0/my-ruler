# USAGE

## Quickstart

### 1. 配布

```bash
npx my-ruler sync <target>
```

### 2. 展開

```bash
npx my-ruler apply <target> -- --agents claude,copilot
```

### 3. 取り消し

```bash
npx my-ruler revert <target> -- --agents claude
```

## Notes

- `sync` は `.ruler/agents/*.md` の同名ファイルを上書きしません（Skippedとして報告します）。
- `apply/revert` は `--` 以降の引数をそのまま Ruler に透過します。
