
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
ansible-galaxy collection install git+https://github.com/synthesio/infra-ovh-ansible-module
ansible-playbook playbook.yml --ask-vault-pass
```


## TODO

- ansible-vault
- podman