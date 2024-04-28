resource "databricks_pipeline" "nyc_tlc_dlt" {
  provider     = databricks.workspace
  name    = "NYC TLC DLT ETL"
  storage = "/test/first-pipeline"
  configuration = {
    env = var.environment
  }

  cluster {
    label       = "default"
    num_workers = 1
    custom_tags = {
      cluster_type = "default"
    }
  }

  library {
    notebook {
      path = "/Workspace/Shared/dataplatform/nyc_tlc_dlt/orchestrate_dlt_bronze.py"
    }
  }

  library {
    notebook {
      path = "/Workspace/Shared/dataplatform/nyc_tlc_dlt/orchestrate_dlt_silver.py"
    }
  }

  library {
    notebook {
      path = "/Workspace/Shared/dataplatform/nyc_tlc_dlt/orchestrate_dlt_gold.py"
    }
  }

  continuous = false

  depends_on = [
    databricks_notebook.sync_notebook,
    ]
}