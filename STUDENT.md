% GIT - Infrastructure as code, Student Workbook
% Mathias Homann
% 11-2021

# GIT - Infrastructure as code
# Student manual

## Was bedeutet eigentlich "Infrastructure as code"?

Immer öfter hört man heute den Begriff "Infrastructure as code", aber was bedeutet das eigentlich?

Es ist eigentlich ziemlich simpel: "Infrastructure as code" ist nichts anderes als eine neue Art und Weise, an die Konfiguration
kompletter IT-Umgebungen heranzugehen.
Dabei wird so viel wie möglich in Form von Scripten (im weitesten Sinne des Wortes) implementiert. Dieses bringt uns mehrere Vorteile:

* Wiederholbarkeit

* Fehlerfreiheit

* Automatisierbarkeit

Wiederholbarkeit bedeutet, dass man den gleichen Prozess immer wieder verwenden kann, und sich darauf verlassen kann dass der Prozess
immer gleich abläuft.

Fehlerfreiheit bedeutet, dass ein Prozess, den man ein mal korrekt implementiert hat, durch seine Wiederholbarkeit sicherstellt, dass keine Fehler auftreten.

Automatisierbarkeit ist die Kombination dieser Eigenschaften: Einen Prozess, den ich korrekt und wiederholbar implementiert habe, kann ich mit gutem Gewissen automatisch ablaufen lassen.

### Idempotenz
Eine wichtige Voraussetzung hier ist die sogenannte **Idempotenz**.

Idempotenz bedeutet, dass ich einen Prozess beliebig oft wiederholen kann, und garantiert jedesmal das gleiche Ergebnis herauskommt.
Ein Beispiel aus der Welt der Zahlen:

`x=x+2` ist **nicht** idempotent - nach dem ersten Aufruf ist der Wert der Variablen 2, danach 4, dann 6, und so weiter.

`x=x*2` ist hingegen idempotent - egal wie oft man es ausführt, das Ergebnis ist **immer gleich**.

Um das ganze mal in die Welt der Systemadministration zu heben:

`mkdir /tmp/testdir` wird beim ersten Aufruf funktionieren, aber wenn das Verzeixchnis dann existiert, wird jeder weitere Aufruf zu einer Fehlermeldung führen - also **nicht** idempotent.

`test -d /tmp/testdir || mkdir /tmp/testdir` wird hingegen bei **jedem** Aufruf ordnungsgemäß funktionieren - also ist diese Form **idempotent**.

### Systemunabhängigkeit

Eine weitere wichtige Eigenschaft der verwendeten Skripte ist die **Systemunabhängigkeit**. 

Das bedeutet, dass man in den Skripten beschreibt, welches Ergebnis man wünscht, aber sich nicht darum kümmern muss, wie genau dieses Ergebnis zu erreichen ist - darum kümmern sich die verwendeten Werkzeuge.

### Versionsverwaltung

Zu guter Letzt benötigt man eine wie auch immer geartete **Versionsverwaltung** in der die erzeugten Konfigurationsscripte abgelegt werden. Dadurch kann man immer zur letzten als gut bekannten Konfiguration zurückkehren wenn es denn doch einmal nötig sein sollte.

## Welche Tools gibt es

### Automatisierungstools

* Saltstack: Ein open source Konfigurationsmanagement für Server. Setzt einen zentralen Server voraus, der die Aufgaben an die "minions" verteilt. Steht unter der apache-Lizenz. Wurde in 2020 von VMWare aufgekauft, seitdem ist die "offizielle Webseite" ziemlich nutzlos.
  
* Puppet: Ein weiteres open source Konfigurationssystem. Auch puppet benötigt einen zentralen Server (den "Puppet master"). Wichtiges Merkmal: Die verschiedenen schritte in puppet-"scripten", den sogenannten Modulen, können, und werden, in beliebiger Reihenfolge ausgeführt werden. **Idempotenz** ist hier **lebenswichtig**.
  
