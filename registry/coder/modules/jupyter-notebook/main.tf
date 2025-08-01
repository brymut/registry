terraform {
  required_version = ">= 1.0"

  required_providers {
    coder = {
      source  = "coder/coder"
      version = ">= 2.5"
    }
  }
}

# Add required variables for your modules and remove any unneeded variables
variable "agent_id" {
  type        = string
  description = "The ID of a Coder agent."
}

variable "log_path" {
  type        = string
  description = "The path to log jupyter notebook to."
  default     = "/tmp/jupyter-notebook.log"
}

variable "port" {
  type        = number
  description = "The port to run jupyter-notebook on."
  default     = 19999
}

variable "share" {
  type    = string
  default = "owner"
  validation {
    condition     = var.share == "owner" || var.share == "authenticated" || var.share == "public"
    error_message = "Incorrect value. Please set either 'owner', 'authenticated', or 'public'."
  }
}

variable "order" {
  type        = number
  description = "The order determines the position of app in the UI presentation. The lowest order is shown first and apps with equal order are sorted by name (ascending order)."
  default     = null
}

variable "group" {
  type        = string
  description = "The name of a group that this app belongs to."
  default     = null
}

variable "requirements_path" {
  type        = string
  description = "The path to requirements.txt with packages to preinstall"
  default     = ""
}

variable "pip_install_extra_packages" {
  type        = string
  description = "List of extra packages to preinstall (example: numpy==1.26.4 pandas matplotlib<4 scikit-learn)"
  default     = ""
}

resource "coder_script" "jupyter-notebook" {
  agent_id     = var.agent_id
  display_name = "jupyter-notebook"
  icon         = "/icon/jupyter.svg"
  script = templatefile("${path.module}/run.sh", {
    LOG_PATH : var.log_path,
    PORT : var.port,
    REQUIREMENTS_PATH : var.requirements_path,
    PIP_INSTALL_EXTRA_PACKAGES : var.pip_install_extra_packages
  })
  run_on_start = true
}

resource "coder_app" "jupyter-notebook" {
  agent_id     = var.agent_id
  slug         = "jupyter-notebook"
  display_name = "Jupyter Notebook"
  url          = "http://localhost:${var.port}"
  icon         = "/icon/jupyter.svg"
  subdomain    = true
  share        = var.share
  order        = var.order
  group        = var.group
}
