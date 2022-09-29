# CICD pipeline using terraform and GCP Cloud Build

The repository has two folders:
1. terraform
2. cloud_buid


## Folder: terraform

The folder has terraform code for infrastructure needed to setup and run ci-cd pipeline in GCP using Cloud Build and Cloud Run:

- subfolder common: It has terraform code for call providers, enable Google cloud APIs, add privileges, create storage bucket for terraform state and source code repo in GCP. This infrastructure will be common for all the environments (dev, stg or prod).

- subfolder module : It has terraform reusable modules. Different environments will call these modules to create the necessary resources by passing the input variables. Here we have only one module: build_trigger which is used to create the trigger for Cloud Build to kick off the build.

- subfolder environments: It has the configuration file to download the provider, set variables specific to environments and call the modules (i.e. to create environment specific triggers.)

## Folder: cloud_build

The folder has following three files:

- Dockerfile and index.html file: Dockerfile for nginx container and index.html file to display environment specific welcome message.
- cloudbuild.yaml: The file defines the fields that are needed for Cloud Build to perform build tasks.

## Step to use this repo:

### Before we start

We should have a working `gcloud` CLI, configured with a google cloud account (say account owner), and have the default application credentials file created:

```
gcloud auth application-default login
```

We should have an existing project in the above GCP account to get started.


###  Clone the repo:

```
git clone https://github.com/ashokm4/cicd.git
```

### Update terraform variables:

Update the local variable section in `module/main.tf` and `environments/(dev/prod)/main.tf` as per your setting.

### Create common infrastructure for all the environments:

```
cd common
terraform init
terraform plan
terraform apply
```
Imp: Above step will create a git-like source code repository in GCP. Changes in this repo will be trigger the build process

###  Create environment specific trigger:

```
cd environments/dev and cd environments/prod
terraform init
terraform plan
terraform apply
```
Above step will create environment specific cloud build triggers.

### Now clone the GCP source code repository created in previous steps:

```
git clone <GCP soure code repo url>
```

### Copy the contents of cloud_build subfolder to the GCP source code repository.

Commit the code to the master branch.

### Checkout development branch, make change and push it:

- Now make some changes in the development branch. In our case, just change the message in the index.html file and push the branch to the remote.
- Above step will trigger the build process. However we have set up the trigger with the require_approval flag set to true, so first we have to manually approve the build. Once this is done, build process will start
- At the end of build a new container image will be created and deployed using cloud run.
- Build log will have a service url. Copy and paste the URL on browser: You should see the modified message nginx front page.


### Merge the changes from development branch to production branch

Merge the changes from development branch to production branch and repeat the steps as in previous steps.


