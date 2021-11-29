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

Eine wie auch immer geartete Versionsverwaltung sollte die folgenden Merkmale aufweisen:

* Jede Änderung wird mit einer Logmessage gespeichert
* Dateien können wieder auf frühere Versionen zurückgesetzt werden
* Die Unterschiede zwischen verschiedenen Versionen können übersichtlich dargestellt werden
* Bei jeder Änderung wird Uhrzeit, Datum, und der Accont der die Änderung gemacht hat gespeichert.
* Viele verschiedene Nutzer können gleichzeitig am gleichen Projekt arbeiten, wobei Konflikte die entstehen wenn mehrere Nutzer die gleiche Datei ändern abgefangen bzw. sauber zusammengeführt werden.
* Es gibt die Möglichkeit das Versionskontrollsystem über sog. `hooks` in den Workflow der Softwareentwicklung zu integrieren, so kann z.B. das Erstellen von neuen Containerimages automatisiert werden (gut zu sehen auf dockerhub für zahlende Accounts, oder auf quay.io)



### Was ist git
`git` ist eines der verbretitetesten Versionskontrollsysteme dieser Tage. Das kommt wahrscheinlich nicht zuletzt daher, dass einerseits der Linux-Kernel in einem GIT-repository gepflegt wird, und andererseits unter `https://github.com` ein großer öffentlicher GIT-server für jeden der es nutzen will zur Verfügung gestellt wird.

Git arbeitet mit bis zu vier versxchiedenen Arbeitsbereichen.
 * central repository
 * local repository
 * staging 
 * working tree

Das "central repository" liegt üblicherweise auf einem zentralen Server. Das kann der bereits erwähnte Dienst github.com sein, man kann aber auch sehr einfach im lokalen Netz einen eigenen zentralen git server aufsetzen, wie wir noch sehen werden. Dieses "central repository" bezeichnet man gerne als den **upstream** eines Projektes.

Das "local repository" ist die lokal ausgecheckte Kopie eines upstreams.

Innerhalb des "local repositories" gibt es zwei Bereiche: die "staging area" in die alle Änderungen eingetragen sind, die **noch nicht committed** sind, und den "working tree", d.H. die regulären Dateien im Dateisystem.

### Wie benutze ich git

Um mit git zu arbeiten, folge ich einem einfachen Zyklus:
**change, stage, commit, push, repeat**

Zuerst wird ein repository angelegt. Das geschieht entweder lokal oder auf einem zentralen server mit `git init`. Dabei werden auf einem zentralen server noch die parameter `--bare --shared=true` angegeben.

Alternativ dazu kann man auch ein bereits existierendes Repository von einem zentralen server kopieren ("clonen"): `git clone REPOURL`

Nun macht man Änderungen. Wenn man einen Zwischenstand im Repository ablegen will, fügt man die geänderten Dateien mit `git add DATEINAME` zum staging-Bereich hinzu (Dies gilt auch für neuangelegte Dateien).

Um den im staging abgelegten Stand ins Repository zu schreiben, verwendet man `git commit`, wobei die commit-message mit `-m "message"` gleich übergeben werden kann.

Zuletzt kann man alle im lokalen Repository abgelegten Änderungen mit `git push` ins zentrale Repository hochladen.

## Vorbereitende Aufgaben

### Die Lab-Umgebung

Für jeden Teilnehmer des Workshops stehen zwei separate VMs zur Verfügung, auf denen es einen Benutzer "student" mit dem Passwort "student" gibt. Die VMs haben für alle Teilnehmer die gleichen hostnamen, `server` und `workstation`. Auf der Workstation ist eine graphische Benutzeroberfläche eingerichtet, die ggf. erst an die Sprach- und Tastaturpräferenzen des Benutzers angepasst werden muss. Das Kontrollzentrum des verwendeten DE ist selbsterklärend.

### ssh key anlegen

