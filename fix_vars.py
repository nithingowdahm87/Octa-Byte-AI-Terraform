import os
import glob

for filepath in glob.glob('**/variables.tf', recursive=True):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Simple replace for the one-liners that got messed up in dev/bootstrap
    # variable "aws_region" { type = string, default = "ap-south-1" } -> variable "aws_region" { type = string \n default = "ap-south-1" }
    content = content.replace(", default =", "\n  default =")
    
    with open(filepath, 'w') as f:
        f.write(content)
