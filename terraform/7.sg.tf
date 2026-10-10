# Security group for the cluster
resource "aws_security_group" "cluster" {
  name        = "k8s-cluster-sg"
  description = "Kubernetes cluster communication"
  vpc_id      = aws_vpc.k8s_vpc.id

  # SSH to master from your IP
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # SSH to private workers through master
  ingress {
    description     = "SSH from master"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
    self            = true
  }

  # Kubernetes API access from cluster nodes
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    self        = true
  }

  # Node-to-node cluster communication.
  # Restrict production rules further to required ports/protocols.
  ingress {
    description = "Cluster internal communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

##################################
    ingress {
            from_port   = 443
            to_port     = 443
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
    ingress {
            from_port   = 80
            to_port     = 80
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
    ingress {
            from_port   = 8080
            to_port     = 8080
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          }
#    ingress {
#            from_port   = 22
#            to_port     = 22
#            protocol    = "tcp"
#            cidr_blocks = ["0.0.0.0/0"]
#          }
  egress {
            from_port   = 0
            to_port     = 0
            protocol    = -1
            cidr_blocks = ["0.0.0.0/0"]
        }

  tags = {
    Name = "k8s-cluster-sg"
  }
}