Öffne eine Kommandozeile auf der Workstation-VM, und erzeuge einen ssh-key mit dem Befehl `ssh-add`:

```
[student@workstation ~]$ ssh-keygen -C "Student user für git and ansible workshop" 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/student/.ssh/id_rsa): 
Created directory '/home/student/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/student/.ssh/id_rsa
Your public key has been saved in /home/student/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:yd0MxzzCO1Gu5EhCyufgze1WXmCHpcxIvfqGFn2Emd4 Student user für git and ansible workshop
The key's randomart image is:
+---[RSA 3072]----+
|      . ..  o    |
|   . o . =.O     |
|    + o o &=B    |
|   . * = B=%..   |
|    . + S+Bo+    |
|       .ooooE    |
|        o+..     |
|       .o o      |
|       . .       |
+----[SHA256]-----+
```

### ssh key auf server und workstation kopieren
Diesen Key müssen wir nun auf server und workstation für die benutzer `root` und `student` freischalten.
Zuerst für den student:
```
[student@workstation ~]$ ssh-copy-id student@workstation
The authenticity of host 'workstation (fe80::5054:ff:fe80:d2dc%enp1s0)' can't be established.
ED25519 key fingerprint is SHA256:nlhHjxx85kikhzW6JilOG8hUOGktByu/Dwu3v2nmnyA.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 2 key(s) remain to be installed -- if you are prompted now it is to install the new keys
student@workstation's password: 

Number of key(s) added: 2

Now try logging into the machine, with:   "ssh 'student@workstation'"
and check to make sure that only the key(s) you wanted were added.

[student@workstation ~]$ ssh-copy-id student@server
The authenticity of host 'server (192.168.238.174)' can't be established.
ED25519 key fingerprint is SHA256:8BPQfyhV3O+YR2MrXcSp1+OfbDS+cprzns+zge5kpYc.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 2 key(s) remain to be installed -- if you are prompted now it is to install the new keys
student@server's password: 

Number of key(s) added: 2

Now try logging into the machine, with:   "ssh 'student@server'"
and check to make sure that only the key(s) you wanted were added.
```
Um den key auch für `root` freizuschalten, müssen wir uns auf dem betreffenden System erst einmal als student anmelden, und danach den bereits für `student` freigeschalteten key auch für root freischalten:
```
[student@workstation ~]$ sudo -i
[sudo] Passwort für student: 
[root@workstation ~]# mkdir -p ~root/.ssh
[root@workstation ~]# cat ~student/.ssh/authorized_keys >> ~root/.ssh/authorized_keys
[root@workstation ~]# 
Abgemeldet
[student@workstation ~]$ ssh root@workstation
Last login: Mon Nov 29 03:44:45 2021 from fe80::5054:ff:fe80:d2dc%enp1s0
[root@workstation ~]# 
Abgemeldet
Connection to workstation closed.
```

Und noch mal das gleiche auf dem `server`:
```
[student@workstation ~]$ ssh student@server
Last login: Mon Nov 29 03:53:19 2021 from 192.168.238.175
[student@server ~]$ sudo -i
[sudo] Passwort für student: 
[root@server ~]# mkdir -p ~root/.ssh
[root@server ~]# cat ~student/.ssh/authorized_keys >> ~root/.ssh/authorized_keys
[root@server ~]# 
Abgemeldet
[student@server ~]$ 
Abgemeldet
Connection to server closed.
[student@workstation ~]$ ssh root@server
Last login: Mon Nov 29 03:50:26 2021 from 192.168.238.175
[root@server ~]# 
Abgemeldet
Connection to server closed.
```

