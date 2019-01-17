SET SERVEROUTPUT ON;

-- Usuwanie sekwencji

DROP SEQUENCE TEAMS_SEQUENCE;
DROP SEQUENCE LEAGUE_TABLE_SEQUENCE;
DROP SEQUENCE PLAYERS_SEQUENCE;
DROP SEQUENCE MATCHES_SEQUENCE;
DROP SEQUENCE PLAYER_GOALS_HISTORY_SEQUENCE;

-- Tworzenie sekwencji

create sequence TEAMS_SEQUENCE
    minvalue 1
    maxvalue 24
    start with 1
    increment by 1
    cache 20;
    
create sequence LEAGUE_TABLE_SEQUENCE
    minvalue 1
    maxvalue 24
    start with 1
    increment by 1
    cache 20;
    
create sequence PLAYERS_SEQUENCE
    minvalue 1
    maxvalue 552
    start with 1
    increment by 1
    cache 20;
    
create sequence MATCHES_SEQUENCE
    minvalue 1
    maxvalue 552
    start with 1
    increment by 1
    cache 20;
    
create sequence PLAYER_GOALS_HISTORY_SEQUENCE
    minvalue 1
    maxvalue 552
    start with 1
    increment by 1
    cache 20;

--- Tworzenie druzyn ---
BEGIN
    team_utils.add_team('Manchester United', 1907);
    team_utils.add_team('Manchester City', 1907);
END;

--- Tworzenie zawodników ---
BEGIN
    player_utils.add_player('Paul', 'Pogba', '1993-03-15');
    player_utils.add_player('David', 'de Gea', '1990-11-07');
    player_utils.add_player('David', 'Silva', '1986-01-08');
    player_utils.add_player('Leroy', 'Sane', '1996-01-11');
END;

--- Przypisanie zawodników do druzyn ---
BEGIN
  player_utils.add_team(1,1);
  player_utils.add_team(2,1);
  player_utils.add_team(3,2);
  player_utils.add_team(4,2);
END;

--- Dodawanie historii bramek do zawodnika --- 
BEGIN
    player_utils.add_player_goals_history(1, 17, '2015-01-01');
    player_utils.add_player_goals_history(1, 17, '2016-01-01');
    player_utils.add_player_goals_history(2, 21, '2015-01-01');
END;

--- Wypisanie historii bramek ---
BEGIN
    player_utils.print_player_goals_history(1);
END;

--- Wypisanie graczy ---
BEGIN
    player_utils.print_players;
END;
