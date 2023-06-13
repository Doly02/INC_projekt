# INC_projekt
Projekt do INC, navrh UART vysilace 

Vycházíme ze základních informací o fungování a zpracování asynchronní sériové komunikace. Uvažuje se vstupní tok dat v pevném formátu: 
jeden START bit, 8 bitů dat, jeden STOP bit, zasílaných rychlostí 9600 baudů za sekundu. Přijímací obvod zpracovává na 16x vyšší frekvenci (signál CLK) ve srovnání 
s přenosovou rychlostí jednotlivých datových bitů. Úkolem je snímat datové bity uprostřed přenášeného intervalu.

Obvod UART_RX přijímá jednotlivé bity na vstupním datovém portu DIN, provede jejich de-serializaci a výsledné 8-bitové slovo zapíše na datový port DOUT. 
Platnost datového slova na portu DOUT se potvrzuje nastavením příznaku DOUT_VLD na úroveň logické 1 po dobu jednoho taktu hodinového signálu CLK. 

HODNOCENÍ PROJEKTU: 20/20

Projekt není určen ke kopírování.