### git repo auf server anlegen
Jetzt können wir auf dem server als der student-user ein gemeinsam genutztes git repository anlegen:
```
[student@workstation ~]$ ssh student@server
Last login: Mon Nov 29 03:53:22 2021 from 192.168.238.175
[student@server ~]$ mkdir ansible-mysql
[student@server ~]$ cd ansible-mysql/
[student@server ansible-mysql]$ git init --bare --shared=true .
Hinweis: Als Name für den initialen Branch wurde 'master' benutzt. Dieser
Hinweis: Standard-Branchname kann sich ändern. Um den Namen des initialen Branches
Hinweis: zu konfigurieren, der in allen neuen Repositories verwendet werden soll und
Hinweis: um diese Warnung zu unterdrücken, führen Sie aus:
Hinweis: 
Hinweis:        git config --global init.defaultBranch <Name>
Hinweis: 
Hinweis: Häufig gewählte Namen statt 'master' sind 'main', 'trunk' und
Hinweis: 'development'. Der gerade erstellte Branch kann mit diesem Befehl
Hinweis: umbenannt werden:
Hinweis: 
Hinweis:        git branch -m <Name>
Leeres verteiltes Git-Repository in /home/student/ansible-mysql/ initialisiert
[student@server ansible-mysql]$ 
Abgemeldet
Connection to server closed.
```

### git repo clonen
Dieses repository clonen wir auf die Workstation:
```
[student@workstation ~]$ git clone git+ssh://student@server/home/student/ansible-mysql
Klone nach 'ansible-mysql' ...
warning: Sie scheinen ein leeres Repository geklont zu haben.
[student@workstation ~]$ cd ansible-mysql/
[student@workstation ansible-mysql]$ ls -la
insgesamt 4
drwxr-xr-x.  3 student student   18 29. Nov 03:57 .
drwx------. 16 student student 4096 29. Nov 03:57 ..
drwxr-xr-x.  7 student student  119 29. Nov 03:57 .git
```

### ansible.cfg und inventory anlegen
Jetzt können wir eine Konfigurationsdatei und ein Inventory für ansible anlegen:

```
[student@workstation ~]$ cd ~/ansible-mysql/
[student@workstation ansible-mysql]$ vim ansible.cfg
[student@workstation ansible-mysql]$ cat ansible.cfg 
[defaults]
inventory = ./inventory/
remote-user = student

[privilege_escalation]
become = False
become_method = sudo
become_user = root
become_ask_pass = False

```
```
[student@workstation ansible-mysql]$ mkdir ./inventory/
[student@workstation ansible-mysql]$ vim ./inventory/000-hosts
[student@workstation ansible-mysql]$ cat ./inventory/000-hosts 
server
workstation
```
### ein erster Test
Um zu testen ob das alles in Ordnung ist, können wir ein ansible "ad hoc"-Kommando verwenden, aber erst mal muss ansible überhaupt installiert werden:

```
[student@workstation ansible-mysql]$ sudo dnf install ansible
[sudo] Passwort für student: 
Letzte Prüfung auf abgelaufene Metadaten: vor 0:14:40 am Mo 29 Nov 2021 03:48:07 EST.
Abhängigkeiten sind aufgelöst.
=============================================================================================================================================
 Package                                   Architecture               Version                              Repository                   Size
=============================================================================================================================================
Installieren:
 ansible                                   noarch                     2.9.27-1.fc35                        updates                      15 M
Abhängigkeiten werden installiert:
 python3-babel                             noarch                     2.9.1-4.fc35                         fedora                      5.8 M
 python3-bcrypt                            x86_64                     3.2.0-1.fc35                         fedora                       43 k
 python3-cryptography                      x86_64                     3.4.7-5.fc35                         fedora                      695 k
 python3-jinja2                            noarch                     3.0.1-2.fc35                         fedora                      529 k
 python3-jmespath                          noarch                     0.10.0-4.fc35                        fedora                       46 k
 python3-markupsafe                        x86_64                     2.0.0-2.fc35                         fedora                       27 k
 python3-ntlm-auth                         noarch                     1.5.0-4.fc35                         fedora                       53 k
 python3-pynacl                            x86_64                     1.4.0-4.fc35                         fedora                      108 k
 python3-pytz                              noarch                     2021.3-1.fc35                        updates                      47 k
 python3-requests_ntlm                     noarch                     1.1.0-16.fc35                        fedora                       18 k
 python3-xmltodict                         noarch                     0.12.0-13.fc35                       fedora                       22 k
 sshpass                                   x86_64                     1.09-2.fc35                          fedora                       27 k
Schwache Abhängigkeiten werden installiert:
 python3-paramiko                          noarch                     2.7.2-6.fc35                         fedora                      288 k
 python3-pyasn1                            noarch                     0.4.8-7.fc35                         fedora                      134 k
 python3-winrm                             noarch                     0.4.1-4.fc35                         fedora                       80 k

Transaktionsübersicht
=============================================================================================================================================
Installieren  16 Pakete

Gesamte Downloadgröße: 23 M
Installationsgröße: 133 M
Ist dies in Ordnung? [j/N]: j
```

