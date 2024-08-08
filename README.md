This script is designed to delete GitLab project artifacts, retaining a specified number of recent pipelines.
It utilizes the GitLab API to achieve this task.

Variables:

- GITLAB_TOKEN: Your personal access token for GitLab API authentication.
- GITLAB_URL: The URL of your GitLab instance.
- RETAIN_COUNT: The number of recent pipelines whose artifacts you want to retain.
- PROJECT_IDS: A space-separated list of project IDs to process. Set to "all" to process all projects.

The script follows these steps:

1. Define a function `delete_old_artifacts` that takes a project ID as an argument:
   - It retrieves a list of all pipelines in the specified project, sorted by descending order of their IDs.
   - It separates the pipelines into those to retain and those to delete based on the RETAIN_COUNT variable.
   - For each pipeline to be deleted, it retrieves the jobs in the pipeline and deletes the artifacts associated with ch job.
2. Determine the list of project IDs to process:
   - If PROJECT_IDS is set to "all", the script retrieves a list of all project IDs using the GitLab API.
   - Otherwise, it uses the provided list of project IDs.
3. Iterate over the list of project IDs:
   - For each project ID, the script calls the `delete_old_artifacts` function to delete old artifacts.
   - It also uses the `/projects/:id/artifacts` endpoint to delete all artifacts eligible for deletion in the project.
4. Output a message indicating the completion of the artifact deletion process, specifying the number of retained pelines.

Note:

- The script assumes you have `jq` installed for JSON parsing.
- The API calls are authenticated using the provided personal access token.
- The script ensures that recent pipelines are retained and older artifacts are cleaned up to free up space.
