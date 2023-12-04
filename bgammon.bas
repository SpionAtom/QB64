'Backgammon von SpionAtom November 2o23

'QB64 Magic, um kein so kleines Fenster zu haben
$Resize:Stretch
DEFINT A-Z
const xr = 320, yr = 200, screenMode = 7


'Layout fuer das Spielbret
    Type GameBoard
        x as Integer
        y as Integer
        w as integer
        h as integer
        pointWidth as Double
        pieceRadius as Double
        colorPoint1 as Integer
        colorPoint2 as Integer
        colorBorder as Integer
        colorSelection as Integer
        colorP1a as Integer
        colorP1b as Integer
        colorP2a as Integer
        colorP2b as Integer
    End Type
    Dim Shared Board As GameBoard
    Board.x = 0
    Board.y = 20
    Board.w = xr - 124
    Board.h = yr - 2 * Board.y
    Board.pointWidth = Board.w / 15.
    Board.pieceRadius = Board.w / 30. - 2
    Board.colorPoint1 = 4
    Board.colorPoint2 = 12
    Board.colorBorder = 12
    Board.colorSelection = 14
    Board.colorP1a = 7
    Board.colorP1b = 15
    Board.colorP2a = 8
    Board.colorP2b = 0

'Layout fuer die Points (= die gezackten Spielfelder)
    Type BoardPoint
        number as string * 2
        p as Integer
        p1pieces as Integer
        p2pieces as Integer
        x as Integer 'Position
        y as Integer
        w as Integer 'Dimension
        h as Integer
        d as Integer 'Direction: 1 means pointing down, -1 means pointing up
        c as Integer 'color
    End Type
    Dim shared points(25) as BoardPoint

'Initialisiere die Points
    For i = 1 to 24
        points(i).number = str$(i)
        If i < 10 then points(i).number = "0" + str$(i)
        points(i).p1pieces = 0
        points(i).p2pieces = 0
    next

    for i = 0 to 5
        points(12 + i + 1).x = Board.x + (i + 1) * Board.pointWidth + Board.pointWidth / 2
        points(12 + i + 1).y = Board.y
        points(12 + i + 1).d = 1
        points(12 + i + 1).w = Board.pointWidth
        points(12 + i + 1).h = Board.h * 0.4
        points(18 + i + 1).x = Board.x + (i + 8) * Board.pointWidth + Board.pointWidth / 2
        points(18 + i + 1).y = Board.y
        points(18 + i + 1).d = 1
        points(18 + i + 1).w = Board.pointWidth
        points(18 + i + 1).h = Board.h * 0.4
        If i Mod 2 = 0 Then points(12 + i + 1).c = Board.colorPoint1 Else points(12 + i + 1).c = Board.colorPoint2
        If i Mod 2 = 0 Then points(18 + i + 1).c = Board.colorPoint2 Else points(18 + i + 1).c = Board.colorPoint1

        points(12 - i).x     = Board.x + (i + 1) * Board.pointWidth + Board.pointWidth / 2
        points(12 - i).y     = Board.y + Board.h - 1
        points(12 - i).d     = -1
        points(12 - i).w     = Board.pointWidth
        points(12 - i).h     = Board.h * 0.4
        points(6 - i).x      = Board.x + (i + 8) *Board.pointWidth + Board.pointWidth / 2
        points(6 - i).y      = Board.y + Board.h - 1
        points(6 - i).d      = -1
        points(6 - i).w      = Board.pointWidth
        points(6 - i).h      = Board.h * 0.4
        If i Mod 2 = 1 Then points(12 - i).c = Board.colorPoint1 Else points(12 - i).c = Board.colorPoint2
        If i Mod 2 = 1 Then points(6 - i).c = Board.colorPoint2 Else points(6 - i).c = Board.colorPoint1
    next



screen screenMode, ,  1, 0



    'Images fuer Pieces
    r = Board.pieceRadius
    Dim shared imgPieceM(45), imgPiece1(45), imgPiece2(45)

    'Maske
    cls
    line (0, 0)-(2 * r, 2 * r), 15, bf
    Circle (r, r), r, 0
    Paint step(0, 0), 0, 0
    get (0, 0)-(2 * r, 2 * r), imgPieceM
    cls 'Pieces vom 1. Spieler
    Circle (r, r), r, Board.colorP1a
    Paint step(0, 0), Board.colorP1b, Board.colorP1a
    get (0, 0)-(2 * r, 2 * r), imgPiece1
    cls 'Piecesvom 2. Spieler
    Circle (r, r), r, Board.colorP2a
    Paint step(0, 0), Board.colorP2b, Board.colorP2a
    get (0, 0)-(2 * r, 2 * r), imgPiece2


    resetBoard
    selectedPoint = 8
    dim shared gameState, menue, keypressed$
    gameState = 0: menue = 0

    Do
        keypressed$ = inkey$

        cls
        drawBoard
        drawPieces
        drawSelectedPoint selectedPoint
        drawMenue

        Wait &H3DA, 8
        pcopy 1, 0



    Loop while keypressed$ <> chr$(27)
