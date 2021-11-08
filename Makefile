##
## Makefile for (re)building the course manuals and environment
##

all: README.html STUDENT.html INSTRUCTOR.html server.qcow2 workstation.qcow2

books: README.html STUDENT.html INSTRUCTOR.html

vms: server.qcow2 workstation.qcow2

%.qcow2:
	virt-builder fedora-34 \
	--format qcow2 \
	--install bash,git \
	--root-password password:Funk3nGr00v3n123 \
	-o $@ \
	--ssh-inject root:file:/users/lemmy/.ssh/id_ed25519.pub \
	--hostname $(basename $@).gitworkshop.local \
	--firstboot-command 'useradd -m -p "" student ; chage -d 0 student' \
	--firstboot-command 'localectl set-keymap de'

%.html:
	pandoc \
	-f markdown \
	-t html \
	-o $@ \
	$(basename $@).md

%.pdf:
	pandoc \
	-f markdown \
	-t pdf \
	-o $@ \
	$(basename $@).md

