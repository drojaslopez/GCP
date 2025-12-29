gcloud auth list

gcloud config list project


gcloud config set compute/region Region


gcloud iam list-testable-permissions //cloudresourcemanager.googleapis.com/projects/$DEVSHELL_PROJECT_ID



gcloud iam roles describe roles/editor



gcloud iam list-grantable-roles //cloudresourcemanager.googleapis.com/projects/$DEVSHELL_PROJECT_ID


nano role-definition.yaml

title: "Role Editor"
description: "Edit access for App Versions"
stage: "ALPHA"
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list

gcloud iam roles create editor --project $DEVSHELL_PROJECT_ID --file role-definition.yaml




gcloud iam roles create viewer --project $DEVSHELL_PROJECT_ID \
--title "Role Viewer" --description "Custom role description." \
--permissions compute.instances.get,compute.instances.list --stage ALPHA


gcloud iam roles describe editor --project $DEVSHELL_PROJECT_ID



description: Edit access for App Versions
etag: BwZGLbtQ1bY=
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
name: projects/qwiklabs-gcp-01-a3d4caac64d2/roles/editor
stage: ALPHA
title: Role Editor

nano new-role-definition.yaml

description: Edit access for App Versions
etag: BwVxIAbRq_I=
includedPermissions:
- appengine.versions.create
- appengine.versions.delete
- storage.buckets.get
- storage.buckets.list
name: projects/qwiklabs-gcp-01-a3d4caac64d2/roles/editor
stage: ALPHA
title: Role Editor


gcloud iam roles update editor --project $DEVSHELL_PROJECT_ID \
--file new-role-definition.yaml


gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--add-permissions storage.buckets.get,storage.buckets.list




gcloud iam roles update viewer --project $DEVSHELL_PROJECT_ID \
--stage DISABLED


gcloud iam roles delete viewer --project $DEVSHELL_PROJECT_ID

gcloud iam roles undelete viewer --project $DEVSHELL_PROJECT_ID