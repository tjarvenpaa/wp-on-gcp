gcloud iam service-accounts create ansible-sa --display-name=ansible-sa
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
gcloud iam service-accounts keys create ~/ansible-sa.json \
Ansible playbook to obtain Let's Encrypt certificate and configure Nginx for the WordPress VM.

Quick start
1. Static inventory (simple)

 - Edit `ansible/inventory.ini` and set `ansible_user` and `ansible_ssh_private_key_file` for the target VM (example IP: 35.228.94.221).

```ini
[wordpress]
35.228.94.221 ansible_user=UserName ansible_ssh_private_key_file=~/.ssh/google_compute_engine
```

Then run:

```bash
ansible-playbook -i ansible/inventory.ini ansible/site.yml
```

2. Dynamic GCP inventory (recommended for automation)

Use Ansible's `google.cloud.gcp_compute` inventory plugin so Ansible discovers instances directly from GCP. Note: plugin requires the `google.cloud` collection (already present) and Google Python libraries (`google-api-python-client`, `google-auth`, etc.).

Steps:

- Create a service account and JSON key (do not commit this key):

```bash
gcloud iam service-accounts create ansible-sa --display-name=ansible-sa
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:ansible-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.viewer"
gcloud iam service-accounts keys create ~/ansible-sa.json \
  --iam-account=ansible-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
chmod 600 ~/ansible-sa.json
```

- Use the inventory file `ansible/gcp_compute.yml` (this filename is important — plugin verifies filename):

```yaml
plugin: google.cloud.gcp_compute
projects:
  - YOUR_PROJECT_ID
auth_kind: serviceaccount
service_account_file: /home/you/ansible-sa.json
compose:
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
```

- Test the inventory and ping hosts:

```bash
ansible-inventory -i ansible/gcp_compute.yml --list
ansible -i ansible/gcp_compute.yml -m ping wordpress -u UserName --private-key=~/.ssh/google_compute_engine
```

Notes on Cloudflare and cert issuance
- If your domain is proxied through Cloudflare (orange cloud), the HTTP-01 challenge will fail. Either temporarily set DNS record to "DNS only" (gray cloud) while obtaining certs or use DNS-01 challenge with `python3-certbot-dns-cloudflare` and Cloudflare API token.

Troubleshooting
- If `ansible-inventory` fails to parse the GCP inventory, check:
  - The service account JSON exists and is readable (`ls -l /home/you/ansible-sa.json`).
  - Python Google libraries are installed (`pip install --user google-api-python-client google-auth google-auth-httplib2 google-auth-oauthlib`).
  - The inventory filename: must end with `gcp_compute.yml` or `gcp.yml` per plugin docs.

Security
- Do not commit service account keys to git. Use `chmod 600` on the JSON key and store it securely.

Using Cloudflare API token securely (Ansible Vault)
-----------------------------------------------
- Recommended: store the Cloudflare API token in an encrypted `group_vars/wordpress.yml` using Ansible Vault.

1) Create the vault file interactively (this will open your editor):

```bash
ansible-vault create group_vars/wordpress.yml
```

Inside the file (example content):

```yaml
cloudflare_api_token: "YOUR_REAL_TOKEN_HERE"
```

2) Run the playbook and provide the vault password interactively:

```bash
ansible-playbook -i ansible/gcp_compute.yml ansible/site.yml \
  --ask-vault-pass -u UserName --private-key=~/.ssh/google_compute_engine
```

3) Optionally, use a vault password file (keep it secure and out of repo):

```bash
ansible-playbook -i ansible/gcp_compute.yml ansible/site.yml \
  --vault-password-file ~/.vault_pass.txt -u UserName --private-key=~/.ssh/google_compute_engine
```




