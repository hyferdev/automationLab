#!/usr/bin/env python3
"""
WORK IN PROGRESS

Connect to two Palo Alto firewalls via SSH using your default SSH key
and retrieve the API key by running 'request api-key'.

Requires: pip install paramiko
"""

import paramiko

def get_api_key_via_ssh(ip, username):
    """
    SSH to the firewall using default SSH key(s) and run 'request api-key'.
    """
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        print(f"[{ip}] Connecting...")

        # This uses your default SSH key(s) (from agent or ~/.ssh/id_rsa)
        ssh.connect(ip, username=username, look_for_keys=True, allow_agent=True, timeout=10)

        stdin, stdout, stderr = ssh.exec_command("request api-key")
        output = stdout.read().decode().strip()
        ssh.close()

        print(f"[{ip}] Connection successful.")
        return output

    except Exception as e:
        return f"[{ip}] Connection failed: {e}"


def main():
    print("=== Palo Alto SSH API Key Fetcher (default key) ===\n")

    ip1 = input("Enter IP/hostname of firewall 1: ").strip()
    ip2 = input("Enter IP/hostname of firewall 2: ").strip()
    username = input("SSH Username [admin]: ").strip() or "admin"

    print("\nFetching API keys...\n")
    for ip in [ip1, ip2]:
        result = get_api_key_via_ssh(ip, username)
        print(result)
        print("-" * 60)

    print("Done.")


if __name__ == "__main__":
    main()
