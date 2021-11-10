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
  
* Puppet: Ein weiteres open source Konfigurationssystem. Auch puppet benötigt einen zentralen Server (den "Puppet master"). Wichtiges Merkmal: Die verschiedenen schritte in puppet-"scripten", den sogenannten NModulen, können, und werden, in beliebiger Reihenfolge ausgeführt werden. **Idempotenz** ist hier **lebenswichtig**.
  
* Ansible: Das dritte der verbreiteten Konfigurationssysteme. Ansible-Playbooks sind in YAML verfasst, einfach zu lesen, und werden (im Gegensatz zu Puppet) von oebn nach unten abgearbeitet, was den Umgang mit Ansible wesentlich einfacher macht. Ansible benötigt im Gegensatz zu Puppet und Saltstack **keinen** zentralen Server, esgibt aber eine zentralisiert einsetzbare Webapplikation, den "Ansible Tower", der ansible um RBAC (role based access controls), Logging, scheduling, u.v.m. erweitert.

Red Hat Linux unterstützt Puppet und Ansible, wir werden uns im Weiteren mit Ansible befassen.
