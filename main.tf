resource "aws_instance" "my-test-instance" {
  ami                    = "ami-0bdfa1adc3878cd23"
  instance_type          = "t2.micro"
  subnet_id              = "${aws_subnet.main-public-1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow-ssh.id}"]
  key_name               = "key-new"

  tags = {
          Name = "test-instance"
  }
}

resource "aws_security_group" "allow-ssh" {
  vpc_id = "${aws_vpc.main.id}"

   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags ={
    application = "DCP"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block_vpc}"
  instance_tenancy     = "default"
enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    application = "DCP"
  }
}


# Subnets
resource "aws_subnet" "main-public-1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.cidr_block_public}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch_public}"
  availability_zone       = "eu-west-2a"

  tags = {
    application = "DCP"
  }
}

resource "aws_subnet" "main-private-1" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.cidr_block_private}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch_private}"
  availability_zone       = "eu-west-2b"

  tags = {
    application = "DCP"
  }
}

# Internet GW
resource "aws_internet_gateway" "main-gw" {
    vpc_id = "${aws_vpc.main.id}"

    tags ={
        application = "DCP"
    }
}
# route tables
resource "aws_route_table" "main-public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.main-gw.id}"
    }

    tags ={
        application = "DCP"
    }
}
# Route table association
resource "aws_route_table_association" "main-public-1-a" {
    depends_on=[aws_route_table.main-public]
    subnet_id = "${aws_subnet.main-public-1.id}"
    route_table_id = "${aws_route_table.main-public.id}"
}
