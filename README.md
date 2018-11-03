# AWS VPC Terraform module

## Subnet

- public
- private
- intra

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

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
