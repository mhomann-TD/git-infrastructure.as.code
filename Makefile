##
## Makefile for (re)building the course manuals and environment
##

all: books vms

books: README.html STUDENT.html INSTRUCTOR.html

vms: server.qcow2 workstation.qcow2

%.qcow2: Makefile
	virt-builder fedora-34 \
	--update \
	--format qcow2 \
	--install bash,git \
	--root-password password:Funk3nGr00v3n123 \
	-o $@ \
	--ssh-inject root:file:./id_ed25519.pub \
	--hostname $(basename $@) \
	--run-command 'useradd -m -p "" student ; chage -d 0 student' \
	--firstboot-command 'localectl set-keymap de' \
	--firstboot-command 'touch /firstboot'

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