* Ansible: Das dritte der verbreiteten Konfigurationssysteme. Ansible-Playbooks sind in YAML verfasst, einfach zu lesen, und werden (im Gegensatz zu Puppet) von oebn nach unten abgearbeitet, was den Umgang mit Ansible wesentlich einfacher macht. Ansible benötigt im Gegensatz zu Puppet und Saltstack **keinen** zentralen Server, esgibt aber eine zentralisiert einsetzbare Webapplikation, den "Ansible Tower", der ansible um RBAC (role based access controls), Logging, scheduling, u.v.m. erweitert.

Red Hat Linux unterstützt Puppet und Ansible, wir werden uns im Weiteren mit Ansible befassen.

### Versionsverwaltung

Versionsverwaltungssoftware gibt es wie Sand am Meer: rcs, cvs, mercurial, subversion, git, um nur die bekanntesten zu nennen.
Wir werden im weiteren auf git näher eingehen.

## Was ist Ansible

Ansible ist eine "Systembeschreibungssprache", das bedeutet ich sage was ich will, und Ansible weiss dann "von selber" wie das zu machen ist. ein Beispiel:

`ansible -m package -a 'name=httpd state=latest' -bkK server17`

Heisst in umgangssprachlichem Deutsch:
"Liebes Ansible, ich möchte, dass auf Server17 das Paket 'httpd' in der aktuellsten Version installiert ist. Dazu brauchst du das `package` modul, das musst du als root machen, nach den benötigten Passwörtern sollst du mich fragen."
Und ob Server17 nun ein RHEL (oder ein Abkömmling) ist, wo man das entweder mit yum oder dnf macht, oder ein SLES/openSUSE wo der Paketmanager zypper heisst, oder gar ein debian mit apt-get oder aptitude - das ist vollkommen Wurst, darum kümmert sich Ansible selber. Und auch ob das Paket schon drauf ist, oder in einer älteren Version, oder gar nicht, ist für diesen Befehl egal.

Mit ansible kann man (wie eben gesehen) sogenannte "ad-hoc-befehle" ausführen lassen, oder man schreibt sogenannte "playbooks". Ein Playbook ist eine ganze Abfolge von ansible-modulaufrufen, die nacheinander ausgeführt werden.

### Und was ist mit der idempotenz? 
Ansible-befehle sind bis auf wenige Ausnahmen immer idempotent - wenn in dem obigen Beispiel das httpd-paket schon in der aktuellsten Version installiert ist sagt Ansible einfach "Oh. Na dann ist ja alles gut und ich muss nix tun."
Die wenigen Ausnahmen: alles was man mit dem -raw, dem -command und dem -shell modul macht. Mit diesen drei Ansible-Modulen werden nämlich direkt "native" Befehle auf den Zielsystemen ausgeführt - ohne auf die Ergebnisse zu achten. Somit muss man da dann selber auf die Idempotenz achten... und das kann schon etwas fehleranfällig werden.

### Ansible-module?
Ansible basiert auf tausenden von Modulen. In diesen Modulen steckt die eigentliche Logik hinter Ansible. So z.B. das oben schon verwendete "package" modul, was betriebssystemunabhängig Softwarepakete installiert, deinstalliert, und updatet.
Es gibt zur Zeit über 3300 Module für alle Zwecke, vom einfachen Anlegen von Dateien bis zur Verwaltung meiner AWS-Instanzen, und viele mehr - sogar Windows-systeme und Netzwerkhardware kann mit Ansible gemanagt werden.

Eine liste aller für meine Ansible-version verfügbaren Module sehe ich mit dem Befehl `ansible-doc -l`. Mit dem gleichen Befehl sehe ich dann auch die Dokumentation für ein Modul, z.B. so: `ansible-doc package` um die Doku für das package-modul zu lesen.

### Playbooks?
Ein Ansible-playbook ist im Grunde nichts anderes als ein script, in dem nacheinander verschiedene Module mit Parametern aufgerufen werden.
Playbooks sind in YAML geschrieben ("yet another markup language"). Zu YAML muss ich zwei Dinge wissen:

