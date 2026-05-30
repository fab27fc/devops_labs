[webservers]
%{ for index, server in webservers ~}
web0${index + 1} ansible_host=${server.private_ip} ansible_user=ubuntu
%{ endfor ~}

[webservers:vars]
ansible_ssh_private_key_file=~/.ssh/keypair_project_1-aws.pem
