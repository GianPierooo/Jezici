# -*- coding: utf-8 -*-
"""Despliega la Edge Function matix-push + secrets VAPID vía Management API.
Las claves VAPID se leen de un archivo local temporal (vapid.txt del scratchpad,
NUNCA del repo). La pública no es secreta (va también en el cliente)."""
import json, os, sys, urllib.request, urllib.error
from apply_sql import env

REF = env("SUPABASE_PROJECT_REF")
TOKEN = env("SUPABASE_ACCESS_TOKEN")
BASE = f"https://api.supabase.com/v1/projects/{REF}"


def call(method, path, body=None, ctype="application/json"):
    data = None
    if body is not None:
        data = body if isinstance(body, bytes) else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, method=method)
    req.add_header("Authorization", f"Bearer {TOKEN}")
    req.add_header("Content-Type", ctype)
    req.add_header("User-Agent", "curl/8")
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()


def main(vapid_file):
    pub = priv = None
    with open(vapid_file, encoding="utf-8") as f:
        for line in f:
            if line.startswith("PUB="):
                pub = line.strip()[4:]
            if line.startswith("PRIV="):
                priv = line.strip()[5:]
    assert pub and priv, "vapid.txt sin claves"

    # 1) Secrets de la función (la privada JAMÁS al repo).
    code, out = call("POST", "/secrets", [
        {"name": "VAPID_PUBLIC_KEY", "value": pub},
        {"name": "VAPID_PRIVATE_KEY", "value": priv},
        {"name": "VAPID_SUBJECT", "value": "mailto:gianpierodaniel@gmail.com"},
    ])
    print("secrets:", code, out[:200])

    # 2) La función (crea o actualiza).
    src = open(os.path.join(os.path.dirname(__file__), "..", "..", "supabase",
                            "functions", "matix-push", "index.ts"), encoding="utf-8").read()
    code, out = call("POST", "/functions?slug=matix-push&name=matix-push&verify_jwt=true",
                     src.encode(), ctype="application/typescript")
    print("create:", code, out[:300])
    if code == 409 or (code >= 400 and "already exists" in out):
        code, out = call("PATCH", "/functions/matix-push?verify_jwt=true",
                         src.encode(), ctype="application/typescript")
        print("update:", code, out[:300])
    # 3) Estado final.
    code, out = call("GET", "/functions")
    print("list:", code, out[:400])


if __name__ == "__main__":
    main(sys.argv[1])