* YAML ist einfach wie klartext zu lesen (das ist gut)
* YAML ist sehr pingelig was die Einrücktiefe angeht - eine falsch eingerückte Zeile führt zu Fehlermeldungen - aber nicht unbedingt in der betreffenden Zeile sondern ganz wo anders... (Das ist nicht gut)

Für die Problematik mit den Einrückungen gibt es eine relativ einfache Lösung:
* den `vim` editor nutzen
* die folgende zeile in `~/.vimrc` eintragen:

```
autocmd FileType yaml setlocal ai ts=2 sw=2 et cc=3,5,7,9,11
```

Diese Zeile führt dazu, dass `vim` bei YAML-Dateien automatisch einrückt, das immer um zwei Leerzeichen mehr (oder weniger) tut, und dazu noch die ersten 5 Einrückstufen in rot markiert. Dieser Trick hat dem Ersteller dieses Dokumentes auch schon viele graue Haare erspart...

Zuletzt noch ein Beispiel für ein sehr einfaches Playbook:

```
- hosts: test-servers
  remote_user: nahmed
  become: true
  vars:
    project_root: /var/www/html
  tasks:  
  - name: Install Apache Webserver
    yum: pkg=httpd state=latest
  - name: Place the index file at project root
    copy: src=index.html dest={{ project_root }}/index.html owner=apache group=apache mode=0644
  - name: Enable Apache on system reboot
    service: name=httpd enabled=yes
    notify: restart apache
  handlers:
  - name: restart apache
    service: name=httpd state=restarted
```

Was genau passiert hier nun?
Zuerst werden einige Daten definiert: die "zielhosts" sind alle hosts die im Inventory in der Gruppe "test-servers" sind. Der Benutzer für den Zugang ist "nahmed" und alle aktionen sollen dann als root ausgeführt werden (become: true). Danach wird eine Variable definiert, und dann folgen die Tasks und handlers (Ein handler ist ein task, der nur dann ausgeführt wird, wenn er von  irgend einem anderen Task ein "notify" erhalten hat).

Der erste Task stellt sicher, dass das httpd paket in der neuesten Verion installiert ist.
Der zweite Task kopiert eine Datei, die im gleichen Verzeichnis wie das playbook liegt, an eine bestimmte Stelle auf allen betroffenen Servern.
Der dritte Task stellt sicher, dass der httpd-dienst beim boot aktiv ist, und schickt ein notify an den einzigen handler in diesem playbook.
Der handler stellt dann zuletzt sicher, dass der httpd-dienst neu gestartet wird.

### ...das inventory?
Ansible benötigt ein "inventory". Das ist im allereinfachsten Fall eine Textdatei, in der Zeile für Zeile die hostnamen aller Systeme aufgelistet sind, mit denen man arbeiten will, aso z.B. so:
```
server1.local.net
server2.local.net
dbserver1.local.net
dbserver2.local.net
...
```

### Und wo liegt das Inventory? oder: die Datei ansible.cfg
Daneben gibt es noch die Datei ansible.cfg, in der (unter Anderem) festgelegt wird, wo genau das Inventory zu finden ist.
Jedesmal wenn ich ansible aufrufe, wird an mehreren Stellen nach so einer Datei `ansible.cfg` gesucht.
1. in `/etc/ansible/ansible.cfg`
2. in `~/.ansible.cfg`
3. in `./ansible.cfg`

Das heisst also: in /etc kann ich (als Administrator) globale Vorgaben für Ansible machen. Als User mache ich die Vorgaben für mich alleine in `~/.ansible.cfg` festlegen. und dann gibt es zu jedem meiner Ansible-projekte die Möglichkeit eine lokale Datei `ansible.cfg` anzulegen.

Ein Beispiel für eine ~/.ansible.cfg:
```
[defaults]
inventory = /home/mathias/.ansible/inventory/
remote_user = ansible-remote
private_key_file = /home/mathias/.ansible/id_rsa_ansible
```

