##
## Makefile for (re)building the course manuals and environment
##

all: books vms

books: README.html STUDENT.html INSTRUCTOR.html

pdf: README.pdf STUDENT.pdf

vms: server.qcow2 workstation.qcow2

vmdk: server.vmdk workstation.vmdk

server.qcow2: Makefile
	virt-builder centos-8.2 \
	--format qcow2 \
	--update \
	--install "bash,git,qemu-guest-agent,vim-enhanced,glibc-langpack-de,PackageKit-command-not-found,centos-release-ansible-29,bash-completion,@minimal-environment" \
	--install "ansible" \
	--root-password password:Funk3nGr00v3n123 \
	--output $@ \
	--ssh-inject root:file:./id_ed25519.pub \
	--hostname $(basename $@) \
	--timezone "Europe/Berlin" \
	--run-command 'useradd -m -G wheel -p "" student' \
	--password student:password:student \
	--firstboot-command 'localectl set-locale LANG=de_DE.UTF-8' \
	--firstboot-command 'localectl set-keymap de-nodeadkeys' \
	--firstboot-command 'localectl set-x11-keymap de --no-convert' \
	--firstboot-command 'systemctl enable --now qemu-guest-agent' \
	--firstboot-command 'systemctl reboot' \
	--selinux-relabel

workstation.qcow2: Makefile
	virt-builder centos-8.2 \
	--format qcow2 \
	--size 20G \
        --update \
	--install "bash,git,qemu-guest-agent,vim-enhanced,glibc-langpack-de,PackageKit-command-not-found,centos-release-ansible-29,bash-completion,@graphical-server-environment" \
	--install "ansible" \
	--root-password password:Funk3nGr00v3n123 \
	--output $@ \
	--ssh-inject root:file:./id_ed25519.pub \
	--hostname $(basename $@) \
	--timezone "Europe/Berlin" \
	--run-command 'useradd -m -G wheel -p "" student' \
	--password student:password:student \
	--firstboot-command 'localectl set-locale LANG=de_DE.UTF-8' \
	--firstboot-command 'localectl set-keymap de-nodeadkeys' \
	--firstboot-command 'localectl set-x11-keymap de --no-convert' \
	--firstboot-command 'systemctl enable --now qemu-guest-agent' \
	--firstboot-command 'systemctl set-default graphical.target' \
	--firstboot-command 'systemctl reboot' \
	--selinux-relabel

server.vmdk: server.qcow2
	qemu-img convert -f qcow2 -O vmdk server.qcow2 server.vmdk

workstation.vmdk: workstation.qcow2
	qemu-img convert -f qcow2 -O vmdk workstation.qcow2 workstation.vmdk

%.html : %.md
	pandoc \
	-f markdown \
	-t html \
	-o $@ \
	$(basename $@).md

%.pdf : %.md
	pandoc \
	-f markdown \
	-t pdf \
	-o $@ \
	$(basename $@).md

