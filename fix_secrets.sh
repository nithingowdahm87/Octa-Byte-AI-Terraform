sed -i 's/{ type = string }/{ \n  type = string\n}/g' modules/secrets/variables.tf
sed -i 's/{ type = number }/{ \n  type = number\n}/g' modules/secrets/variables.tf
sed -i 's/{ type = map(string) }/{ \n  type = map(string)\n}/g' modules/secrets/variables.tf

sed -i '/variable "secrets_kms_key_arn"/!b;n;a\  default = ""' modules/secrets/variables.tf
sed -i '/variable "ssm_kms_key_arn"/!b;n;a\  default = ""' modules/secrets/variables.tf
sed -i '/variable "db_endpoint"/!b;n;a\  default = "dummy"' modules/secrets/variables.tf
sed -i '/variable "db_port"/!b;n;a\  default = 5432' modules/secrets/variables.tf
sed -i '/variable "db_name"/!b;n;a\  default = "appdb"' modules/secrets/variables.tf
sed -i '/variable "db_master_username"/!b;n;a\  default = "dummy"' modules/secrets/variables.tf
sed -i '/variable "db_username_parameter_name"/!b;n;a\  default = "db-user"' modules/secrets/variables.tf
sed -i '/variable "db_username_prefix"/!b;n;a\  default = "user-"' modules/secrets/variables.tf

sed -i 's/{ type = string }/{ \n  type = string\n}/g' modules/iam/variables.tf
sed -i 's/{ type = map(string) }/{ \n  type = map(string)\n}/g' modules/iam/variables.tf
sed -i '/variable "secrets_arn"/!b;n;a\  default = ""' modules/iam/variables.tf
sed -i '/variable "kms_key_arn"/!b;n;a\  default = ""' modules/iam/variables.tf

