import json
import sys
from passlib.hash import sha512_crypt
from jinja2 import Template, StrictUndefined, UndefinedError

template_path = sys.argv[1]
json_path = sys.argv[2]
output_path = sys.argv[3]

# Load template
with open(template_path, 'r', encoding='utf-8') as f:
    template = Template(f.read(), undefined=StrictUndefined)

# Load config
with open(json_path, 'r', encoding='utf-8') as f:
    config_data = json.load(f)

# Validate required keys
required_keys = ["hostname", "username", "password"]
missing = [k for k in required_keys if k not in config_data or not config_data[k]]

if missing:
    print(f"❌ Missing required config keys: {', '.join(missing)}")
    sys.exit(1)

# Hash password using passlib (SHA-512)
config_data["user_password_hash"] = sha512_crypt.hash(config_data["password"])

# Render template
try:
    rendered = template.render(config_data)
except UndefinedError as e:
    print(f"❌ Template rendering error: {e}")
    sys.exit(1)

# Write result
with open(output_path, 'w', encoding='utf-8') as f:
    f.write(rendered)

print(f"✅ Cloud-init rendered to: {output_path}")
