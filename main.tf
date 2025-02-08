module "sg_web" {
  source                    = "./sg"
  sg_name                   = "ec2_web_sg"
  allowed_ports_from_public = var.allowed_ports_from_public_to_web_ec2
}

module "sg_database" {
  source                    = "./sg"
  sg_name                   = "ec2_database_sg"
  allowed_ports_from_public = var.allowed_ports_from_public_to_database_ec2
  allowed_ports_from_sg = [{
    sg_id = module.sg_web.sg_id
    port : 3306
  }]
}

module "img_storage_s3" {
  source        = "./s3"
  bucket_policy = data.aws_iam_policy_document.allow_access_from_webs_to_img_storage.json
}

data "aws_iam_policy_document" "web_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "web_role" {
  assume_role_policy = data.aws_iam_policy_document.web_assume_role_policy.json
}

resource "aws_iam_instance_profile" "web_profile" {
  role = aws_iam_role.web_role.name
}

data "aws_iam_policy_document" "allow_access_from_webs_to_img_storage" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.web_role.arn]
    }

    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [
      module.img_storage_s3.arn,
      "${module.img_storage_s3.arn}/*"
    ]
  }
}

module "webs_ec2" {
  count = var.num_web

  source               = "./ec2"
  iam_instance_profile = aws_iam_instance_profile.web_profile.name
  key_name             = var.key_name
  instance_name        = "${var.web_instance_name}-${count.index + 1}"
  instance_type        = var.instance_type
  sg_ids               = [module.sg_web.sg_id]
  userdata             = file("${path.module}/web_ec2_userdata.sh")
}

module "database_ec2" {
  source        = "./ec2"
  key_name      = var.key_name
  instance_name = var.database_instance_name
  instance_type = var.instance_type
  sg_ids        = [module.sg_database.sg_id]
  userdata = templatefile("${path.module}/database_ec2_userdata.sh.tftpl", {
    instances : {
      for instance in module.webs_ec2 : instance.instance_id => instance.private_dns
    },
    db_database : var.db_database
    db_admin_username : "admin",
    db_admin_password : "secret"
  })
}

locals {
  local_web_directory  = "${path.module}/web"
  remote_web_directory = "/home/ubuntu/web"
}

resource "null_resource" "build_web" {
  provisioner "local-exec" {
    command = templatefile("${path.module}/build_web.sh.tftpl", {
      web_directory : local.local_web_directory
    })
    working_dir = path.module
  }
}

resource "null_resource" "run_webs" {
  depends_on = [null_resource.build_web]

  count = length(module.webs_ec2)

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = module.webs_ec2[count.index].public_ip
    private_key = file("~/${var.key_name}.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",

      # Update
      "sudo apt update",
      "rm -rf web",
      "mkdir web"
    ]
  }

  provisioner "file" {
    source      = "${local.local_web_directory}/.next"
    destination = local.remote_web_directory
  }

  provisioner "file" {
    source      = "${local.local_web_directory}/package.json"
    destination = "${local.remote_web_directory}/package.json"
  }

  provisioner "file" {
    source      = "${local.local_web_directory}/next.config.ts"
    destination = "${local.remote_web_directory}/next.config.ts"
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",

      # Install nodejs
      "sudo apt install -y nodejs",
      "sudo apt install -y npm",

      # Install pm2 and stop process if exists
      "sudo npm install -g pm2",
      "pm2 delete 'my-web'",

      # Add environment variables
      "cd web",
      "echo 'DB_HOST=${module.database_ec2.private_dns}' >> .env",
      "echo 'DB_USER=${module.webs_ec2[count.index].instance_id}' >> .env",
      "echo 'DB_PASSWORD=${module.webs_ec2[count.index].instance_id}' >> .env",
      "echo 'DB_DATABASE=${var.db_database}' >> .env",
      "echo 'BACKEND_URL=http://localhost:3000' >> .env",
      "echo 'AWS_ACCESS_KEY=${var.access_key}' >> .env",
      "echo 'AWS_SECRET_KEY=${var.secret_key}' >> .env",
      "echo 'AWS_REGION=${var.region}' >> .env",
      "echo 'AWS_BUCKET_NAME=${module.img_storage_s3.name}' >> .env",

      # Build and run web
      "npm install --force --production",
      "pm2 start --name 'my-web' npm -- start"
    ]
  }
}

resource "null_resource" "clean" {
  depends_on = [null_resource.run_webs]

  provisioner "local-exec" {
    command = "rm -rf ${local.local_web_directory}"
  }
}
