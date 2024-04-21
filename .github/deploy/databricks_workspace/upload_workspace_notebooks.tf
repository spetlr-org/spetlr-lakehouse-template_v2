# This module is for uploading all notebooks reside in the workspace folder to databricks workspace /Shared/dataplatform

# First, we want to exctract all directories nested in the workspace folder
locals {
  # Replace this with the path to your 'dataplatform' directory
  base_directory = "${path.cwd}/workspace"

  db_workspace_base_path = "/Shared/dataplatform"

  # List all paths within the 'workspace' directory
  all_paths = fileset(local.base_directory, "**/*")

  # Filter out directories from the list of paths
  # This method assumes that directories contain at least one file or subdirectory
  directories = [for path in local.all_paths : dirname(join("/", split("/", path))) if length(fileset("${local.base_directory}/${path}", "*")) > 0]

  # Remove duplicates from the list of directories
  unique_directories = distinct(local.directories)

  # Map each directory to its corresponding path in the Databricks workspace
  databricks_directories = { for d in local.unique_directories : d => "${local.db_workspace_base_path}/${d}" }

  # List all files within the 'workspace' directory
  all_files = tolist(fileset(local.base_directory, "**/*"))

  # Create a map of file paths to their corresponding workspace destination paths
  file_workspace_map = { for file in local.all_files : file => "${local.db_workspace_base_path}/${file}" }
}

# Create a dataplatform directory in the workspace
resource "databricks_directory" "workspace_dataplatform_directory" {
  provider = databricks.workspace
  path = local.db_workspace_base_path
}

# Create a Databricks directory for each unique directory found in the workspace
resource "databricks_directory" "workspace_directories" {
  provider = databricks.workspace
  for_each = local.databricks_directories

  # Use the value of each item in the map as the path for the Databricks directory
  path = each.value

  depends_on = [databricks_directory.workspace_dataplatform_directory]
}

# # Sync files to the created Databricks workspace
# resource "databricks_workspace_file" "sync_file" {
#   provider = databricks.workspace
#   for_each = local.file_workspace_map

#   source = "${local.base_directory}/${each.key}"
#   path   = each.value

#   depends_on = [databricks_directory.workspace_directories]
# }