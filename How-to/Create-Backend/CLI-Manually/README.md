# How to Create a Backend for Terraform

In this guide we will cover how to create a backend to store the Terraform state file.

- [How to Create a Backend for Terraform](#how-to-create-a-backend-for-terraform)
  - [Terraform State files](#terraform-state-files)
  - [Creating a place to store your state file](#creating-a-place-to-store-your-state-file)
    - [Create Azure Backend](#create-azure-backend)
      - [Creating Storage Account](#creating-storage-account)
    - [Create the AWS Backend](#create-the-aws-backend)
      - [Create S3 Bucket](#create-s3-bucket)
      - [Creating the DynamoDB Table](#creating-the-dynamodb-table)
      - [Creating IAM user](#creating-iam-user)

## Terraform State files

State files are very important, they hold the information regarding your infrastructure deployments and configurations. Rather than butchering an explanation myself I'll add this directly from Terraforms website:

> Terraform must store state about your managed infrastructure and configuration. This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures. 
> 
> Terraform uses this local state to create plans and make changes to your infrastructure. Prior to any operation, Terraform does a refresh to update the state with the real infrastructure.

*[Link to docs for reference above](https://www.terraform.io/docs/language/state/index.html)*

## Creating a place to store your state file

So there are two ways to manage your state file, locally and remote. The latter of those two being the easiest to manage within a team and also the safest as there is no way for the state file to be accidentally deleted.

You can store your state file in most cloud providers storage but the most common places are as follows:

- Azure container storage
- Amazon S3 Bucket
- GCP Cloud Storage Bucket

Now we know where we can store the state files lets cover actually setting up each of these in detail.

### Create Azure Backend

This guide assumes you're logged into Azure via the CLI, if you aren't then please follow the guides below: 

- [Install Az CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Login to Azure via CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)

#### Creating Storage Account

Firstly you'll need to create a storage account and a container to store the state file.

Use the below script to create the storage account via the CLI - please note you need to be logged into AZ-Cli - it also advised to replace the default names for the variables.

```bash
#!/bin/bash

RESOURCE_GROUP_NAME="tfstate"
STORAGE_ACCOUNT_NAME="tfstate$RANDOM"
CONTAINER_NAME="tfstate"
LOCATION="uksouth"

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
```

Once this has completed, you will need the following details from the storage account

- storage_account_name: The name of the Azure Storage account.
- container_name: The name of the blob container.
- key: The name of the state store file to be created.
- access_key: The storage access key.
- resource_group: The name of the resource group

This next step isn't always necessary but if you receive an error stating you cannot access the storage account due to the ARM_ACCESS_KEY, then use the below env variable:

```bash
ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
```

Next we will need to add the details of the storage account to the ```backend.tf```in order for Terraform to store the state file.

Below is the details you need for the backend:

```bash
backend "azurerm" {
  resource_group_name  = "<resource_group_name>"
  storage_account_name = "<storage_account_name>"
  container_name       = "<container_name"
  key                  = "tfstate"
}
```

Please follow the next step to then initialise the project and backend

Once this has been updated all your need to do is run the following command

```bash
terraform init
``` 

### Create the AWS Backend

This guide assumes you're already authenticated with AWS via the CLI - if you aren't then please follow the guides below:

- [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Login to AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

#### Create S3 Bucket

Firstly you'll need to create an S3 bucket to store the state and add the bucket encryption - that can be done below using the below script:

```bash
#!/bin/bash

BUCKET_NAME="tf-state"
REGION="eu-west-2"

aws s3api create-bucket –bucket $BUCKET_NAME –region $REGION –create-bucket-configuration LocationConstraint=$REGION

aws s3api put-bucket-encryption –bucket $BUCKET_NAME –server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\": \"AES256\"}}]}"
```

#### Creating the DynamoDB Table

Now the bucket with encryption has been created we now need to create the dynamoDB table to store the state lock to prevent concurrent access to the state file.

You can do that below with the following command:

```bash
TABLE_NAME="tf-state-lock"

aws dynamodb create-table –table-name $TABLE_NAME –attribute-definitions AttributeName=LockID,AttributeType=S –key-schema AttributeName=LockID,KeyType=HASH –provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

If there is no output in the CLI then that means the table has been successfully created.

#### Creating IAM user

We need a user to be able to access the S3 bucket and the DynamoDB table - this user will have a policy with only access to those two resources.

You will need to create a policy file to parse into the AWS command. 

Copy the below into the file and replace all the variables (example: $(REGION)) with the correct data from the previous steps:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem"
            ],
            "Resource": "arn:aws:dynamodb:$(Region):$(AWSAccountNumber):table/$(BackendLockTableName)"
        },
        {
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::$(BackendBucketName)"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::$(BackendBucketName)/$(PathToTFStateFile)"
        }
    ]
}
```

Next you'll need to run the command to create the user with the policy above

```bash
#!/bin/bash

POLICY_NAME="Terraform-customer-Backend-Policy"

aws iam create-policy –policy-name $POLICY_NAME –policy-document file://backend-role-policy.json
```

Finally you're ready to add the backend block to the ```backend.tf```file and initialise the project.

Use the backend block below but replace the variables with the corresponding details:

```bash
terraform {  
    backend "s3" {
        bucket         = "$(BackendBucketName)"    # the name of the S3 bucket that was created
        encrypt        = true
        key            = "$(PathToTFStateFile)"    # the path to the terraform.tfstate file stored inside the bucket
        region         = "$(BucketRegion)"         # the location of the bucket
        dynamodb_table = "$(BackendLockTableName)" # the name of the table to store the lock
    }
}
```

Once this has been saved, run the following terraform command:

```bash
terraform init
```

