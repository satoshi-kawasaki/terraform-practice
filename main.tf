variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
    default = "ap-northeast-1"
}

# Configure AWS Provider
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

# Create Amazon VPC
resource "aws_vpc" "myVPC" {
    cidr_block = "10.1.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "false"
}

# Create AWS Internet Gateway
resource "aws_internet_gateway" "myGW" {
    vpc_id = "${aws_vpc.myVPC.id}"
}

# Create AWS subnet
resource "aws_subnet" "public-a" {
    vpc_id = "${aws_vpc.myVPC.id}"
    cidr_block = "10.1.1.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_route_table" "public-route" {
    vpc_id = "${aws_vpc.myVPC.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.myGW.id}"
    }
}

resource "aws_route_table_association" "puclic-a" {
    subnet_id = "${aws_subnet.public-a.id}"
    route_table_id = "${aws_route_table.public-route.id}"
}

resource "aws_security_group" "admin" {
    name = "admin"
    description = "Allow SSH inbound traffic"
    vpc_id = "${aws_vpc.myVPC.id}"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "cm-test" {
    ami = "ami-cbf90ecb"
    instance_type = "t2.micro"
    key_name = "satoshi.kawasaki"
    vpc_security_group_ids = [
      "${aws_security_group.admin.id}"
    ]
    subnet_id = "${aws_subnet.public-a.id}"
    associate_public_ip_address = "true"
}
