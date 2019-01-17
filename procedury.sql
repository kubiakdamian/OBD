--- LEAGUE UTILS---
CREATE OR REPLACE PACKAGE league_utils AS
    
    PROCEDURE create_league(leagueName IN VARCHAR2);
    
end league_utils;

CREATE OR REPLACE PACKAGE BODY league_utils AS

    WRONG_DATA EXCEPTION;
    
    PROCEDURE create_league(leagueName IN VARCHAR2) AS
        BEGIN
            

END league_utils;


--- TEAM UTILS ---
CREATE OR REPLACE PACKAGE team_utils AS
    
    PROCEDURE add_team(newTeamName IN VARCHAR2, establishmentYear IN NUMBER);
    PROCEDURE print_team_players(teamId IN NUMBER);
    
END team_utils;

--- TEAM UTILS BODY ---
CREATE OR REPLACE PACKAGE BODY team_utils AS
    
    WRONG_DATA EXCEPTION;
    TEAM_ALREADY_EXSISTS EXCEPTION;
    TEAM_NOT_FOUND EXCEPTION;
    
    PROCEDURE add_team(newTeamName IN VARCHAR2, establishmentYear IN NUMBER) AS
        counter INTEGER;
        
        BEGIN        
            IF newTeamName IS NOT NULL AND establishmentYear IS NOT NULL THEN
                SELECT COUNT(*) INTO counter FROM teams t WHERE t.teamName = newTeamName;
                
                IF counter = 0 THEN
                    INSERT INTO teams values
                    (
                        TEAMS_SEQUENCE.nextval, newTeamName, establishmentYear, 0, 0, 0, 0
                    );
                    DBMS_OUTPUT.PUT_LINE('Dodano nowa dru�yn�');
                ELSE
                    RAISE TEAM_ALREADY_EXSISTS;
                END IF;
            ELSE
                RAISE WRONG_DATA;
            END IF;          
        EXCEPTION
            WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
            WHEN TEAM_ALREADY_EXSISTS THEN DBMS_OUTPUT.PUT_LINE('Dru�yna o podanej nazwiej ju� istnieje');
            
    END add_team;
    
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
                WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana dru�yna nie istnieje');
                WHEN WRONG_DATA THEN DBMS_OUTPUT.PUT_LINE('Wprowadzono niepoprawne dane');
        
    END print_team_players;

end team_utils;


--- PLAYER UTILS ---
CREATE OR REPLACE PACKAGE player_utils AS
    
    PROCEDURE add_player(playerFirstName IN VARCHAR2, playerLastName IN VARCHAR2, playerBirthDate IN DATE);
    PROCEDURE print_players;
    PROCEDURE add_team(playerId number, teamId number);
    PROCEDURE add_match_data(playerId number, scoredGoals number, minutesPlayed number, assistsNumber number, yellowCardsReceived number, redCardsReceived number);
    
END player_utils;

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
                WHEN PLAYER_ALREADY_EXSISTS THEN DBMS_OUTPUT.PUT_LINE('Gracz o podanych danych ju� istnieje' || playerFirstName || ' ' || playerLastName || ' ' || playerBirthDate);    
    END add_player;
    
    --- WYPISYWANIE ZADOWNIK�W ---
    PROCEDURE print_players AS
        team t_team;
        BEGIN
        FOR cursor1 IN (SELECT * FROM players) 
          LOOP
            SELECT DEREF(cursor1.team) INTO team from players p WHERE p.id = cursor1.id;
            DBMS_OUTPUT.PUT_LINE('Imie = ' || cursor1.firstName || ', Nazwisko = ' || cursor1.lastName || ', Nazwa dru�yny = ' || team.teamName);
          END LOOP;
    END print_players;
    
    --- DODAWANIE DRU�YNY DO GRACZA ---
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
                        DBMS_OUTPUT.PUT_LINE('Przypisano dru�yn� do gracza');
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
                WHEN TEAM_NOT_FOUND THEN DBMS_OUTPUT.PUT_LINE('Podana dru�yna nie istnieje');
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