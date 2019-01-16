SET SERVEROUTPUT ON;

--- Tworzenie dru¿yn ---
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

--- Wypisanie graczy ---
BEGIN
    player_utils.print_players;
END;
