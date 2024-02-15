'BG-CORE.BAS
'Funktionsbibliothek für Backgammon

DEFINT A-Z
DECLARE SUB SpielerWechseln ()
DECLARE SUB bewegeStein (von%, nach%)
DECLARE FUNCTION bewegungMoeglich (von%, nach%)
DECLARE SUB zeigeSpielbrett ()
DECLARE SUB initSpiel ()

CONST TRUE = -1, FALSE = NOT TRUE
CONST WEISS = 1, SCHWARZ = 2

TYPE TZunge
   schwarze AS INTEGER
   weisse AS INTEGER
   nummer AS INTEGER
END TYPE

TYPE TSpieler
   nickname AS STRING * 12
   farbe AS INTEGER 'kann WEISS oder SCHWARZ sein
   ziel AS INTEGER
   bar AS INTEGER
END TYPE

DIM SHARED wuerfel(4) AS INTEGER 'zwei Würfel gibt es in der Regel, aber beim Pasch gibt es sozusagen vier.
DIM SHARED zungen(24) AS TZunge
DIM SHARED spieler(2) AS TSpieler
DIM SHARED aktuellerSpieler AS INTEGER
DIM SHARED infoText$


spieler(WEISS).nickname = "Thomas"
spieler(SCHWARZ).nickname = "Teddy"
initSpiel

        DO
                COLOR 7, 1
                CLS
                zeigeSpielbrett

                COLOR 7, 1
                LOCATE 14, 1: PRINT "1) Spieler wechseln"
                LOCATE 15, 1: PRINT "2) Einen Stein bewegen"
                LOCATE 16, 1: PRINT "3) Spiel neu starten"
                LOCATE 17, 1: PRINT "4) Würfel rollen"
                LOCATE 18, 1: PRINT "5) Würfel setzen"
                LOCATE 19, 1: PRINT "6) Ermittle Gewinner"
                LOCATE 20, 1: PRINT "7) Alle im Heimfeld?"
                LOCATE 21, 1: PRINT "0) Ende"
                INPUT "Aktion: ", aktion%

                SELECT CASE aktion%
                        CASE 1: SpielerWechseln
                        CASE 2:
                        INPUT "Von: "; von%
                        INPUT "Nach: "; nach%
                        IF bewegungMoeglich(von%, nach%) = TRUE THEN
                                PRINT infoText$
                                bewegeStein von%, nach%
                        ELSE
                                PRINT infoText$
                                PRINT "Bewegung nicht m”glich."
                                INPUT "Taste", taste$
                        END IF
                        CASE 3: initSpiel
                        case 4: wuerfeln FALSE, FALSE
                        case 5:
                        input "Würfel 1: ", w1%
                        input "Würfel 2: ", w2%
                        wuerfeln w1%, w2%
                        case 6:
                        Print "Ermittle Gewinner (1, 2, 0=keiner): "; ermittleGewinner
                        INPUT "Taste", taste$
                        case 7:
                        INPUT "Ermittle, ob alle Steine im Heimfeld von Spieler: ", s%
                        aih% = alleImHeimfeld(s%)
                        if aih% = TRUE THEN
                            PRINT "Alle Steine im Heimfeld."
                        ELSE
                            PRINT "Es sind nicht alle Steine im Heimfeld."
                        END IF
                        INPUT "Taste", taste$


                        CASE 0: 'Loop verlassen
                END SELECT

        LOOP UNTIL aktion% = 0


END

DEFINT A-Z
SUB bewegeStein (von%, nach%)

        IF aktuellerSpieler = WEISS THEN
                IF zungen(nach%).schwarze = 1 THEN 'Schwarzer Stein wird gecschlagen
                        zungen(nach%).schwarze = 0
                        spieler(SCHWARZ).bar = spieler(SCHWARZ).bar + 1
                END IF
                zungen(von%).weisse = zungen(von%).weisse - 1
                zungen(nach%).weisse = zungen(nach%).weisse + 1

        ELSE
                IF zungen(nach%).weisse = 1 THEN 'Weiáer Stein wird geschlagen
                        zungen(nach%).weisse = 0
                        spieler(WEISS).bar = spieler(WEISS).bar + 1
                END IF
                zungen(von%).schwarze = zungen(von%).schwarze - 1
                zungen(nach%).schwarze = zungen(nach%).schwarze + 1
        END IF

END SUB

DEFINT A-Z
FUNCTION bewegungMoeglich (von%, nach%)

        IF von% < 1 OR von% > 24 THEN infoText$ = "falscher Parameter von%: " + STR$(von%): bewegungMoeglich = FALSE: EXIT FUNCTION
        IF nach% < 1 OR nach% > 24 THEN infoText$ = "falscher Parameter nach%: " + STR$(nach%): bewegungMoeglich = FALSE: EXIT FUNCTION

        IF aktuellerSpieler = WEISS THEN
                IF von% > nach% THEN infoText$ = "Der Spieler darf nur nach vorne ziehen": bewegunMoeglich = FALSE: EXIT FUNCTION
                IF zungen(von%).weisse = 0 THEN infoText$ = "Auf dem von-Feld befindet sich kein Stein von diesem Spieler": bewegungMoeglich = FALSE: EXIT FUNCTION
                IF zungen(nach%).schwarze > 1 THEN infoText$ = "Das Ziel ist vom anderen Spieler besetzt": bewegungMoeglich = FALSE: EXIT FUNCTION


        ELSE
                IF von% < nach% THEN infoText$ = "Der Spieler darf nur nach hinten ziehen":  bewegungMoeglich = FALSE: EXIT FUNCTION
                IF zungen(von%).schwarze = 0 THEN infoText$ = "Auf dem von-Feld befindet sich kein Stein von diesem Spieler":  bewegungMoeglich = FALSE: EXIT FUNCTION
                IF zungen(nach%).weisse > 1 THEN infoText$ = "Das Ziel ist vom anderen Spieler besetzt":  bewegungMoeglich = FALSE: EXIT FUNCTION

        END IF


        bewegungMoeglich = TRUE
        infoText$ = "Zug kann ausgefhrt werden"

