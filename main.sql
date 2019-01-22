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
    team_utils.add_team('Manchester United', 1878);
    team_utils.add_team('Manchester City', 1880);
    team_utils.add_team('Liverpool', 1892);
    team_utils.add_team('Tottenham', 1882);
END;

--- Tworzenie druzyn - b³êdne dane ---
BEGIN
    team_utils.add_team('Tottenham', 1882); -- Druzyna o podanej nazwiej juz istnieje
    team_utils.add_team(null, 1907); -- Wprowadzono niepoprawne dane
    team_utils.add_team('Manchester City', null); -- Wprowadzono niepoprawne dane
END;

--- Tworzenie zawodników ---
BEGIN
    player_utils.add_player('Paul', 'Pogba', '1993-03-15');
    player_utils.add_player('David', 'de Gea', '1990-11-07');
    player_utils.add_player('David', 'Silva', '1986-01-08');
    player_utils.add_player('Leroy', 'Sane', '1996-01-11');
END;

--- Tworzenie zawodników - B£ÊDNE DANE---
BEGIN
    player_utils.add_player('Paul', 'Pogba', '1993-03-15'); -- Gracz o podanych danych juz istniejePaul Pogba 93/03/15
    player_utils.add_player(null, 'de Gea', '1990-11-07'); -- Wprowadzono niepoprawne dane
END;

--- Przypisanie zawodników do druzyn ---
BEGIN
  player_utils.add_team(1,1);
  player_utils.add_team(2,1);
  player_utils.add_team(3,2);
  player_utils.add_team(4,2);
END;

--- Przypisanie zawodników do druzyn - b³êdne dane ---
BEGIN
  player_utils.add_team(3431, 1); -- Podany gracz nie istnieje
  player_utils.add_team(1, null); -- Wprowadzono niepoprawne dane
  player_utils.add_team(1, 23423); -- Podana dru¿yna nie istnieje
END;

--- Wypisanie zawodników konkretnej dru¿yny --- 
BEGIN
    team_utils.print_team_players(1);
END;

--- Wypisanie zawodników konkretnej dru¿yny - b³êdne dane --- 
BEGIN
    team_utils.print_team_players(133); -- Podana druzyna nie istnieje
    team_utils.print_team_players(null); -- Wprowadzono niepoprawne dane
END;

--- Przypisanie zawodników do druzyn - b³êdne dane ---
BEGIN
  player_utils.add_team(134534, 1); -- Podany gracz nie istnieje
  player_utils.add_team(2, 435351); -- Podana druzyna nie istnieje
  player_utils.add_team(2, null); -- Wprowadzono niepoprawne dane
END;

--- Wypisanie graczy ---
BEGIN
    player_utils.print_players;
END;

--- Dodawanie historii bramek do zawodnika --- 
BEGIN
    player_utils.add_player_goals_history(1, 17, '2015-01-01');
    player_utils.add_player_goals_history(1, 19, '2016-01-01');
    player_utils.add_player_goals_history(1, 32, '2017-01-01');
    player_utils.add_player_goals_history(2, 21, '2015-01-01');
END;

--- Dodawanie historii bramek do zawodnika - b³êdne dane --- 
BEGIN
    player_utils.add_player_goals_history(234231, 17, '2015-01-01'); -- Podany gracz nie istnieje
    player_utils.add_player_goals_history(1, null, '2016-01-01'); -- Wprowadzono niepoprawne dane
END;

--- Wypisanie historii bramek ---
BEGIN
    player_utils.print_player_goals_history(1);
END;

--- Wypisanie historii bramek - b³êdne dane ---
BEGIN
    player_utils.print_player_goals_history(134434); -- Podany gracz nie istnieje
    player_utils.print_player_goals_history(null); -- Wprowadzono niepoprawne dane
END;

--- Dodawanie danych meczowych do gracza ---
BEGIN
    player_utils.add_match_data(1, 2, 87, 1, 1, 0);
    player_utils.add_match_data(2, 3, 90, 0, 0, 0);
END;

--- Dodawanie danych meczowych do gracza - B£ÊDNE DANE ---
BEGIN
    player_utils.add_match_data(1, null, 87, 1, 1, 0); -- Wprowadzono niepoprawne dane
    player_utils.add_match_data(45541, 2, 87, 1, 1, 0); -- Podany gracz nie istnieje
END;

--- Dodawanie nowego meczu ---
BEGIN
    match_utils.add_match(1, 2, '2019-01-19');
    match_utils.add_match(3, 4, '2019-01-19');
    match_utils.add_match(1, 3, '2019-01-20');
END;

--- Dodawanie nowego meczu - b³êdne dane ---
BEGIN
    match_utils.add_match(144343, 2, '2019-01-19'); -- Jedna badz obie druzyny nie istnieja
    match_utils.add_match(1, 2, null); -- Wprowadzono niepoprawne dane
    match_utils.add_match(3, 1, '2019-01-19'); -- Jedna z podanych dru¿yn rozgrywa ju¿ mecz w tym terminie
END;

--- Dodawanie wyniku meczu ---
BEGIN
    match_utils.add_match_result(1, 1, 3, 2);
    match_utils.add_match_result(2, null, 1, 1);
    match_utils.add_match_result(3, 1, 4, 1);
END;

--- Dodawanie wyniku meczu - b³êdne dane ---
BEGIN
    match_utils.add_match_result(1324, 1, 3, 2); -- Podany mecz nie istnieje
    match_utils.add_match_result(1324, 1, null, 2); -- Wprowadzono niepoprawne dane
    match_utils.add_match_result(3, 13433, 3, 2); -- Podana dru¿yna nie istnieje
END;

--- WYPISANIE UPORZ¥DKOWANEJ TABELI ---
BEGIN
    league_utils.get_league_table;
END;

--- WYPISANIE KLASYFIKACJI STRZELCÓW ---
BEGIN
    league_utils.get_best_scorers;
END;

--- WYPISANIE KLASYFIKACJI ASYSTENTÓW ---
BEGIN
    league_utils.get_best_assistants;
END;