sed -i 's/{ type = string }/{ \n  type = string\n}/g' variables.tf
sed -i 's/{ type = number }/{ \n  type = number\n}/g' variables.tf
sed -i 's/{ type = map(string) }/{ \n  type = map(string)\n}/g' variables.tf
sed -i 's/{ type = bool }/{ \n  type = bool\n}/g' variables.tf
sed -i 's/{ type = list(string) }/{ \n  type = list(string)\n}/g' variables.tf

sed -i '/variable "application_port"/!b;n;a\  default = 8000' variables.tf
sed -i '/variable "create_bastion_host"/!b;n;a\  default = false' variables.tf
sed -i '/variable "enable_https"/!b;n;a\  default = false' variables.tf
sed -i '/variable "enable_bastion_ssh"/!b;n;a\  default = false' variables.tf
sed -i '/variable "allowed_admin_cidrs"/!b;n;a\  default = []' variables.tf