END FUNCTION

DEFINT A-Z
SUB initSpiel

        'Alle Werte der Zungen zurcksetzen
        FOR i% = 1 TO 24
                zungen(i%).schwarze = 0
                zungen(i%).weisse = 0
                zungen(i%).nummer = i%
        NEXT

        'Startformation aufstellen
        zungen(1).weisse = 2
        zungen(6).schwarze = 5
        zungen(8).schwarze = 3
        zungen(12).weisse = 5
        zungen(13).schwarze = 5
        zungen(17).weisse = 3
        zungen(19).weisse = 5
        zungen(24).schwarze = 2

        'Spielerwerte zurcksetzen
        spieler(1).ziel = 0
        spieler(1).bar = 0
        spieler(2).ziel = 0
        spieler(2).bar = 0
        aktuellerSpieler = 1

END SUB

SUB SpielerWechseln

        IF aktuellerSpieler = WEISS THEN
                aktuellerSpieler = SCHWARZ
        ELSE
                aktuellerSpieler = WEISS
        END IF

END SUB

SUB zeigeSpielbrett

        FOR i% = 1 TO 24
                COLOR 7, 1
                LOCATE 8, 3 * i%
                PRINT i%;

                LOCATE 7, 3 * i%
                IF zungen(i%).weisse > zungen(i%).schwarze THEN
                        COLOR 15, 14
                        PRINT zungen(i%).weisse;
                ELSE
                        IF zungen(i%).schwarze > zungen(i%).weisse THEN
                                COLOR 0, 14
                                PRINT zungen(i%).schwarze;
                        END IF
                END IF

        NEXT


        COLOR 15, 1

        LOCATE 1, 1: PRINT spieler(1).nickname;
        COLOR 7, 1
        LOCATE 2, 1: PRINT "Bar:  "; spieler(1).bar;
        LOCATE 3, 1: PRINT "Ziel: "; spieler(1).ziel;
        IF aktuellerSpieler = 1 THEN LOCATE 4, 1: PRINT "Du bist am Zug!"

        COLOR 0, 1
        LOCATE 1, 80 - LEN(spieler(2).nickname)
        PRINT spieler(2).nickname;

        COLOR 7, 1
        LOCATE 2, 68: PRINT "Bar:  "; spieler(1).bar;
        LOCATE 3, 68: PRINT "Ziel: "; spieler(1).ziel;
        IF aktuellerSpieler = 2 THEN LOCATE 4, 65: PRINT "Du bist am Zug!"

        COLOR 7, 1
        LOCATE 1, 37: PRINT "Würfel"
        LOCATE 2, 37: PRINT "W1: "; wuerfel(1)
        LOCATE 3, 37: PRINT "W2: "; wuerfel(2)
        IF wuerfel(3) > 0 AND wuerfel(4) > 0 THEN
            LOCATE 4, 37: PRINT "W3: "; wuerfel(3)
            LOCATE 5, 37: PRINT "W4: "; wuerfel(4)
        END IF



END SUB

DEFINT A-Z
SUB wuerfeln(w1%, w2%)

    IF w1% = FALSE and w2% = FALSE THEN
        w1% = INT(RND * 6) + 1
        w2% = INT(RND * 6) + 1
    END IF

    wuerfel(1) = w1%
    wuerfel(2) = w2%
    'Bei einem PASCH DIE Würfel verdoppeln.
    'Inaktive Würfel sind auf FALSE gesetzt
    if w1% = w2% THEN
        wuerfel(3) = w1%
        wuerfel(4) = w1%
    ELSE
        wuerfel(3) = FALSE
        wuerfel(4) = FALSE
    END IF

END SUB

DEFINT A-Z
FUNCTION ermittleGewinner()

    IF SPIELER(WEISS).ziel = 15 THEN
        ermittleGewinner = WEISSE
        EXIT FUNCTION
    ELSE
        IF SPIELER(SCHWARZ).ziel = 15 THEN
            ermittleGewinner = SCHWARZE
            EXIT FUNCTION
        END IF
    END IF

    ermittleGewinner = FALSE

END FUNCTION

DEFINT A-Z
FUNCTION alleImHeimfeld(s%)
    IF SPIELER(s%).bar > 0 THEN infoText$ = "Der Spieler hat noch Steine auf der Bar.": alleImHeimfeld = FALSE: EXIT FUNCTION

    IF s% = WEISS THEN
        FOR i% = 1 TO 18
            IF zungen(i%).weisse > 0 THEN infoText$ = "Es sind noch Steine ausserhalb des Heimfelds.": alleImHeimfeld = FALSE: EXIT FUNCTION
        NEXT
    ELSE
        FOR i% = 7 TO 24
            IF zungen(i%).schwarze > 0 THEN infoText$ = "Es sind noch Steine ausserhalb des Heimfelds.": alleImHeimfeld = FALSE: EXIT FUNCTION
        NEXT
    END IF

    alleImHeimfeld = TRUE

END FUNCTION
