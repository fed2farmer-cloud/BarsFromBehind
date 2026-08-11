const cities=["Los Angeles","Houston","Dallas–Fort Worth","Phoenix","Chicago","Miami","Atlanta","New York City","Memphis","New Orleans"];document.getElementById("cityList").innerHTML=cities.map((c,i)=>`<div><b>${String(i+1).padStart(2,"0")}</b>${c}<em>Facility verification required</em></div>`).join("");const form=document.getElementById("login"),dash=document.getElementById("dash"),err=document.getElementById("error");form.addEventListener("submit",e=>{e.preventDefault();if(email.value==="manager.demo@barsfrombehind.test"&&password.value==="BFB-DEMO-2026!"){form.hidden=true;dash.hidden=false;err.textContent=""}else err.textContent="Demo credentials not recognized."});document.getElementById("signout").onclick=()=>{dash.hidden=true;form.hidden=false};

// ===== Bars From Behind v1.1 account/database foundation =====
const BFB = (() => {
  const cfg = window.BFB_CONFIG || {};
  const configured = Boolean(cfg.SUPABASE_URL && cfg.SUPABASE_ANON_KEY && window.supabase);
  const client = configured ? window.supabase.createClient(cfg.SUPABASE_URL, cfg.SUPABASE_ANON_KEY) : null;

  async function signIn(email, password) {
    if (!client) throw new Error("Supabase is not configured.");
    return client.auth.signInWithPassword({ email, password });
  }

  async function signUp(email, password, role = "artist_rep") {
    if (!client) throw new Error("Supabase is not configured.");
    return client.auth.signUp({ email, password, options: { data: { requested_role: role } } });
  }

  async function signOut() {
    if (client) await client.auth.signOut();
  }

  return { client, configured, signIn, signUp, signOut };
})();
window.BFB = BFB;

document.querySelectorAll(".role-btn").forEach(btn => {
  btn.addEventListener("click", () => {
    const status = document.getElementById("auth-status");
    const role = btn.dataset.role;
    if (!BFB.configured) {
      status.textContent = `Selected ${role}. Add SUPABASE_URL and SUPABASE_ANON_KEY to config.js before enabling live authentication.`;
      return;
    }
    status.textContent = `${role} authentication is connected.`;
  });
});
