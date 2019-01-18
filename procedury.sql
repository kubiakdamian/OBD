--- TRIGGER ---
CREATE OR REPLACE TRIGGER trigger_league_data_updating AFTER UPDATE ON league_table
DECLARE
    teamT t_team;
BEGIN
    SELECT * INTO teamT
        FROM (SELECT DEREF(l.team) FROM league_table l ORDER BY l.points DESC, l.scoredGoals DESC, l.wins DESC)
    WHERE rownum = 1;
    
    DBMS_OUTPUT.PUT_LINE('Lider: ' || teamT.teamName);
END;

--- LEAGUE UTILS------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE league_utils AS
    
    PROCEDURE update_league_data(teamId IN NUMBER, newScoredGoals IN NUMBER, newLostGoals IN NUMBER, newWins IN NUMBER, newDraws IN NUMBER, newLosses IN NUMBER);
    PROCEDURE update_league_data_from_match(matchId IN NUMBER, winnerId NUMBER);
    PROCEDURE get_league_table;
    PROCEDURE get_best_scorers;
    PROCEDURE get_best_assistants;
    
end league_utils;

--- LEAGUE UTILS BODY ------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY league_utils AS

    WRONG_DATA EXCEPTION;
    TEAM_NOT_FOUND EXCEPTION;
    MATCH_NOT_FOUND EXCEPTION;
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
                                t.points = t.points + newWins * 3 + newDraws,
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
                    WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Wprowadzona druzyna nie istnieje');
            END update_league_data;
            
        PROCEDURE update_league_data_from_match(matchId IN NUMBER, winnerId NUMBER) AS
                nMatch t_match;
                hostT t_team;
                visitorT t_team;
                matchCounter INTEGER;
                winnerGoalsN NUMBER;
                losserGoalsN NUMBER;
                
            BEGIN
                SELECT COUNT(*) INTO matchCounter FROM matches m WHERE m.id = matchId;
                IF matchCounter = 1 THEN
                    FOR cursor1 IN (SELECT * FROM matches) 
                        LOOP
                            IF cursor1.ID = matchId THEN   
                                SELECT DEREF(cursor1.matchHost) INTO hostT from matches m WHERE m.id = cursor1.ID;
                                SELECT DEREF(cursor1.visitor) INTO visitorT from matches m WHERE m.id = cursor1.ID;
                                winnerGoalsN := cursor1.winnerGoals;
                                losserGoalsN := cursor1.loserGoals;
                            END IF;
                        END LOOP;
                    
                    IF winnerId IS null THEN
                        update_league_data(hostT.id, winnerGoalsN, losserGoalsN, 0, 1, 0);
                        update_league_data(visitorT.id, losserGoalsN, winnerGoalsN, 0, 1, 0);
                        DBMS_OUTPUT.PUT_LINE('Zaktualizowano tabele ligowa');
                    ELSE
                        IF winnerId = hostT.id THEN
                            update_league_data(hostT.id, winnerGoalsN, losserGoalsN, 1, 0, 0);
                            update_league_data(visitorT.id, losserGoalsN, winnerGoalsN, 0, 0, 1);
                            DBMS_OUTPUT.PUT_LINE('Zaktualizowano tabele ligowa');
                        ELSE
                            update_league_data(visitorT.id, winnerGoalsN, losserGoalsN, 1, 0, 0);
                            update_league_data(hostT.id, losserGoalsN, winnerGoalsN, 0, 0, 1);
                            DBMS_OUTPUT.PUT_LINE('Zaktualizowano tabele ligowa');
                        END IF;               
                    END IF;
                ELSE
                    RAISE MATCH_NOT_FOUND;
                END IF;
                EXCEPTION
                    WHEN MATCH_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Wprowadzona druzyna nie istnieje');
        END update_league_data_from_match;
        
        PROCEDURE get_league_table AS
            teamT t_team;
            pos INTEGER;
        BEGIN
            pos := 1;
            FOR cursor1 IN (SELECT * FROM league_table ORDER BY points DESC, wins DESC, scoredgoals DESC) 
                LOOP
                    SELECT DEREF(cursor1.team) INTO teamT FROM league_table WHERE league_table.id = cursor1.id;
                    DBMS_OUTPUT.PUT_LINE('Poz.' || pos || '  Dru¿yna: ' || teamT.teamName || '  Punkty: ' || cursor1.points || '  Zwyciêstwa: ' || cursor1.wins
                    || '  Remisy: ' || cursor1.draws || '  Pora¿ki: ' || cursor1.losses || '  Bramki zdobyte ' || cursor1.scoredGoals
                    || '  Bramki stracone: ' || cursor1.lostGoals);
                    pos := pos + 1;
                END LOOP; 
        END get_league_table;
        
        PROCEDURE get_best_scorers AS
            i INTEGER;
        BEGIN
            i := 0;
            FOR cursor1 IN (SELECT * FROM players p ORDER BY p.goals DESC, p.minutesTotal ASC) 
            LOOP
                IF i < 10 THEN
                    DBMS_OUTPUT.PUT_LINE(cursor1.firstName || ' ' || cursor1.lastName || ' ' || cursor1.goals);
                    i := i + 1;
                END IF;
            END LOOP;
        END get_best_scorers;
        
        PROCEDURE get_best_assistants AS
            i INTEGER;
        BEGIN
            i := 0;
            FOR cursor1 IN (SELECT * FROM players p ORDER BY p.assists DESC, p.minutesTotal ASC) 
            LOOP
                IF i < 10 THEN
                    DBMS_OUTPUT.PUT_LINE(cursor1.firstName || ' ' || cursor1.lastName || ' ' || cursor1.assists);
                    i := i + 1;
                END IF;
            END LOOP;
        END get_best_assistants;
