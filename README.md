# Terraform 0.12 Examples
This repository contains some Terraform 0.12 examples that demonstrate new HCL features and other Terraform enhancements that are being added to Terraform 0.12. Each sub-directory contains a separate example that can be run separately from the others by running `terraform init` followed by `terraform apply`.

## AWS Instance With Network
The [AWS VPC](./aws-instance-with-network) example creates an AWS VPC, a subnet, a network interface, and an EC2 instance. It illustrates the following new features:
1. Referencing of Terraform variables without interpolation.
1. Referencing of resource attributes witout interpolation in other resources and outputs.
1. The need to include `=` when setting the value for attributes of type map or list.

In particular, the setting of a Name tag for the VPC is done with this code:
```
  tags = {
    Name = var.vpc_name
  }
```
Note that this code refers to the variable called name directly (`Name = var.vpc_name`) without using interpolation which would have used `${var.vpc_name}`. It also directly refers to the id of the VPC (`vpc_id = aws_vpc.my_vpc.id`) in the subnet resource, to the id of the subnet (`subnet_id = aws_subnet.my_subnet.id`) in the network interface resource, and to the id of the network interface (`network_interface_id = aws_network_interface.foo.id`) in the EC2 instance. In a similar fashion, the output refers to the private_dns attribute (`value = aws_instance.foo.private_dns`) of the EC2 instance.

Additionally, it uses `=` when setting the tags attributes of all the resources to the maps that includes the Name key/value pair. This is required in Terraform 0.12 since tags is an attribute rather than a block which would not use `=`. (Note that cidr_block is an attribute despite the inclusion of "block" in its name.) In contrast, we do not include `=` when specifying the network_interface block of the EC2 instance since this is a block.

It is not easy to distinguish blocks from attributes of type map when looking at pre-0.12 Terraform code. But if you look at the documentation for a resource, all blocks have their own sub-topic describing the block. So, there is a [Network Interfaces](https://www.terraform.io/docs/providers/aws/r/instance.html#network-interfaces) sub-topic for the network_interface block of the aws_instance resource, but there is no sub-topic for the tags attribute of the same resource.

For more on the difference between attributes and blocks, see [Attributes and Blocks](https://github.com/hashicorp/terraform/blob/v0.12-alpha/website/docs/configuration/syntax.html.md#attributes-and-blocks)
