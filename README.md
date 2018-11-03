# AWS VPC Terraform module

## About VPC

### Subnet

- public - Internet gateway
- private - NAT Gateway
- intra - None(Intranet)

## Usage

### Single Public Subnet

Reference - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario1.html

- Subnet - public
- NAT Gateway : no

```hcl
module "vpc" {
  source             = "github.com/jyotti/terraform-aws-vpc"
  name               = "simple"
  cidr_block         = "10.0.0.0/16"
  public_subnets     = ["10.0.32.0/20", "10.0.96.0/20", "10.0.160.0/20"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  tags = {
    Stage = "dev"
  }
}
```

### Public and Private Subnets (NAT)

Reference - https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Scenario2.html

- Subnet - public, private
- NAT Gateway : yes

```hcl
module "vpc" {
  source             = "github.com/jyotti/terraform-aws-vpc"
  name               = "public-and-private-subnets"
  cidr_block         = "10.0.0.0/16"
  public_subnets     = ["10.0.32.0/20", "10.0.96.0/20", "10.0.160.0/20"]
  private_subnets    = ["10.0.0.0/19", "10.0.64.0/19", "10.0.128.0/19"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Stage = "dev"
  }
}
```

## Example CIDR

I refer to the explanation of [Practical VPC Design](https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc).

```
10.0.0.0/16
    10.0.0.0/18 - AZ1
      10.0.0.0/19 - private
      10.0.32.0/19
        10.0.32.0/20 - public
        10.0.48.0/20
          10.0.48.0/21 - intra
          10.0.56.0/21 - (spare)
    10.0.64.0/18 - AZ2
      10.0.64.0/19 - private
      10.0.96.0/19
        10.0.96.0/20  - public
        10.0.112.0/20
          10.0.112.0/21 - intra
          10.0.120.0/21 - (spare)
    10.0.128.0/18 - AZ3
      10.0.128.0/19 - private
      10.0.160.0/19
        10.0.160.0/20 - public
        10.0.176.0/20
          10.0.176.0/21 - intra
          10.0.184.0/21 - (spare)
    10.0.192.0/18 - (spare)
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability\_zones | A list of availability zones in the region | list | `<list>` | no |
| cidr\_block | The CIDR block for the VPC | string | `10.0.0.0/16` | no |
| enable\_dynamodb\_endpoint | Should be true if you want to provision a DynamoDB endpoint to the VPC | string | `false` | no |
| enable\_nat\_gateway | Should be true if you want to provision NAT Gateways for each of your private networks | string | `false` | no |
| enable\_s3\_endpoint | Should be true if you want to provision an S3 endpoint to the VPC | string | `false` | no |
| intra\_subnet\_tags | Additional tags for the intra subnets | map | `<map>` | no |
| intra\_subnets | List of CIDR block for intra subnet | list | `<list>` | no |
| name | Name to be used on all the resources as identifier | string | `` | no |
| private\_subnet\_tags | Additional tags for the private subnets | map | `<map>` | no |
| private\_subnets | List of CIDR block for private subnet | list | `<list>` | no |
| public\_subnet\_tags | Additional tags for the public subnets | map | `<map>` | no |
| public\_subnets | List of CIDR block for public subnet | list | `<list>` | no |
| single\_nat\_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | string | `false` | no |
| tags | A map of tags to add to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| db\_subnet\_group | The db subnet group name |
| default\_route\_table\_id | The ID of the default route table |
| default\_security\_group\_id | The ID of the security group created by default on VPC creation |
| elasticache\_subnet\_group | The ElastiCache Subnet group ID |
| intra\_route\_table\_ids | List of IDs of intra route tables |
| intra\_subnet\_ids | List of IDs of the intra subnet |
| private\_route\_table\_ids | List of IDs of private route tables |
| private\_subnet\_ids | List of IDs of the private subnet |
| public\_route\_table\_ids | List of IDs of public route tables |
| public\_subnet\_ids | List of IDs of the public subnet |
| redshift\_subnet\_group | The Redshift Subnet group ID |
| vpc\_cidr\_block | The CIDR block of the VPC |
| vpc\_id | The ID of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
