---
name: migration-kysely
description: D1 + Kysely 環境でマイグレーションファイルを追加・管理するときに自動適用する
---

D1 (SQLite) + Kysely 環境でのマイグレーション規約:

1. **up/down ペア**: `0001_create_todos.up.ts` / `0001_create_todos.down.ts`
2. **スキーマバージョン管理**: Kysely の `Migrator` + `FileMigrationProvider` を使い適用済みを追跡
3. **日付ベース命名**: `20250301_add_tags.ts` でファイル順序の衝突を防ぐ
4. **D1 制約の考慮**: ALTER TABLE の制限（列削除不可など）を意識する
5. **自動適用**: アプリ起動時に未適用マイグレーションを自動で実行する仕組みを構築
