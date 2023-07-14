#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Please provide the filename as an argument."
  exit 1
fi

file_path="$1"

if [[ -f "$file_path" ]]; then
  echo "Using file: $file_path"
else
  echo "File not found: $file_path"
  echo "Retrieving project list using gcloud..."

  gcloud projects list --format="value(project_id)" > "$file_path"

  if [[ -f "$file_path" ]]; then
    echo "Project list saved to $file_path"
  else
    echo "Failed to retrieve project list."
    exit 1
  fi
fi

if [[ -f "$file_path" ]]; then
  while IFS= read -r line <&3; do
    echo "Getting enabled APIs for $line"
    servicesCommand=$(gcloud services list --enabled --project "$line")
    echo "$servicesCommand"
    computeAPI="compute.googleapis.com"
    if [[ $servicesCommand =~ $computeAPI ]]; then
      echo "Getting Compute for $line"
      computeOutput=$(gcloud compute networks list --project "$line")
      computeregexError="^Listed\s\d+.*"
      if [[ ! $computeOutput =~ $computeregexError ]]; then
        echo "$computeOutput"
      fi
    fi
    bigqueryAPI="bigquery.googleapis.com"
    if [[ $servicesCommand =~ $bigqueryAPI ]]; then
      echo "Getting BigQuery for $line"
      bqOutput=$(bq ls --project_id "$line")
      bqregexError="^BigQuery\serror.*"
      if [[ ! $bqOutput =~ $bqregexError ]]; then
        echo "$bqOutput"
      fi
    fi
    containerAPI="containerregistry.googleapis.com"
    if [[ $servicesCommand =~ $containerAPI ]]; then
      echo "Getting Container for $line"
      containerOutput=$(gcloud container images list --project "$line")
      containerregexError="^ERROR.*"
      if [[ ! $containerOutput =~ $containerregexError ]]; then
        echo "$containerOutput"
      fi
    fi
    kubeAPI="container.googleapis.com"
    if [[ $servicesCommand =~ $kubeAPI ]]; then
      echo "Getting Clusters for $line"
      gcloud container clusters list --project "$line"
    fi
    storageAPI="storage-component.googleapis.com"
    if [[ $servicesCommand =~ $storageAPI ]]; then
      echo "Getting Storage for $line"
      storageOutput=$(gsutil ls -p "$line")
      storageregexError="^ERROR.*"
      if [[ ! $storageOutput =~ $storageregexError ]]; then
        echo "$storageOutput"
      fi
    fi
    functionsAPI="cloudfunctions.googleapis.com"
    if [[ $servicesCommand =~ $functionsAPI ]]; then
      echo "Getting Cloud Functions for $line"
      functionsOutput=$(gcloud functions list --project "$line")
      functionsregexError="^ERROR.*"
      if [[ ! $functionsOutput =~ $functionsregexError ]]; then
        echo "$functionsOutput"
      fi
    fi
    sqlAPI="sql-component.googleapis.com"
    if [[ $servicesCommand =~ $sqlAPI ]]; then
      echo "Getting SQL for $line"
      sqlOutput=$(gcloud sql instances list --project "$line")
      sqlregexError="^ERROR.*"
      if [[ ! $sqlOutput =~ $sqlregexError ]]; then
        echo "$sqlOutput"
      fi
    fi
    firestoreAPI="firestore.googleapis.com"
    if [[ $servicesCommand =~ $firestoreAPI ]]; then
      echo "Getting Firestore for $line"
      firestoreOutput=$(gcloud firestore indexes composite list --project "$line")
      firestoreregexError="^ERROR.*"
      if [[ ! $firestoreOutput =~ $firestoreregexError ]]; then
        echo "$firestoreOutput"
      fi
    fi
    kmsAPI="cloudkms.googleapis.com"
    if [[ $servicesCommand =~ $kmsAPI ]]; then
      echo "Getting Cloud KMS for $line"
      kmsOutput=$(gcloud kms keyrings list --location global --project "$line")
      kmsregexError="^ERROR.*"
      if [[ ! $kmsOutput =~ $kmsregexError ]]; then
        echo "$kmsOutput"
      fi
    fi
    secretsAPI="secretmanager.googleapis.com"
    if [[ $servicesCommand =~ $secretsAPI ]]; then
      echo "Getting SQL for $line"
      secretsOutput=$(gcloud secrets list --project "$line")
      secretsregexError="^ERROR.*"
      if [[ ! $secretsOutput =~ $secretsregexError ]]; then
        echo "$secretsOutput"
      fi
    fi

  done 3< "$file_path"   # Use file descriptor 3 for input redirection
else
  echo "File not found: $file_path"
fi
