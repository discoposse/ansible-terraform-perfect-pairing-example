# Ansible + Terraform = Perfect Pairing

## About This Repository

This is a code and presentation bundle that will be used to show how Ansible and Terraform can be used together with AWS for a simple, and complete lifecycle for an application.

The presentation folder contains a PDF of what was presented at the Toronto Ansible Meetup on March 31, 2020 by Eric Wright thanks to the invitation by the team at Arctiq, who host the meetup.

## BEFORE YOU USE THIS REPO

This is a sample repository which is being used for a presentation.  There are OVERLY PERMISSIVE SECURITY SETTINGS in this repo.  Yes, I just used all caps to emphasize the point.  

Before you use this as a reference for production, note that:
 
* Security Group configuration is 0.0.0.0/0 for HTTP, HTTPS, and SSH - which is a terrible idea
* EC2 instance type comes from a variable _turbonomic_instance_size_

You need to be able to reach the instance using SSH to initially setup Ansible.  Ideally you should have a change at the Ansible build process to close up the security group after provisioning.  Hopefully this will be documented more fully here by @DiscoPosse :)


## Requiremens

To use this process as documented in the presetnation and demo:

* Must have a Terraform Cloud or Terraform Enterprise account
* Terraform local binary must match the Terraform Cloud version if you interact from the CLI
* Commands used in the remote-exec provisioner are not idempotent - plan accordingly
* Full example includes ACM (AWS Certificate Manager), EC2, Route53, and an ALB
* You must configure your Terraform Cloud to monitor artifacts/terraform 