end

Sub drawMenue()

    select case gameState
        case 0 'Hauptmenue
            if keypressed$ = CHR$(0) + "H" then menue = (5 + menue - 1) mod 5
            if keypressed$ = CHR$(0) + "P" then menue = (5 + menue + 1) mod 5
            color 15
            CenterMenue 2, "Hauptmenue"
            if menue = 0 then color 14 else color 7
            CenterMenue 5, "Spielstart"
            if menue = 1 then color 14 else color 7
            CenterMenue 7, "Konfiguration"
            if menue = 2 then color 14 else color 7
            CenterMenue 9, "Brett editieren"
            if menue = 3 then color 14 else color 7
            CenterMenue 11, "Hilfe"
            if menue = 4 then color 14 else color 7
            CenterMenue 13, "Beenden"

        case else
    end select

End Sub


Sub CenterMenue(row, txt$)

    locate row, 26 + (15 - len(txt$)) / 2
    print txt$;

End Sub

Sub drawPieces()

    r = Board.pieceRadius
    For i = 1 To 24
        stack = 0
        If points(i).p1pieces > 0 Then
            stack = points(i).p1pieces
        else
            stack = points(i).p2pieces
        End if

        y = points(i).y + (Board.pieceRadius) * points(i).d
        If stack > 0 Then
            For s = 0 To stack - 1
                if points(i).p1pieces > 0 then Put (points(i).x-r, y-r), imgPieceM, and: Put (points(i).x-r, y-r), imgPiece1, xor
                if points(i).p2pieces > 0 then Put (points(i).x-r, y-r), imgPieceM, and: Put (points(i).x-r, y-r), imgPiece2, xor
                y = y + points(i).d * (2 * (Board.pieceRadius) + 1) ';+ points(i).d
            Next
        End If
    Next

End Sub

Sub resetBoard()
    'Spielsteine auf Anfangsposition setzen

    For i = 1 To 24
        points(i).p1pieces = 0
        points(i).p2pieces = 0
    Next

    points(1).p2pieces = 2
    points(6).p1pieces = 5
    points(8).p1pieces = 3
    points(12).p2pieces = 5
    points(13).p1pieces = 5
    points(16).p2pieces = 3
    points(18).p2pieces = 5
    points(24).p1pieces = 2

End SUb

Sub DrawBoard()

    'Points
    For i = 1 to 24
        drawPoint points(i)
    Next

    'Rahmen
    Rect Board.x, Board.y, Board.w, Board.h, Board.colorBorder
    Rect Board.x + 0 * Board.pointWidth, Board.y, Board.pointWidth, Board.h, Board.colorBorder  'left bar
    Rect Board.x + 7 * Board.pointWidth, Board.y, Board.pointWidth, Board.h, Board.colorBorder   'mid bar
    Rect Board.x + 14 * Board.pointWidth, Board.y, Board.pointWidth, Board.h, Board.colorBorder 'right bar

End SUb

Sub drawSelectedPoint(s)
    If s = 0 Then Exit Sub

    Color Board.colorSelection
    If s <= 12 Then 'Selektion unten
        For i = 0 To 4
            r = (i / 4.) * Board.pointWidth / 2
            Line (points(s).x - r, points(s).y + 2 + i) - (points(s).x + r, points(s).y + 2 + i)
        Next
    Else 'Selektion oben
        For i = 0 To 4
            r = (i / 4.) * Board.pointWidth / 2
            Line (points(s).x - r, points(s).y - 2 - i) - (points(s).x + r, points(s).y - 2 - i)
        Next
    End If

End Sub

Sub drawPoint(p as BoardPoint)

    Color  p.c

    If p.d = 1 Then 'Nach unten gezackt

        For i = 0 To p.h - 1
            r = (1 - (i) / p.h) * p.w / 2
            Line (p.x - r, p.y + i)-(p.x + r, p.y + i)
        Next


    Else
        If p.d = -1 Then 'Nach oben gezackt
        For i = 0 To p.h - 1
            r = (1 - (i) / p.h) * p.w / 2
            Line (p.x - r, p.y - i)-(p.x + r, p.y - i)
        Next
        End If
    End if

End Sub


Sub Rect(x, y, w, h, c)
    Line (x, y) - (x + w - 1, y + h - 1), c, B
End Sub
