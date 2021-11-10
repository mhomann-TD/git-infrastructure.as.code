##
## Makefile for (re)building the course manuals and environment
##

all: books vms

books: README.html STUDENT.html INSTRUCTOR.html

vms: server.qcow2 workstation.qcow2

server.qcow2: Makefile
	virt-builder fedora-35 \
	--format qcow2 \
	--install "bash,git,qemu-guest-agent" \
	--root-password password:Funk3nGr00v3n123 \
	--output $@ \
	--ssh-inject root:file:./id_ed25519.pub \
	--hostname $(basename $@) \
	--run-command 'useradd -m -p "" student' \
	--password student:password:student \
	--firstboot-command 'localectl set-keymap de' \
	--firstboot-command 'systemctl enable --now qemu-guest-agent' \
	--selinux-relabel

#	--update \

workstation.qcow2: Makefile
	virt-builder fedora-35 \
	--format qcow2 \
	--size 20G \
	--install "bash,git,@Deepin Desktop" \
	--root-password password:Funk3nGr00v3n123 \
	--output $@ \
	--ssh-inject root:file:./id_ed25519.pub \
	--hostname $(basename $@) \
	--run-command 'useradd -m -p "" student' \
	--password student:password:student \
	--firstboot-command 'localectl set-keymap de' \
	--firstboot-command 'touch /firstboot' \
	--selinux-relabel

#	--update \


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

