# Docker utility functions

`docker-functions.sh` provide functions that are meant to be used in bash conditions.

It can check if one:

- container...
    + exist
    + dont exist
    + is running
    + is not running
    + was created from a given image name
    + was not created from a given image name
- network...
    + exist
    + dont exist
- volume...
    + exist
    + dont exist

Check the `tests.sh` for examples.

## Example

Create an SSH agent and add a key.

```bash

source .docker-functions.sh

if container "ssh-agent" dont_exist;
    docker run -u 1000 -d --restart always -v ssh-agent-data:/ssh --name=ssh-agent whilp/ssh-agent
fi

if container "ssh-agent" not_created_from_image "whilp/ssh-agent";then
    echo "[ERROR] we expect the container ssh-agent to be created from the whilp/ssh-agent image"
    exit 1
fi

if container "ssh-agent" is_not_running;then
    docker start ssh-agent
fi

# add an ssh key to the agent
docker run -u 1000 --rm -v ssh-agent-data:/ssh -v $HOME:$HOME -it whilp/ssh-agent:latest ssh-add $HOME/.ssh/id_rsa
```
