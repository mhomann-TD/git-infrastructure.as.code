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

## Idempotenz
Eine wichtige Voraussetzung hier ist die sogenannte **Idempotenz**.

Idempotenz bedeutet, dass ich einen Prozess beliebig oft wiederholen kann, und garantiert jedesmal das gleiche Ergebnis herauskommt.
Ein Beispiel aus der Welt der Zahlen:

`x=x+2` ist **nicht** idempotent - nach dem ersten Aufruf ist der Wert der Variablen 2, danach 4, dann 6, und so weiter.

`x=x*2` ist hingegen idempotent - egal wie oft man es ausführt, das Ergebnis ist **immer gleich**.

Um das ganze mal in die Welt der Systemadministration zu heben:

`mkdir /tmp/testdir` wird beim ersten Aufruf funktionieren, aber wenn das Verzeixchnis dann existiert, wird jeder weitere Aufruf zu einer Fehlermeldung führen - also **nicht** idempotent.

`test -d /tmp/testdir || mkdir /tmp/testdir` wird hingegen bei **jedem** Aufruf ordnungsgemäß funktionieren - also ist diese Form **idempotent**.