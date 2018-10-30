# Terraform 0.12 Examples
This repository contains some Terraform 0.12 examples that demonstrate new HCL features and other Terraform enhancements that are being added to Terraform 0.12. Each sub-directory contains a separate example that can be run separately from the others by running `terraform init` followed by `terraform apply`.

## Setting Up
1. Determine the location of the Terraform binary in your path. On a Mac of Linux machine, run `which terraform`. On a Windows machine, run `where terraform`.
1. Move your current copy of the Terraform binary to a different location outside your path and remember where so you can restore it after using the Terraform 0.12 alpha. Also note the old location.
1. Download the Terraform 0.12 alpha for your OS from https://releases.hashicorp.com/terraform/0.12.0-alpha1.
1. Unzip the file and copy the terraform or terraform.exe binary to the location where your original terraform binary was. If you did not previously have the terraform binary deployed, copy it to a location within your path or edit your PATH environment variable to include the directory you put it in.
1. Create a directory for the included providers and copy them to it:
  1. On a Mac, run `mkdir -p ~/.terraform.d/plugins/darwin_amd64` followed by `cp <install_directory>/terraform_0.12.0-alpha1_darwin_amd64/terraform-provider-* ~/.terraform.d/plugins/darwin_amd64/.`
  1. On a Linux machine, run `mkdir -p ~/.terraform.d/plugins/linux_amd64` followed by `cp <install_directory>/terraform_0.12.0-alpha1_darwin_amd64/terraform-provider-* ~/.terraform.d/plugins/amd_amd64/.`
  1. On a Windows laptop, run `mkdir %USERPROFILE%\terraform.d\plugins\windows_amd64` followed by `cp <install_directory>/terraform_0.12.0-alpha1_darwin_amd64/terraform-provider-* %USERPROFILE%/terraform.d/plugins/amd_amd64/.`  
1. Clone this repository to your laptop with the command `git clone https://github.com/rberlind/terraform-0.12-examples.git`.
1. Use `cd terraform-0.12-examples` to change into the directory that was created.

## First Class Expressions Example
The [First Class Expressions](./first-class-expressions) example creates an AWS VPC, a subnet, a network interface, and an EC2 instance. It illustrates the following new features:
1. Referencing of Terraform variables and resource attributes without interpolation using [First Class Expressions](https://www.hashicorp.com/blog/terraform-0-12-preview-first-class-expressions).
1. The need to include `=` when setting the value for attributes of type map or list.

In particular, the Terraform code that creates the VPC refers to the variable called vpc_name directly (`Name = var.vpc_name`) without using interpolation which would have used `${var.vpc_name}`. Other code in this example also directly refers to the id of the VPC (`vpc_id = aws_vpc.my_vpc.id`) in the subnet resource, to the id of the subnet (`subnet_id = aws_subnet.my_subnet.id`) in the network interface resource, and to the id of the network interface (`network_interface_id = aws_network_interface.foo.id`) in the EC2 instance. In a similar fashion, the output refers to the private_dns attribute (`value = aws_instance.foo.private_dns`) of the EC2 instance.

Additionally, the code uses `=` when setting the tags attributes of all the resources to the maps that include the Name key/value pairs.  For example the tags for the subnet are added with:
```
tags = {
  Name = "tf-0.12-example"
}
```
This is required in Terraform 0.12 since tags is an attribute rather than a block which would not use `=`. In contrast, we do not include `=` when specifying the network_interface block of the EC2 instance since this is a block.

It is not easy to distinguish blocks from attributes of type map when looking at pre-0.12 Terraform code. But if you look at the documentation for a resource, all blocks have their own sub-topic describing the block. So, there is a [Network Interfaces](https://www.terraform.io/docs/providers/aws/r/instance.html#network-interfaces) sub-topic for the network_interface block of the aws_instance resource, but there is no sub-topic for the tags attribute of the same resource.

For more on the difference between attributes and blocks, see [Attributes and Blocks](https://github.com/hashicorp/terraform/blob/v0.12-alpha/website/docs/configuration/syntax.html.md#attributes-and-blocks)

## For Expressions Examples
The [for-expressions](./for-expressions) example illustrates how the new [For Expression](https://github.com/hashicorp/terraform/blob/v0.12-alpha/website/docs/configuration/expressions.html.md#for-expressions) can be used to iterate across multiple items in lists. It does this for several outputs, iterating across 3 instances of a particular aws_instance resource to get a list of all 3 public DNS addresses and across the variable azs of type list that provides the availability zones the EC2 instances should be created in.

We actually generate the outputs that show the list of public DNS addresses for the 3 EC2 instances in two ways, first using the **old splat syntax**:
```
output "public_addresses_old" {
  value = aws_instance.ubuntu.*.public_dns
}
```
and then using the new **for** expression:
```
output "public_addresses_new" {
  value = [
    for instance in aws_instance.ubuntu:
    instance.public_dns
  ]
}
```
Both of these give an output like this:
```
public_addresses_new = [
  "ec2-54-159-217-16.compute-1.amazonaws.com",
  "ec2-35-170-33-78.compute-1.amazonaws.com",
  "ec2-18-233-162-38.compute-1.amazonaws.com",
]
```

We also demonstrate the use of the **for** expression to convert the availability zones contained in the azs variable to upper case. We first do this in a list:
```
output "upper-azs-list" {
  value = [for z in var.azs: upper(z)]
}
```
and then in a map:
```
output "upper-azs-map" {
  value = {for z in var.azs: z => upper(z)}
}
```
The first gives the output
which gives the output:
```
upper-azs-list = [
  "A",
  "B",
  "C",
]
```
while the second gives:
```
upper-azs-map = {
  "a" = "A"
  "b" = "B"
  "c" = "C"
}
```

## Cleanup
1. When done with the Terraform 0.12 alpha, remove the providers from the terraform.d or .terraform.d directory under your home directory and replace the Terraform 0.12 binary with the Terraform binary you were previously using.
