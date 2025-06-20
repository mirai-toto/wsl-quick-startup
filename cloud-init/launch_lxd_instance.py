import sys
import subprocess
import yaml
import crypt
from jinja2 import Template

# Load variables from a YAML config file
with open("cloud-init-vars.yaml", "r") as f:
    variables = yaml.safe_load(f)

# Hash the plaintext password
if "user_password" in variables:
    hashed = crypt.crypt(variables["user_password"], crypt.mksalt(crypt.METHOD_SHA512))
    variables["user_password_hash"] = hashed
else:
    print("Missing 'user_password' in config file.")
    sys.exit(1)

# Load user-data template
with open("user-data", "r") as f:
    template = Template(f.read())
    rendered_user_data = template.render(**variables)

# Get instance name
instance_name = variables["hostname"]

# Delete existing instance if it exists
try:
    subprocess.run(["lxc", "delete", instance_name, "--force"], check=False)
except Exception as e:
    print(f"Warning: failed to delete existing instance '{instance_name}':", e)

# Launch LXD instance with rendered user-data
cmd = [
    "lxc", "launch", "ubuntu:22.04", instance_name,
    f"--config=user.user-data={rendered_user_data}"
]

# Run command
try:
    subprocess.run(cmd, check=True)
except subprocess.CalledProcessError as e:
    print("Error launching instance:", e)
    sys.exit(1)

print(f"LXD instance '{instance_name}' launched successfully.")