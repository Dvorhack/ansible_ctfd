
## Usage:

Change variables in `group_vars/all.yml`

`group_vars/secrets.yml` should contain: 
- github_token
- OVH_application_key
- OVH_application_secret
- OVH_consumer_key
- ctfd_username
- ctfd_password

```
# full install
ansible-galaxy collection install git+https://github.com/synthesio/infra-ovh-ansible-module
ansible-playbook playbook.yml --ask-vault-pass

# only sync challenges
ansible-playbook playbook.yml --ask-vault-pass  --tag challs -e 'ctfd_admin_token=REDACTED'
```


## TODO

- podman