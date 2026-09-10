import os
import glob
import re

for filepath in glob.glob('**/variables.tf', recursive=True):
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    out_lines = []
    for line in lines:
        if line.startswith("variable"):
            # variable "name" { type = string, default = "val" }
            # Or currently it might be modified by the previous script
            # Let's just catch the basic signature
            pass
            
    # Actually it's easier to just use sed to format them correctly.
