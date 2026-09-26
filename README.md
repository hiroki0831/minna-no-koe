# みんなの声 — GitHub Pages + Supabase 試作版

社内サーバーは不要。スマホで音声入力して、要約を確認し、会社／倫理法人会それぞれの非公開掲示板へ投稿します。ブラウザ対応状況によっては音声入力の代わりに直接入力可能です。

## 1. Supabase を作る
1. https://supabase.com/ でプロジェクト作成。
2. SQL Editorで `schema.sql` を全文実行。会社と倫理法人会の2グループが作成されます。
3. Project Settings / API から Project URL と **publishable / anon** key をコピーし、`config.js` を設定。**service_role キーを入れないでください。**
4. Authentication > URL Configuration の Site URL と Redirect URLs にGitHub PagesのURLを指定。公開前に認証設定・メール送信設定を確認。

## 2. GitHub Pages へ配置
1. GitHubに `minna-no-koe` リポジトリを作成し、`index.html`、`config.js`、`manifest.webmanifest`、`.nojekyll` をリポジトリ直下へアップロード。`schema.sql` は公開リポジトリに置いても秘密情報は含みませんが、置かなくてもOK。
2. Settings > Pages > Deploy from a branch > main / (root) > Save。
3. `https://<GitHubユーザー名>.github.io/minna-no-koe/` へアクセス。

## 3. メンバーの所属を承認
アプリ上で各メンバーが「新規登録」してメール認証を済ませた後、Supabase Authentication > Users でUUIDを確認します。
SQL Editorで以下を実行してください（実際のUUIDに置換）。一人を両方のグループに所属させる場合は2行実行します。

```sql
insert into public.memberships(org_id,user_id,role)
select id,'ここに利用者のUUID'::uuid,'member' from public.organizations where name='会社';

insert into public.memberships(org_id,user_id,role)
select id,'ここに利用者のUUID'::uuid,'admin' from public.organizations where name='倫理法人会';
```

所属はDB管理者だけが付与できます。アプリに新規登録しただけではどの掲示板も見られません。投稿者は所属グループ以外の意見を閲覧・投稿できません。現時点では投稿後の状態変更とコメントは未実装です。

## 4. AI要約（任意、有料API）
初期状態では「要約案を作る」は先頭3文から簡易要約を作成する機能です。AI要約を有効にするにはSupabase CLIで `supabase/functions/summarize` をデプロイし、`OPENAI_API_KEY` を Supabase Function Secrets に設定してから `config.js` の `enableAiSummary` を `true` に変えてください。JWT認証は必ず有効のままにしてください。API費用は使った分だけ別途発生します。APIキーをGitHubやconfig.jsに書かないでください。

## 注意
- **会社の機密情報や個人情報は、運用・契約・音声認識サービスのデータ処理条件を確認してから入力してください。** ブラウザ音声認識は環境により外部サービスへ音声を送ります。
- GitHub Pages上のフロントエンドは誰でも取得できます。非公開なのはSupabase RLSで保護した投稿データです。公開リポジトリには秘密鍵を置かないでください。
- 最初は少人数でテストし、モデレーション、誤投稿削除、監査、バックアップ、音声入力の対応機種確認を行ってから本運用してください。
