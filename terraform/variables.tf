variable "aws_region" {
  default = "ap-northeast-1"
}

variable "aws_vpc_settings" {
  type = object({
    vpc_id = string
    public_subnets = list(string)
    private_subnets = list(string)
  })
  default = {
    vpc_id = "vpc-XXXXXXXXXXXXXX"
    public_subnets = ["subnet-XXXXXXXXXXXXXX", "subnet-YYYYYYYYYYYYYYYY"]
    private_subnets = ["subnet-XXXXXXXXXXXXX", "subnet-YYYYYYYYYYYYYYY"]
  }
} 

variable "app_name" {
  default = "test"
}