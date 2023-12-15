#!/bin/bash

# Function to check enabled APIs for a project
enabled_apis() {
  local project="$1"
  local output_file="${project}.txt"

  echo "Getting enabled APIs for $project" > "$output_file"
  servicesCommand=$(gcloud services list --enabled --project "$project" 2>&1)
  echo -e "$servicesCommand\n" >> "$output_file"
  echo "Getting IAM Service Accounts for $project" >> "$output_file"
  iamserviceaccountOutput=$(gcloud iam service-accounts list --project "$project" </dev/null 2>&1)
  echo "$iamserviceaccountOutput" >> "$output_file"
}

# Function to get information for a specific API
get_api_info() {
  local project="$1"
  local api="$2"
  local executeCommand="$3"
  local output_file="${project}.txt"
  echo -e "\n" >> "$output_file"
  echo "Getting $api for $project" >> "$output_file"
  commandOutput=$(eval "$executeCommand" </dev/null 2>&1)
  commandError=".*ERROR.*"
  if [ $? -eq 0 ]; then
    if [[ ! $commandOutput =~ $commandError ]]; then
        echo "$commandOutput" >> "$output_file"
    fi
  else
    echo "Error getting $api for $project" >> "$output_file"
  fi
}

get_recursive_info() {
  local executeCommand="$1"
  local project="$2"
  local output_file="${project}.txt"
  commandOutput=$(eval "$executeCommand" </dev/null 2>&1)
  if [ $? -eq 0 ]; then
    echo "$commandOutput" >> "$output_file"
  else
    echo "Error getting $api for $project" >> "$output_file"
  fi
}

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
  # Read the file line by line
  while IFS= read -r line <&3; do
    # Process each line
    echo "Processing project: $line"
    enabled_apis "$line"
    output_file="${line}.txt"

    # Get specific API information if enabled
    if [[ $servicesCommand =~ "compute.googleapis.com" ]]; then
      get_api_info "$line" "Compute Engine" "gcloud compute networks list --project $line"
    fi

    if [[ $servicesCommand =~ "bigquery.googleapis.com" ]]; then
      get_api_info "$line" "BigQuery" "bq ls --project_id $line"
    fi

    if [[ $servicesCommand =~ "containerregistry.googleapis.com" ]]; then
      get_api_info "$line" "k8s Images" "gcloud container images list --project $line"
    fi

    if [[ $servicesCommand =~ "container.googleapis.com" ]]; then
      get_api_info "$line" "k8s Clusters" "gcloud container clusters list --project $line"
    fi

    if [[ $servicesCommand =~ "storage-component.googleapis.com" ]]; then
      get_api_info "$line" "Storage" "gsutil ls -p $line"
      get_api_info "$line" "Storage Information" "gsutil ls -L -p $line"
      echo -e "\n\nGetting recursive storage information for: $line" >> "$output_file"
      for i in $(gsutil ls -p $line); do
        get_recursive_info "gsutil ls $i" "$line"
      done
    fi

    if [[ $servicesCommand =~ "cloudfunctions.googleapis.com" ]]; then
      get_api_info "$line" "Cloud Functions" "gcloud functions list --project $line"
    fi

    if [[ $servicesCommand =~ "sql-component.googleapis.com" ]]; then
      get_api_info "$line" "SQL" "gcloud sql instances list --project $line"
      for i in $(gcloud sql instances list --quiet --project $line | awk '{print $1}' | tail -n +2); do
        get_recursive_info "gcloud sql databases list --instance $i --project $line" "$line"
      done
    fi

    if [[ $servicesCommand =~ "firestore.googleapis.com" ]]; then
      get_api_info "$line" "Firestore" "gcloud firestore indexes composite list --project $line"
    fi

    if [[ $servicesCommand =~ "cloudkms.googleapis.com" ]]; then
      get_api_info "$line" "Cloud KMS" "gcloud kms keyrings list --location global --project $line"
      for i in $(gcloud kms keyrings list --location global --quiet --project $line); do
        get_recursive_info "gcloud kms keys list --keyring $i --location global --project $line" "$line"
      done
    fi

    if [[ $servicesCommand =~ "appengine.googleapis.com" ]]; then
      get_api_info "$line" "AppEngine" "gcloud app instances list --project $line"
    fi

    if [[ $servicesCommand =~ "secretmanager.googleapis.com" ]]; then
      get_api_info "$line" "Secrets" "gcloud secrets list --project $line"
    fi

    if [[ $servicesCommand =~ "pubsub.googleapis.com" ]]; then
      get_api_info "$line" "PubSub Topics" "gcloud pubsub topics list --project $line"
      get_api_info "$line" "PubSub Subscriptions" "gcloud pubsub subscriptions list --project $line"
      get_api_info "$line" "PubSub Schmeas" "gcloud pubsub schemas list --project $line"
      get_api_info "$line" "PubSub Snapshots" "gcloud pubsub snapshots list --project $line"
    fi

    if [[ $servicesCommand =~ "bigtable.googleapis.com" ]]; then
      get_api_info "$line" "BigTable" "gcloud bigtable instances list --project $line"
    fi

    if [[ $servicesCommand =~ "datastore.googleapis.com" ]]; then
      get_api_info "$line" "Datastore" "gcloud datastore indexes list --project $line"
    fi

    if [[ $servicesCommand =~ "spanner.googleapis.com" ]]; then
      get_api_info "$line" "Spanner" "gcloud spanner databases list --project $line"
      for i in $(gcloud spanner instances list --quiet --project $line | awk '{print $1}' | tail -n +2); do
        get_recursive_info "gcloud spanner databases list --instance $i --project $line" "$line"
      done
    fi

    if [[ $servicesCommand =~ "run.googleapis.com" ]]; then
      get_api_info "$line" "Cloud Run" "gcloud run services list --project $line"
    fi

    if [[ $servicesCommand =~ "dns.googleapis.com" ]]; then
      get_api_info "$line" "DNS Info" "gcloud dns project-info describe $line"
      get_api_info "$line" "DNS Managed Zones" "gcloud dns managed-zones list $line"
    fi

    if [[ $servicesCommand =~ "logging.googleapis.com" ]]; then
      get_api_info "$line" "Cloud Logging" "gcloud logging logs list --project $line"
      for i in $(gcloud logging logs list --quiet --format="table[no-heading](.)" --project $line); do
        echo "Looking for logs in $i:" >> "$output_file"
        get_recursive_info "gcloud logging read $i --project $line" "$line"
      done
    fi

  done 3< "$file_path"
else
  echo "File not found: $file_path"
fi
