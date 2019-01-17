--- LEAGUE UTILS------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE league_utils AS
    
    PROCEDURE update_league_data(teamId IN NUMBER, newScoredGoals IN NUMBER, newLostGoals IN NUMBER, newWins IN NUMBER, newDraws IN NUMBER, newLosses IN NUMBER);
    
end league_utils;

--- LEAGUE UTILS BODY ------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY league_utils AS

    WRONG_DATA EXCEPTION;
    TEAM_NOT_FOUND EXCEPTION;
    TEAM_PLAYED_ALL_MATCHES EXCEPTION;
    
    --- Aktualizowanie danych tabeli ligowej ---
    PROCEDURE update_league_data(teamId IN NUMBER, newScoredGoals IN NUMBER, newLostGoals IN NUMBER, newWins IN NUMBER, newDraws IN NUMBER, newLosses IN NUMBER) AS
        counter INTEGER;
        team t_team;
        teamFound INTEGER;
        tableId INTEGER;
        
            BEGIN
                teamFound := 0;
                IF teamId IS NOT NULL AND newScoredGoals IS NOT NULL AND newLostGoals IS NOT NULL AND newWins IS NOT NULL AND newDraws IS NOT NULL AND newLosses IS NOT NULL THEN
                    FOR cursor1 IN (SELECT * FROM league_table)
                        LOOP
                            SELECT DEREF(cursor1.team) INTO team from league_table t WHERE t.id = cursor1.id;
                            IF team.id = teamId THEN
                                teamFound := 1;
                                tableId := cursor1.id;
                            END IF;
                        END LOOP;
                        IF teamFound = 1 THEN
                            UPDATE league_table t SET
                                t.points = newWins * 3 + newDraws,
                                t.scoredGoals = t.scoredGoals + newScoredGoals,
                                t.lostGoals = t.lostGoals + newLostGoals,
                                t.wins = t.wins + newWins,
                                t.draws = t.draws + newDraws,
                                t.losses = t.losses + newLosses WHERE t.id = tableId;
                                DBMS_OUTPUT.PUT_LINE('Zaktualizowano dane meczowe');
                        ELSE
                            RAISE TEAM_NOT_FOUND;
                        END IF;
                ELSE
                    RAISE WRONG_DATA;
                END IF;
                EXCEPTION
                    WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
                    WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Wprowadzona druøyna nie istnieje');
            END update_league_data;

END league_utils;


--- TEAM UTILS --------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE team_utils AS
    
    PROCEDURE add_team(newTeamName IN VARCHAR2, establishmentYear IN NUMBER);
    PROCEDURE print_team_players(teamId IN NUMBER);
    
END team_utils;

--- TEAM UTILS BODY ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY team_utils AS
    
    WRONG_DATA EXCEPTION;
    TEAM_ALREADY_EXSISTS EXCEPTION;
    TEAM_NOT_FOUND EXCEPTION;
    
    --- DODAWANIE NOWEJ DRUØYNY ---
    PROCEDURE add_team(newTeamName IN VARCHAR2, establishmentYear IN NUMBER) AS
        counter INTEGER;
        teamId INTEGER;
        newTeamRef REF t_team;
        
        BEGIN        
            IF newTeamName IS NOT NULL AND establishmentYear IS NOT NULL THEN
                SELECT COUNT(*) INTO counter FROM teams t WHERE t.teamName = newTeamName;
                
                IF counter = 0 THEN
                    teamId := TEAMS_SEQUENCE.nextval;
                    INSERT INTO teams values
                    (
                        teamId, newTeamName, establishmentYear, 0, 0, 0, 0
                    );
                    DBMS_OUTPUT.PUT_LINE('Dodano nowa druøynÍ');
                    -- Dodawanie nowo dodanej druøyny do tabeli
                    SELECT REF(t) INTO newTeam FROM teams t WHERE t.id LIKE teamId;
                    INSERT INTO league_table values
                    (
                        LEAGUE_TABLE_SEQUENCE.nextval, newTeam, 0, 0, 0, 0, 0, 0
                    );                
                ELSE
                    RAISE TEAM_ALREADY_EXSISTS;
                END IF;
            ELSE
                RAISE WRONG_DATA;
            END IF;          
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN TEAM_ALREADY_EXSISTS THEN DBMS_OUTPUT.PUT_LINE('Druøyna o podanej nazwiej juø istnieje');
            
    END add_team;
    
    --- WYPISYWANIE WSZYSTKICH ZAWODNIK”W DRUØYNY ---
    PROCEDURE print_team_players(teamId IN NUMBER) AS
        team t_team;
        counter INTEGER;
        BEGIN
            IF teamId IS NOT NULL THEN
                SELECT COUNT(*) INTO counter FROM teams t WHERE t.id = teamId;
                IF counter > 0 THEN
                    FOR cursor1 IN (SELECT * FROM players) 
                      LOOP
                        SELECT DEREF(cursor1.team) INTO team from players p WHERE p.id = cursor1.id;
                        IF team.id = teamID THEN
                            DBMS_OUTPUT.PUT_LINE('Imie = ' || cursor1.firstName || ', Nazwisko = ' || cursor1.lastName);
                        END IF;
                      END LOOP;
                ELSE
                    RAISE TEAM_NOT_FOUND;
                END IF;
            ELSE
                RAISE WRONG_DATA;
            END IF;
            EXCEPTION
                WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana druøyna nie istnieje');
                WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
        
    END print_team_players;

