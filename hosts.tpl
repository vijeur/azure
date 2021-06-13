[test_client_hosts]
%{ for ip in test_clients ~}
${ip}
%{ endfor ~}
[test_client_hosts:vars]
ansible_user=testadmin
ansible_ssh_private_key_file=./keys/ssh_key