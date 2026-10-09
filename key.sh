#!/bin/bash

#copy private key to terraform code
cp ~/.ssh/id_rsa.pub terraform/key.pub

#copy private key to public vm to access private vm 
#scp /home/ec2-user/.ssh/id_rsa ec2-user@10.0.2.138:/home/ec2-user/.ssh/id_rsa