END league_utils;


--- TEAM UTILS --------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE team_utils AS
    
    PROCEDURE add_team(newTeamName IN VARCHAR2, establishmentYear IN NUMBER);
    PROCEDURE print_team_players(teamId IN NUMBER);
    FUNCTION is_team_playing_in_date(teamId IN NUMBER, matchDateD IN DATE) RETURN NUMBER;
    
END team_utils;

--- TEAM UTILS BODY ---------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY team_utils AS
    
    WRONG_DATA EXCEPTION;
    TEAM_ALREADY_EXSISTS EXCEPTION;
    TEAM_NOT_FOUND EXCEPTION;
    
    --- DODAWANIE NOWEJ DRUZYNY ---
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
                    DBMS_OUTPUT.PUT_LINE('Dodano nowa druzyne');
                    -- Dodawanie nowo dodanej druzyny do tabeli
                    SELECT REF(t) INTO newTeamRef FROM teams t WHERE t.id LIKE teamId;
                    INSERT INTO league_table values
                    (
                        LEAGUE_TABLE_SEQUENCE.nextval, newTeamRef, 0, 0, 0, 0, 0, 0
                    );                
                ELSE
                    RAISE TEAM_ALREADY_EXSISTS;
                END IF;
            ELSE
                RAISE WRONG_DATA;
            END IF;          
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN TEAM_ALREADY_EXSISTS THEN DBMS_OUTPUT.PUT_LINE('Druzyna o podanej nazwiej juz istnieje');
            
    END add_team;
    
    --- WYPISYWANIE WSZYSTKICH ZAWODNIKÓW DRUZYNY ---
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
                WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana druzyna nie istnieje');
                WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
        
    END print_team_players;
    
    --- SPRAWDZANIE, CZY DRU¯YNA GRA JU¯ MECZ W PODANYM DNIU ---
    FUNCTION is_team_playing_in_date(teamId IN NUMBER, matchDateD IN DATE) RETURN NUMBER AS is_playing NUMBER;
        hostT t_team;
        visitorT t_team;
    BEGIN
        is_playing := 0;
        FOR cursor1 IN (SELECT * FROM matches m WHERE m.matchDay = matchDateD)
        LOOP
            SELECT DEREF(cursor1.matchhost) INTO hostT FROM matches m where m.id = cursor1.id;
            SELECT DEREF(cursor1.matchhost) INTO visitorT FROM matches m where m.id = cursor1.id;
            IF hostT.id = teamId OR visitorT.id = teamId THEN
                is_playing := 1;
            END IF;     
        END LOOP;
        RETURN is_playing;
    END is_team_playing_in_date;

end team_utils;


