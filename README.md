# Tutorial for ansible-playbook

- --c191213
- author: engel-ch@pm.me
- license: MIT

## File & directory structure

```bash
hosts
./group_vars/
./roles/
./roles/hostname2/
./roles/profile/
./roles/hostname/
./host_vars/
```

1. `group_vars` contains variables for a group or all hosts.

   This directory usually contains the file `all`. This file is used for all hosts. Beside of this one, files like `t_rewrite` can exist. This file would only be applied for systems in the *t_rewrite* group. This file has precedence over entries in the `all` file.
2. `host_vars` contains files for specific hosts. These files end with the suffix `.yml`
3. `roles/` contain the roles as usual. A role with all potential directories can also be created using     the `ansible-galaxy` command.
4. `hosts` lists the actual hosts and defines groups of hosts

## Execution

### For all hosts in the hosts file

```bash
ansible-playbook -i hosts main.yml
```

### For specific hosts

```bash
ansible-playbook -i consul1, main.yml
```

### For some grouped hosts

```bash
ansible-playbook -i hosts --limit t_rewrite main.yml
```

### Tagged Execution

This call executes the commands in the main.yml file for all hosts in the `./hosts` file.

```bash
ansible-playbook -i hosts --limit t_rewrite -t dbg2  main.yml
```

### Example for host-specific variables

This call executs all commands tagged with dbg2 for all hosts specified in `./hosts`.

Here an example for host-specific variables.

```bash
  ansible-playbook -i hosts --limit t_rewrite -t hostname2  main.yml
    PLAY [test1] ******
    TASK [Gathering Facts] ******
    ok: [t-rewrite-cl]
    ok: [t-rewrite-srv]
    TASK [hostname2 : show hostname debug] ********
    ok: [t-rewrite-cl] => {
        "msg": "echo t-rewrite-cl.ioee2-cloud.com"
    }
    ok: [t-rewrite-srv] => {
        "msg": "echo t-rewrite-srv.ioee2-cloud.com"
    }
```

## Roles

create new role

```bash
ansible-galaxy init roles/profile
```

## Gather Facts

gather facts

```bash
ansible all -i hosts -m gather_facts > ansible.facts
```

## ansible-playbook CLI-options

```
--list-tags
--list-tasks
--list-hosts
--skip-tags ....  # do not execute the specified tags
--tags ...        # execute the specified tags
```

## Execution parameters

They can be specified in `./ansible.cfg`. These values cannot easily accessed in the ansible execution.
Access requires either the action plugin or vars plugin.

Here is an example file:

```
[defaults]

timeout = 33
interpreter_python = /usr/bin/python3
```