end team_utils;


--- PLAYER UTILS -----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE player_utils AS
    
    PROCEDURE add_player(playerFirstName IN VARCHAR2, playerLastName IN VARCHAR2, playerBirthDate IN DATE);
    PROCEDURE print_players;
    PROCEDURE add_team(playerId number, teamId number);
    PROCEDURE add_match_data(playerId number, scoredGoals number, minutesPlayed number, assistsNumber number, yellowCardsReceived number, redCardsReceived number);
    
END player_utils;

--- PLAYER UTILS BODY ------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY player_utils AS
    
    WRONG_DATA EXCEPTION;
    PLAYER_ALREADY_EXSISTS EXCEPTION;
    TEAM_NOT_FOUND EXCEPTION;
    PLAYER_NOT_FOUND EXCEPTION;
    
    --- DODAWANIE NOWEGO ZAWODNIKA ---
    PROCEDURE add_player(playerFirstName IN VARCHAR2, playerLastName IN VARCHAR2, playerBirthDate IN DATE) AS
        counter INTEGER;      
        BEGIN
            IF playerFirstName IS NOT NULL AND playerLastName IS NOT NULL AND playerBirthDate IS NOT NULL THEN
                SELECT COUNT(*) INTO counter FROM players p WHERE p.firstName = playerFirstName AND p.lastName = playerLastName AND p.birthDate = playerBirthDate;  
                IF counter = 0 THEN
                    INSERT INTO players values
                    (
                        PLAYERS_SEQUENCE.nextval, null, playerFirstName, playerLastName, playerBirthDate, 0, 0, 0, 0, 0
                    );
                    DBMS_OUTPUT.PUT_LINE('Dodano nowego gracza');
                ELSE
                    RAISE PLAYER_ALREADY_EXSISTS;
                END IF;
            ELSE
                RAISE WRONG_DATA;
            END IF;
            EXCEPTION
                WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
                WHEN PLAYER_ALREADY_EXSISTS THEN DBMS_OUTPUT.PUT_LINE('Gracz o podanych danych juø istnieje' || playerFirstName || ' ' || playerLastName || ' ' || playerBirthDate);    
    END add_player;
    
    --- WYPISYWANIE WSZYSTKICH ZADOWNIK”W ---
    PROCEDURE print_players AS
        team t_team;
        BEGIN
        FOR cursor1 IN (SELECT * FROM players) 
          LOOP
            SELECT DEREF(cursor1.team) INTO team from players p WHERE p.id = cursor1.id;
            DBMS_OUTPUT.PUT_LINE('Imie = ' || cursor1.firstName || ', Nazwisko = ' || cursor1.lastName || ', Nazwa druøyny = ' || team.teamName);
          END LOOP;
    END print_players;
    
    --- DODAWANIE DRUØYNY DO GRACZA ---
    PROCEDURE add_team(playerId number, teamId number) AS
        teamRef REF t_team;
        teamCounter INTEGER;
        playerCounter INTEGER;
        
        BEGIN
            IF playerId IS NOT NULL AND teamId IS NOT NULL THEN
                SELECT COUNT(*) INTO playerCounter FROM players p WHERE p.id = playerId;
                IF playerCounter > 0 THEN
                    SELECT COUNT(*) INTO teamCounter FROM teams t WHERE t.id = teamId;
                    IF teamCounter > 0 THEN
                        SELECT REF(t) INTO teamRef FROM teams t WHERE t.id LIKE teamId;
                        UPDATE players p SET p.team = teamRef WHERE p.id = playerId;
                        DBMS_OUTPUT.PUT_LINE('Przypisano druøynÍ do gracza');
                    ELSE
                        RAISE TEAM_NOT_FOUND;
                    END IF;
                ELSE
                    RAISE PLAYER_NOT_FOUND;
                END IF;
            ELSE
                RAISE WRONG_DATA;
            END IF;
            EXCEPTION
                WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
                WHEN PLAYER_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podany gracz nie istnieje');
                WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana druøyna nie istnieje');
    END add_team;
    
    --- DODAWANIE DANYCH MECZOWYCH DO GRACZA ---
    PROCEDURE add_match_data(playerId number, scoredGoals number, minutesPlayed number, assistsNumber number, yellowCardsReceived number, redCardsReceived number) AS   
    counter INTEGER;
    
    BEGIN
        IF playerId IS NOT NULL AND scoredGoals IS NOT NULL AND minutesPlayed IS NOT NULL AND assistsNumber IS NOT NULL AND yellowCardsReceived IS NOT NULL AND redCardsReceived IS NOT NULL THEN
            SELECT COUNT(*) INTO counter FROM players p WHERE p.id = playerId;
            IF counter > 0 THEN
                UPDATE players p SET
                    p.goals = p.goals + scoredGoals,
                    p.minutesTotal = p.minutesTotal + minutesPlayed,
                    p.assists = p.assists + assistsNumber,
                    p.yellowCards = p.yellowCards + yellowCardsReceived,
                    p.redCards = p.redCards + redCardsReceived WHERE p.id = playerId;
                DBMS_OUTPUT.PUT_LINE('Dodano dane dotyczace meczu do gracza');
            ELSE
                RAISE PLAYER_NOT_FOUND;
            END IF;
        ELSE
            RAISE WRONG_DATA;
        END IF;
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN PLAYER_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podany gracz nie istnieje');
    END add_match_data;
    
