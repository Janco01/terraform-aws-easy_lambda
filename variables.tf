variable "archive_file" {
    type = object({
      source_file = string
      output_path = string
    })
}

variable "lambda_function" {
    type = object({
      function_name = string
      handler = string
      runtime = string
    })
}

variable "env_vars" {
    type = map(string)
    default = { }
}