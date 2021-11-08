# git-infrastructure.as.code

the git "infrastructure as code" student and instructor manuals

(c) 2021 Mathias Homann for Tech Data Akademie

## Creating books

To rebuild html and/or pdf files use pandoc.

## the lab environment

Create two VMs per student.
Images are created with virt-builder:

```
virt-builder fedora-34 --format qcow2 --install bash,git --root-password password:Funk3nGr00v3n123 -o client.qcow2 --ssh-inject root:file:/users/lemmy/.ssh/id_ed25519.pub --hostname workstation.gitworkshop.local --firstboot-command 'useradd -m -p "" student ; chage -d 0 student' --firstboot-command 'localectl set-keymap de'
virt-builder fedora-34 --format qcow2 --install bash,git --root-password password:Funk3nGr00v3n123 -o server.qcow2 --ssh-inject root:file:/users/lemmy/.ssh/id_ed25519.pub --hostname server.gitworkshop.local --firstboot-command 'useradd -m -p "" student ; chage -d 0 student' --firstboot-command 'localectl set-keymap de'
```

Per student, run two of these VMs. The VMs need to be able to access the internet, and resolve each other under useable names, i.e. "server.gitworkshop.local" and "workstation.gitworkshop.local".

## Accessing the labs

To access the lab machines, use the username "student". On first log in you will be prompted for a password for the user.