Was man hier sieht, bedeutet:
* es gibt ein default inventory im ordner /home/mathias/.ansible/inventory/ (es werden einfach alle Dateien in dem Ordner der Reihe nach als Inventory-Dateien eingelesen)
* Der Benutzer, als der Ansible sich per ssh an den Zielsystemen anmeldet, heisst `ansible-remote`
* Der ssh-key für den Zugang liegt in `/home/mathias/.ansible/id_rsa_ansible`

### Vorbereitungen für Ansible:

Aus dem bis hier gesagten ergeben sich folgende Arbeiten, um einen (neuen) REchner für Remote-Administration mit Ansible einzurichten:

1. den Remote-User anlegen
2. den Remote-User für `sudo` freischalten
3. den für Ansible verwendeten ssh-key im Benutzeraccount des ansible-remote-users eintragen.

Und das kann man dann auch schon mit ansible machen:

```
---
- name: create the remote user for ansible and awx
  hosts: all

  tasks:

  - name: create ansible user
    user:
      name:         ansible-remote
      system:       yes
      state:        present
      password:     "{{ upassword | password_hash('sha512') }}"
      create_home:  yes
      expires:      -1

  - name: install ssh authorized key for ansible-remote account
    authorized_key:
      comment: ansible-remote key for ansible and awx
      exclusive: true
      key: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOyicC4KQN3yxW7qI5fC1wLra05vCJNjcPhv5b9unPZxyIpageykqWeShpNYL4P8zos3pYkrF5U23ENwXTOIC/YTIOJSrOcPhoT5v4mzRITc8b5yrRgtoi7op0IiO4grtK68jRyljgzU2x8ALlaK1RgfVDf8haXpZpc/h9mKq6dktfOunawtvV8lwxO4XsExvWCe+nBLybWXU3rTYEdpoSZOIhTReX7iHSufixuqHqIsuf16iapGb/5zm0OCjR4+cfMXKpIlrLGtzQvyjlE5iBEeUIWuEx8L6vrBUhS+Ut3bwgEJA6ycQNsuhbz+CW/rnot+yi18F+B6H4a9rRUijD new ssh key for ansible-remote for ansible and awx"
      state: present
      user: ansible-remote

  - name: comment out "targetpw" in sudoers
    replace:
      path: /etc/sudoers
      regexp: '(^Defaults targetpw)'
      replace: '## \1'
      validate: /usr/sbin/visudo -cf %s

  - name: comment out blanket ALL ALL in sudoers
    replace:
      path: /etc/sudoers
      regexp: '(^ALL.*$)'
      replace: '## \1'
      validate: /usr/sbin/visudo -cf %s

  - name: install sudo rule for ansible-remote user
    copy:
      dest: /etc/sudoers.d/ansible-remote
      content: "ansible-remote ALL=(ALL) ALL"
      mode: 0640
      group: root
      owner: root
      validate: /usr/sbin/visudo -cf %s
```

Aufgerufen wird dieses playbook dann so:
`ansible-playbook -u root -l zielhost -e upassword=dideldum  ansibleuser.yml`.
Damit wird der remote-benutzer angelegt, und als passwort das mit "upassword=" übergebene Passwort eingetragen.

Mit den bis hier erfolgten Ausführungen sollte jeder in der Lage sein, dieses Play zu lesen und zu verstehen.

## Versionsverwaltung mit git

### Was ist git
(versionskontrollsystem - github.org - linux kernel - etc etc etc)

### Wie benutze ich git

change, stage, commit, push, repeat

### Lokal vs. Remote
git init
git clone
git pull
git remote add

## Datenbankadministration mit ansible am Beispiel von mysql auf Red Hat Linux

### Welche Ansible-Module braucht man
user
package
mysql
service
firewalld

### Welche Schritte müssen ausgeführt werden
user anlegen
pakete installieren
dienst aktivieren
firewall öffnen
datenbank initialisieren
dbuser anlegen
db für den dbuser anlegen

### Lösung