END player_utils;


--- MATCH UTILS -----------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE match_utils AS
    
    PROCEDURE add_match(hostId IN NUMBER, guestId IN NUMBER, matchDate IN DATE);
    PROCEDURE add_match_result(matchId IN NUMBER, winnerId IN NUMBER, newWinnerGoals IN NUMBER, newLosserGoals IN NUMBER);
    
END match_utils;

--- MATCH UTILS BODY ------------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY match_utils AS

    WRONG_DATA EXCEPTION;
    TEAM_NOT_FOUND EXCEPTION;
    MATCH_ALREADY_EXISTS EXCEPTION;
    MATCH_NOT_FOUND EXCEPTION;
    counter INTEGER;
    hostRef REF t_team;
    guestRef REF t_team;
    hostFound INTEGER;
    guestFound INTEGER;
    
    PROCEDURE add_match(hostId IN NUMBER, guestId IN NUMBER, matchDate IN DATE) AS
    BEGIN
        hostFound := 0;
        guestFound := 0;
        IF hostId IS NOT NULL AND guestId IS NOT NULL AND matchDate IS NOT NULL THEN
            FOR cursor1 IN (SELECT * FROM teams)
                LOOP
                    IF cursor1.id = hostId THEN
                        hostFound := 1;
                    ELSIF cursor1.id = guestId THEN
                        guestFound := 1;
                    END IF;
                END LOOP;
            IF hostFound = 1 AND guestFound = 1 THEN
                SELECT REF(t) INTO hostRef FROM teams t WHERE t.id LIKE hostId;
                SELECT REF(t) INTO guestRef FROM teams t WHERE t.id LIKE guestId;
                
                SELECT COUNT(*) INTO counter FROM matches m WHERE m.matchHost = hostRef AND m.visitor = guestRef AND m.matchDay = matchDate;
                IF counter = 0 THEN            
                    INSERT INTO matches VALUES
                    (
                        MATCHES_SEQUENCE.nextval, hostRef, guestRef, matchDate, null, null, null
                    );
                    DBMS_OUTPUT.PUT_LINE('Dodano nowy mecz');
                ELSE
                    RAISE MATCH_ALREADY_EXISTS;
                END IF;
            ELSE
                RAISE TEAM_NOT_FOUND;
            END IF;
        ELSE
            RAISE WRONG_DATA;
        END IF;
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Jedna badü obie druøyny nie istnieja');
            WHEN MATCH_ALREADY_EXISTS THEN DBMS_OUTPUT.PUT_LINE('Taki mecz juø istnieje');
    END add_match;
    
    PROCEDURE add_match_result(matchId IN NUMBER, winnerId IN NUMBER, newWinnerGoals IN NUMBER, newLosserGoals IN NUMBER) AS
    matchCounter INTEGER;
    teamCounter INTEGER;
    winnerTeamRef REF t_team;
    
    BEGIN
        IF matchId IS NOT NULL AND winnerId IS NOT NULL AND newWinnerGoals IS NOT NULL AND newLosserGoals IS NOT NULL THEN
            SELECT COUNT(*) INTO matchCounter FROM matches m WHERE m.id = matchId;
            IF matchCounter = 1 THEN
                SELECT COUNT(*) INTO teamCounter FROM teams t WHERE t.id = winnerId;
                IF teamCounter = 1 THEN
                    SELECT REF(t) INTO winnerTeamRef FROM teams t WHERE t.id LIKE winnerId;
                    UPDATE matches m SET
                        m.winner = winnerTeamRef,
                        m.winnerGoals = newWinnerGoals,
                        m.loserGoals = newLosserGoals WHERE m.id = matchId;
                ELSE
                    RAISE TEAM_NOT_FOUND;
                END IF;
            ELSE
                RAISE MATCH_NOT_FOUND;
            END IF;
        ELSE
            RAISE WRONG_DATA;
        END IF;
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana druøyna nie istnieje');
            WHEN MATCH_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podany mecz nie istnieje');
    END add_match_result;
    
END match_utils;