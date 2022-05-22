# Install aws cli and check the version of it
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
aws --version

# Remove the aws cli package after the setup
rm AWSCLIV2.pkg

# Configure AWS profile
aws configure

# Move to terraform folder 
cd terraform

# Setup Terraform 1.2.0 
wget https://releases.hashicorp.com/terraform/1.2.0/terraform_1.2.0_darwin_amd64.zip
unzip terraform_1.2.0_darwin_amd64.zip
# Set the name as tf_1.2 to not override the terraform already setup
mv terraform /usr/local/bin/tf_1.2
tf_1.2 version

# Remove terraform binary zip
rm terraform_1.2.0_darwin_amd64.zip

# Init the terraform script and apply
tf_1.2 init
tf_1.2 $1
