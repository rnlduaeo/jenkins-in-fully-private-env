# Fully Private jenkins workload using ec2 spot fleet

This example deploys jenkins controller and agent AMI image using packer, configure jenkins agent with ec2 spot feet for cost optimization. Setting up Jenkins is already codified by [jenkins configuration as code](https://www.jenkins.io/projects/jcasc/).
This environment also assumes fully private network condition where the enterprise generally takes.
