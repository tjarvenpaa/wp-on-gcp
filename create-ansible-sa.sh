# Aseta muuttujat
PROJECT="wp-on-gcp-475810"
SA_NAME="ansible-sa"
SA_DISPLAY_NAME="ansible service account for ansible inventory"
KEY_PATH="$HOME/ansible-sa.json"

# Luo service account
gcloud iam service-accounts create "$SA_NAME" \
  --project="$PROJECT" \
  --display-name="$SA_DISPLAY_NAME"

# Muodosta service account sähköpostimuodossa
SA_EMAIL="${SA_NAME}@${PROJECT}.iam.gserviceaccount.com"

# Anna service accountille vain tarvittava rooli (compute.viewer riittää inventaarioon)
gcloud projects add-iam-policy-binding "$PROJECT" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/compute.viewer"

# Luo ja lataa JSON-avain paikalliseen tiedostoon
gcloud iam service-accounts keys create "$KEY_PATH" \
  --iam-account="$SA_EMAIL" \
  --project="$PROJECT"

# Rajoita tiedoston oikeudet koneellasi
chmod 600 "$KEY_PATH"

# Varmista polku ja tiedoston lupa
ls -l "$KEY_PATH"