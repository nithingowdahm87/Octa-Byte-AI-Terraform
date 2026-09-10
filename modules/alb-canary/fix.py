import re
with open('main.tf', 'r') as f: content = f.read()

# We can just append the lifecycle block right before the last closing brace of the aws_lb_listener blocks
content = re.sub(r'(resource "aws_lb_listener" "http" \{.*?)(^\})', r'\1  lifecycle {\n    ignore_changes = [default_action]\n  }\n\2', content, flags=re.MULTILINE|re.DOTALL)
content = re.sub(r'(resource "aws_lb_listener" "https" \{.*?)(^\})', r'\1  lifecycle {\n    ignore_changes = [default_action]\n  }\n\2', content, flags=re.MULTILINE|re.DOTALL)

with open('main.tf', 'w') as f: f.write(content)
