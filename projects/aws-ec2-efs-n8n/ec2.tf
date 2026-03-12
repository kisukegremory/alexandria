data "aws_ami" "aws_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}



resource "aws_launch_template" "this" {
  name = "${local.project_name}-launch-template"
  image_id = data.aws_ami.aws_ami.id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    sudo su
    sudo yum -y install docker
    sudo yum -y install amazon-efs-utils
    systemctl start docker
    systemctl enable docker
    sudo usermod -a -G docker ec2-user
    mkdir -p ${local.efs_mount_point}
    sudo chown ec2-user:ec2-user ${local.efs_mount_point}
    sudo mount -t efs -o tls ${aws_efs_file_system.this.id}:/ ${local.efs_mount_point}
    echo "${aws_efs_file_system.this.id}:/ ${local.efs_mount_point} efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
    docker run -d --name n8n --restart=always -p 5678:5678 \
    -e N8N_SECURE_COOKIE=true \
    -e N8N_PUBLIC_API_DISABLED=true \
    -e N8N_HOST=${var.host_name} \
    -e N8N_PROTOCOL=https \
    -v ${local.efs_mount_point}:/home/node/.n8n \
    n8nio/n8n
  EOT
  )
}


resource "aws_autoscaling_group" "this" {
  name_prefix = "${local.project_name}-asg-"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  target_group_arns = [ aws_lb_target_group.instance_tg.arn ]
  vpc_zone_identifier = [data.aws_subnet.az-a.id]
  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }
}

resource "aws_autoscaling_schedule" "scale_up_during_working_hours" {
  scheduled_action_name  = "${local.project_name}-scale-up-during-working-hours"
  autoscaling_group_name = aws_autoscaling_group.this.name # Replace with your ASG name
  min_size               = 0
  max_size               = 1 # Or your desired max during work hours
  desired_capacity       = 1
  recurrence             = "0 8 * * 1-5"          # Cron expression for 8:00 AM Mon-Fri
  time_zone              = "America/Sao_Paulo"              # Specify your timezone
}

resource "aws_autoscaling_schedule" "scale_down_after_working_hours" {
  scheduled_action_name  = "${local.project_name}-scale-down-after-working-hours"
  autoscaling_group_name = aws_autoscaling_group.this.name # Replace with your ASG name
  min_size               = 0
  max_size               = 1
  desired_capacity       = 0
  recurrence             = "0 19 * * 1-5"         # Cron expression for (19:00) Mon-Fri
  time_zone              = "America/Sao_Paulo"              # Specify your timezone
}