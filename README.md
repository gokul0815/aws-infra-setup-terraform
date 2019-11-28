#  AWS  terraform example
​
Below are the variables which user has to change beofre running it.
​
    aws_region -> region where code should be deployed
​
    access_key -> aws access_key
​
    secret_key -> aws secret_key
​
    zone_id -> Aws route53 zone id
​
​
## Usage
The init argument will initialize the environment.
```bash
$ terraform init
```
​
The plan argument will syntax check the files and prepare the deployment.
```bash
$ terraform plan -out vpc.plan
```
​
Deploy the VPC:
​
```bash
$ terraform apply vpc.plan
```
​
This will deploy the AWS VPC. To view data about the VPC/Subnet/Security Group from your local Linux box execute:
​
```bash
$ terraform show
```
​
To destroy the VPC execute:
```bash
$ terraform destroy
```
