"""Aplica SQL al proyecto Supabase vía Management API y registra la migración.
Los secretos NUNCA van al repo: se leen del entorno o de ../../.env (gitignored)."""
import json, os, sys, urllib.request, urllib.error

def _load_env():
    """Carga vars del .env del repo si no están ya en el entorno."""
    here = os.path.dirname(os.path.abspath(__file__))
    env_path = os.path.normpath(os.path.join(here, "..", "..", ".env"))
    vals = {}
    try:
        with open(env_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                vals[k.strip()] = v.strip()
    except FileNotFoundError:
        pass
    return vals

_ENV = _load_env()
def env(key):
    return os.environ.get(key) or _ENV.get(key) or ""

REF = env("SUPABASE_PROJECT_REF")
TOKEN = env("SUPABASE_ACCESS_TOKEN")
SERVICE = env("SUPABASE_SERVICE_ROLE_KEY")
SUPABASE_URL = env("SUPABASE_URL")
URL = f"https://api.supabase.com/v1/projects/{REF}/database/query"

if not (REF and TOKEN):
    sys.exit("Faltan SUPABASE_PROJECT_REF / SUPABASE_ACCESS_TOKEN (define en .env o entorno).")

def run(sql):
    body = json.dumps({"query": sql}).encode("utf-8")
    req = urllib.request.Request(URL, data=body, method="POST")
    req.add_header("Authorization", f"Bearer {TOKEN}")
    req.add_header("Content-Type", "application/json")
    req.add_header("User-Agent", "curl/8")  # evita Cloudflare 1010
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return r.status, r.read().decode("utf-8")
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode("utf-8")

def apply_file(path):
    version = os.path.basename(path).split("_")[0]
    name = os.path.basename(path)[len(version)+1:].replace(".sql", "")
    sql = open(path, encoding="utf-8").read()
    code, out = run(sql)
    print(f"[{code}] {os.path.basename(path)} -> {out[:300]}")
    if code not in (200, 201):
        sys.exit(f"FALLO en {path}")
    rec = ("insert into supabase_migrations.schema_migrations(version, name) "
           f"values ('{version}', '{name}') on conflict (version) do nothing;")
    c2, o2 = run(rec)
    print(f"  schema_migrations[{version}] -> [{c2}] {o2[:120]}")

if __name__ == "__main__":
    for p in sys.argv[1:]:
        apply_file(p)
    print("LISTO")
