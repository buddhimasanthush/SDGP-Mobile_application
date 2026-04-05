
const { createClient } = require('@supabase/supabase-js');

const url = 'https://zdgugonfvsadghkijfnh.supabase.co';
const anonKey = 'sb_publishable_yFf517gDvREqKsR75e6Jxg_JLkl6Uu1';

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