Hier mit "j" antworten und ein bisserl abwarten.

Jetzt kann  getestet werden:
```
[student@workstation ansible-mysql]$ ansible --list-hosts all
  hosts (2):
    server
    workstation
[student@workstation ansible-mysql]$ ansible -m ping server
server | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```
### ansible.cfg und inventory ins repo pushen
Unsere Konfigurationsdatei und das Inventory scheinen ja in Ordnung zu sein, also ab in's Repository damit, aber dafür muss git erst mal für die Logeinträge wissen wer wir sind:
```
[student@workstation ansible-mysql]$ git config --global user.email mhomann@redhat.com
[student@workstation ansible-mysql]$ git config --global user.name "Mathias Homann"

```
Hier setzt man natürlich den eigenen Namen ein, und die passende Email-Adresse. Wenn man das `--global` weglässt, gilt diese Information nur für die lokale repo-kopie in der man gerade arbeitet.

Jetzt können wir unsere Änderungen speichern:
```
[student@workstation ansible-mysql]$ git status
Auf Branch master

Noch keine Commits

Unversionierte Dateien:
  (benutzen Sie "git add <Datei>...", um die Änderungen zum Commit vorzumerken)
        ansible.cfg
        inventory/

nichts zum Commit vorgemerkt, aber es gibt unversionierte Dateien
(benutzen Sie "git add" zum Versionieren)
[student@workstation ansible-mysql]$ git add ansible.cfg 
[student@workstation ansible-mysql]$ git commit -m "ansible configuration file"
[master (Root-Commit) 0688255] ansible configuration file
 1 file changed, 10 insertions(+)
 create mode 100644 ansible.cfg
[student@workstation ansible-mysql]$ git add inventory/
[student@workstation ansible-mysql]$ git commit -m "ansible inventory"
[master 29c7e81] ansible inventory
 1 file changed, 3 insertions(+)
 create mode 100644 inventory/000-hosts
[student@workstation ansible-mysql]$ git push
Objekte aufzählen: 7, fertig.
Zähle Objekte: 100% (7/7), fertig.
Delta-Kompression verwendet bis zu 2 Threads.
Komprimiere Objekte: 100% (4/4), fertig.
Schreibe Objekte: 100% (7/7), 658 Bytes | 658.00 KiB/s, fertig.
Gesamt 7 (Delta 0), Wiederverwendet 0 (Delta 0), Pack wiederverwendet 0
To git+ssh://server/home/student/ansible-mysql
 * [new branch]      master -> master
[student@workstation ansible-mysql]$ git log
commit 29c7e81c23d582ee7ad8fe0a5665dfe793681907 (HEAD -> master, origin/master)
Author: Mathias Homann <mhomann@redhat.com>
Date:   Mon Nov 29 04:15:26 2021 -0500

    ansible inventory

commit 06882552e8bfd56e4e3228dec0bc7131c7dbd6c5
Author: Mathias Homann <mhomann@redhat.com>
Date:   Mon Nov 29 04:15:08 2021 -0500

    ansible configuration file
[student@workstation ansible-mysql]$
```

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