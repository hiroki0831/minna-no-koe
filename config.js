// Supabase Project Settings > API で確認。公開可能な publishable / anon キーのみ設定。
// service_role キーや OpenAI API キーは絶対に書かないでください。
window.APP_CONFIG = {
  supabaseUrl: 'https://YOUR_PROJECT.supabase.co',
  supabaseAnonKey: 'YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY',
  enableAiSummary: false
};
