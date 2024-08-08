#!/bin/bash

# Set your GitLab personal access token and GitLab instance URL
GITLAB_TOKEN=""
GITLAB_URL=""

# Number of pipelines to retain
RETAIN_COUNT=10

# List of project IDs to process. Use "all" to process all projects.
PROJECT_IDS="all"  # Example: "123 456 789" or "all"

# Function to delete old artifacts
delete_old_artifacts() {
  local project_id=$1

  echo "Processing project ID: $project_id"

  # Get a list of all pipelines in the project, sorted by descending order
  pipelines=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/projects/$project_id/pipelines?per_page=100&order_by=id&sort=desc" | jq -r '.[].id')

  # Skip the last RETAIN_COUNT pipelines
  pipelines_to_retain=$(echo "$pipelines" | head -n $RETAIN_COUNT)
  pipelines_to_delete=$(echo "$pipelines" | tail -n +$((RETAIN_COUNT + 1)))

  for pipeline_id in $pipelines_to_delete; do
    echo "Deleting artifacts for pipeline ID: $pipeline_id"

    # Get all jobs in the pipeline
    jobs=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/projects/$project_id/pipelines/$pipeline_id/jobs" | jq -r '.[].id')

    for job_id in $jobs; do
      echo "Deleting artifacts for job ID: $job_id"

      # Delete the artifacts for each job
      curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --request DELETE "$GITLAB_URL/api/v4/projects/$project_id/jobs/$job_id/artifacts"
    done
  done
}

if [ "$PROJECT_IDS" = "all" ]; then
  # Get a list of all projects
  project_ids=$(curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_URL/api/v4/projects?per_page=100" | jq -r '.[].id')
else
  project_ids=$PROJECT_IDS
fi

# Iterate over project IDs and delete old artifacts
for project_id in $project_ids; do
  echo "Deleting artifacts for project ID: $project_id"
  curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" --request DELETE "$GITLAB_URL/api/v4/projects/$project_id/artifacts"
done

echo "Old artifacts deleted, keeping the last $RETAIN_COUNT pipelines for each project."