--- PLAYER UTILS -----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE player_utils AS
    
    PROCEDURE add_player(playerFirstName IN VARCHAR2, playerLastName IN VARCHAR2, playerBirthDate IN DATE);
    PROCEDURE print_players;
    PROCEDURE add_team(playerId number, teamId number);
    PROCEDURE add_match_data(playerId number, scoredGoals number, minutesPlayed number, assistsNumber number, yellowCardsReceived number, redCardsReceived number);
    PROCEDURE add_player_goals_history(playerId IN NUMBER, goalsN IN NUMBER, sezonD IN DATE);
    PROCEDURE print_player_goals_history(playerId IN NUMBER);
    
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
                        PLAYERS_SEQUENCE.nextval, null, playerFirstName, playerLastName, playerBirthDate, 0, 0, 0, 0, 0, null
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
                WHEN PLAYER_ALREADY_EXSISTS THEN DBMS_OUTPUT.PUT_LINE('Gracz o podanych danych juz istnieje' || playerFirstName || ' ' || playerLastName || ' ' || playerBirthDate);    
    END add_player;
    
    --- WYPISYWANIE WSZYSTKICH ZADOWNIKÓW ---
    PROCEDURE print_players AS
        team t_team;
        BEGIN
        FOR cursor1 IN (SELECT * FROM players) 
          LOOP
            SELECT DEREF(cursor1.team) INTO team from players p WHERE p.id = cursor1.id;
            DBMS_OUTPUT.PUT_LINE('Imie = ' || cursor1.firstName || ', Nazwisko = ' || cursor1.lastName || ', Nazwa druzyny = ' || team.teamName);
          END LOOP;
    END print_players;
    
    --- DODAWANIE DRUZYNY DO GRACZA ---
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
                        DBMS_OUTPUT.PUT_LINE('Przypisano druzyne do gracza');
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
                WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana druzyna nie istnieje');
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
    
    --- Dodawanie historii bramek do gracza
    PROCEDURE add_player_goals_history(playerId IN NUMBER, goalsN IN NUMBER, sezonD IN DATE) AS
        counter INTEGER;
        i INTEGER;
        k_goals_history k_player_goals_history;
    BEGIN
        IF playerId IS NOT NULL AND goalsN IS NOT NULL AND sezonD IS NOT NULL THEN
            SELECT COUNT(*) INTO counter FROM players p WHERE p.id = playerId;
            IF counter > 0 THEN
                SELECT p.goals_history INTO k_goals_history FROM players p WHERE p.id = playerId;
                IF k_goals_history IS NULL THEN
                    k_goals_history := k_player_goals_history();
                    k_goals_history.extend(1);
                    i := k_goals_history.last();
                    k_goals_history(i) := new t_player_goals_history(PLAYER_GOALS_HISTORY_SEQUENCE.nextval, goalsN, sezonD);
                ELSE
                    k_goals_history.extend(1);
                    i := k_goals_history.last();
                    k_goals_history(i) := new t_player_goals_history(PLAYER_GOALS_HISTORY_SEQUENCE.nextval, goalsN, sezonD); 
                END IF;
                UPDATE players p SET p.goals_history = k_goals_history WHERE p.id = playerId;
                DBMS_OUTPUT.PUT_LINE('Dodano historie goli');
            ELSE
                RAISE PLAYER_NOT_FOUND;
            END IF;
        ELSE
            RAISE WRONG_DATA;
        END IF;
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN PLAYER_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podany gracz nie istnieje');
    END add_player_goals_history;
    
    --- WYPISYWANIE HISTORII BRAMEK GRACZA
    PROCEDURE print_player_goals_history(playerId IN NUMBER) AS
        counter INTEGER;
        k_goals_history k_player_goals_history;
    BEGIN
    IF playerId IS NOT NULL THEN
        SELECT COUNT(*) INTO counter FROM players p WHERE p.id = playerId;
            IF counter > 0 THEN
                SELECT p.goals_history INTO k_goals_history FROM players p WHERE p.id = playerId;
                FOR cursor1 IN (SELECT * FROM table(k_goals_history)) 
                LOOP
                    DBMS_OUTPUT.PUT_LINE('Sezon = ' || cursor1.sezon || ', Bramki = ' || cursor1.goals);
                 END LOOP;
            ELSE
                RAISE PLAYER_NOT_FOUND;
            END IF;
    ELSE
        RAISE WRONG_DATA;
    END IF;
            EXCEPTION
                WHEN PLAYER_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podany gracz nie istnieje');
                WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
    END print_player_goals_history;
        
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
    TEAM_ALREADY_PLAYING EXCEPTION;
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
            IF team_utils.is_team_playing_in_date(hostId, matchDate) = 0 AND team_utils.is_team_playing_in_date(guestId, matchDate) = 0 THEN
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
                RAISE TEAM_ALREADY_PLAYING;
            END IF;
        ELSE
            RAISE WRONG_DATA;
        END IF;
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Jedna badz obie druzyny nie istnieja');
            WHEN MATCH_ALREADY_EXISTS THEN DBMS_OUTPUT.PUT_LINE('Taki mecz juz istnieje');
            WHEN TEAM_ALREADY_PLAYING THEN DBMS_OUTPUT.PUT_LINE('Jedna z podanych dru¿yn rozgrywa ju¿ mecz w tym terminie');
    END add_match;
    
    PROCEDURE add_match_result(matchId IN NUMBER, winnerId IN NUMBER, newWinnerGoals IN NUMBER, newLosserGoals IN NUMBER) AS
    matchCounter INTEGER;
    teamCounter INTEGER;
    winnerTeamRef REF t_team;
    nMatch t_match;
    
    BEGIN
        IF matchId IS NOT NULL AND newWinnerGoals IS NOT NULL AND newLosserGoals IS NOT NULL THEN
            SELECT COUNT(*) INTO matchCounter FROM matches m WHERE m.id = matchId;
            IF matchCounter = 1 THEN
                IF winnerId IS NOT NULL THEN
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
                    UPDATE matches m SET
                        m.winner = null,
                        m.winnerGoals = newWinnerGoals,
                        m.loserGoals = newLosserGoals WHERE m.id = matchId;
                END IF;
                    --- Aktualizowanie danych tabeli ligowej
                    league_utils.update_league_data_from_match(matchId, winnerId);
            ELSE
                RAISE MATCH_NOT_FOUND;
            END IF;
        ELSE
            RAISE WRONG_DATA;
        END IF;
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana druzyna nie istnieje');
            WHEN MATCH_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podany mecz nie istnieje');
    END add_match_result;
    
END match_utils;