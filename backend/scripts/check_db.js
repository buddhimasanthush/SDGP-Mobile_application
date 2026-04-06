
const { createClient } = require('@supabase/supabase-js');

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  throw new Error('SUPABASE_URL and SUPABASE_ANON_KEY environment variables are required.');
}

const supabase = createClient(url, anonKey);

async function checkData() {
  console.log('--- USER LOGINS ---');
  const { data: logins, error: lErr } = await supabase.from('user_logins').select('*');
  if (lErr) console.error(lErr);
  else console.table(logins);

  console.log('--- PROFILES ---');
  const { data: profiles, error: pErr } = await supabase.from('profiles').select('*');
  if (pErr) console.error(pErr);
  else console.table(profiles);
}

checkData();
