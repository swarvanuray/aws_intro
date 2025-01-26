

output "ssh_command_worker_nodes" {
  value       = <<-SSHCOMMAND
  %{for dns in aws_instance.web[*].public_dns}
  ssh -i ~/.ssh/{aws_key_pair.this.key_name} ec2-user@${dns}
  %{endfor}
  SSHCOMMAND
  description = "ssh command for connect to the worker node"
}