###Высокоуровневая схема модулей генератора:  
![alt text](https://github.com/padung99/Metrotek_LAB4/blob/main/gen_eth_pkt/eth_pkt_gen.png)

###Статичные параметры модуля генератора:  
+ Скорость генерации ( От 0 до 1Gb/s на уровне L1 ).
+ Длительность ( в количестве пакетов / в секундах ).
+ Режим работы ( 1000 Mbps full duplex ).

###Структура и работа генератора:  
Avalon-mm register file:
- Данные в этом Register file являются настройками генератора, они будут получены по интерфейсу Avalon-mm, эти данные могут быть:
+ Общее количество пакетов, которые необходимо передать.
+ Инкрементный или случайный тип данных.
+ MAC-адрес приемника и передатчика.
+ Случайное начальное число ( Random seed ) для блока PRBS.
+ Размер кадров.

- Ethernet packet generation: этот блок генерирует рандомизированные ethernet данных ( Payload ) с помощью алгоритма PSBS.  
---> После того, как Payload генерирован, модуль соединит каждую часть ethernet кадра вместе по стандарту IEEE 802.3  

Структура одной ethernet кадры:  
![alt text](https://github.com/padung99/Metrotek_LAB4/blob/main/gen_eth_pkt/ethernet_frame.png)

*Preamble&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[7 bytes]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: Последовательность бит, определяющая начало фрейма. Каждый байт преамбулы равен следующей &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;последовательности битов: 10101010  
*SFD&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[1 byte ]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: Признак начала кадра. Равен следующей последовательности битов: 10101011  
*Destination address&nbsp;[6 bytes]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: MAC-адрес приемника ( получен по интерфейсу Avalon-mm, хранется в Avalon-MM register file )  
*Source address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[6 bytes]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: MAC-адрес передатчика ( получен по интерфейсу Avalon-mm, хранется в Avalon-MM register file )  
*length&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[2 bytes]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: Размер кадров  
*Payload&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[46-1500 bytes]: Данные, генерированы блоком "Ethernet packet generation"  
*CRC&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4 bytes]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: Контрольная сумма, генерирована блоком "CRC generator"  

---> Так как у одного кадра очень большой объем (больше 1500 байтов), мы не можем передать все пакеты за 1 раз, это следует, что кадры, генерированы в блоке "Ethernet packet generation" разделяются на маленькие пакеты. Эти маленькие пакеты подаются в блок "CRC generator" и блок "Shift register" одновременно.

- CRC generator: Этот блок генерирует контрольную сумму с помощью алгоритма CRC для того, чтобы эти пакеты правильно получаются на стророне TSE.
- Shift register: этот блок преобразует параллельные данные, которые получены с блока "Ethernet packet generation" на последовательные пакеты.
---> Выход этих обоих блоков ( CRC generator и Shift register ) является последовательные пакеты с добавлением контрольной суммы в конце пакетов, например:

Выходные данные блока "Ethernet packet generation": 0xA4 0x58 0x36 0x16 0x04 0x99 0xE4 ..... 0xBA ( параллельные )  
---> контрольная сумма этого пакета:  0x74 ( генерируется в блоке "CRC generator" )  
Выходные данные обоих блоков ( CRC generator и Shift register ) будут в формате: [Пакет] [контрольная сумма]:  
[0xA4 0x58 0x36 0x16 0x04 0x99 0xE4 ..... 0xBA] [&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0x74&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;]&nbsp;&nbsp;&nbsp;&nbsp;( последовательные )  
[-----------------------Пакет---------------------] [ Контрольная сумма ]  

- После добавления котрольной суммы в конце последовательного пакета, пакет будет передан на выход генератора по интерфейсу Avalon-ST, этот пакет будет получен модулем TSE
