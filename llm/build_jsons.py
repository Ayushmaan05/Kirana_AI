import json, pathlib
BASE = pathlib.Path(__file__).resolve().parent
schema = json.loads((BASE / "kirana_schema.json").read_text(encoding="utf-8"))
print("loaded tables:", len(schema.get("tables", [])))