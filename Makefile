##
## Makefile for (re)building the course manuals and environment
##

all: books vms

books: README.html STUDENT.html INSTRUCTOR.html

vms: server.qcow2 workstation.qcow2

vmdk: server.vmdk workstation.vmdk

server.qcow2: Makefile
	virt-builder fedora-35 \
	--format qcow2 \
	--install "bash,git,qemu-guest-agent,vim" \
	--root-password password:Funk3nGr00v3n123 \
	--output $@ \
	--ssh-inject root:file:./id_ed25519.pub \
	--hostname $(basename $@) \
	--run-command 'useradd -m -G wheel -p "" student' \
	--password student:password:student \
	--firstboot-command 'dnf update -y' \
	--firstboot-command 'dnf install -y glibc-langpack-de' \
	--firstboot-command 'localectl set-locale LANG=de_DE.UTF-8' \
	--firstboot-command 'localectl set-keymap de-nodeadkeys' \
	--firstboot-command 'localectl set-x11-keymap de --no-convert' \
	--firstboot-command 'systemctl enable --now qemu-guest-agent' \
	--firstboot-command 'systemctl reboot' \
	--selinux-relabel

workstation.qcow2: Makefile
	virt-builder fedora-35 \
	--format qcow2 \
	--size 20G \
	--install "bash,git,vim,vim-syntastic-ansible,vim-ansible,@kde-desktop-environment" \
	--root-password password:Funk3nGr00v3n123 \
	--output $@ \
	--ssh-inject root:file:./id_ed25519.pub \
	--hostname $(basename $@) \
	--run-command 'useradd -m -G wheel -p "" student' \
	--password student:password:student \
	--firstboot-command 'dnf update -y' \
	--firstboot-command 'dnf install -y glibc-langpack-de' \
	--firstboot-command 'localectl set-locale LANG=de_DE.UTF-8' \
	--firstboot-command 'localectl set-keymap de-nodeadkeys' \
	--firstboot-command 'localectl set-x11-keymap de --no-convert' \
	--firstboot-command 'systemctl enable --now qemu-guest-agent' \
	--firstboot-command 'systemctl set-default graphical.target' \
	--firstboot-command 'systemctl isolate graphical.target' \
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

