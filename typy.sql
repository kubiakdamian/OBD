---- TYPY -----

-- Typ opisujacy tabelê ligowa
create or replace TYPE t_league AS OBJECT 
(
    id number(10),
    team REF t_team,
    points number,
    scoredGoals number,
    lostGoals number,
    wins number,
    draws number,
    losses number
)
--- Tabela ligowa
create table league_table of t_league
(
    id PRIMARY KEY,
    team WITH ROWID,
    SCOPE FOR (team) IS teams
)
OBJECT id PRIMARY KEY;

-- Typ opisujacy mecz
create or replace TYPE t_match AS OBJECT 
(
    id number(10),
    matchHost REF t_team,
    visitor REF t_team,
    matchDay date,
    winner REF t_team,
    winnerGoals number,
    loserGoals number
)
--- Tabela meczów
create table matches of t_match
(
    id PRIMARY KEY,
    matchHost WITH ROWID,
    SCOPE FOR (matchHost) IS teams,
    visitor WITH ROWID,
    SCOPE FOR (visitor) IS teams,
    winner WITH ROWID,
    SCOPE FOR (winner) IS teams
)
OBJECT id PRIMARY KEY;

--- Typ opisujacy historiê bramek zdobytych przez zawodnika
CREATE OR REPLACE TYPE t_player_goals_history AS OBJECT
(
    id NUMBER(10),
    goals NUMBER,
    sezon DATE
)

--- tablica zagni¿d¿ona historii bramek zdobytych w poszczególnych sezonach przez zawodnika
CREATE TYPE k_player_goals_history AS TABLE OF t_player_goals_history;

-- Typ opisujacy zawodnika
create or replace TYPE t_player AS OBJECT 
( 
    id number(10),
    team REF t_team,
    firstName varchar2(30),
    lastName varchar2(30),
    birthDate date,
    goals number,
    minutesTotal number,
    assists number,
    yellowCards number,
    redCards number,
    goals_history k_player_goals_history
)

--- Tabela zawodników
create table players of t_player
(
    id PRIMARY KEY,
    team WITH ROWID,
    SCOPE FOR (team) IS teams
)
OBJECT id PRIMARY KEY
NESTED TABLE goals_history
STORE AS player_goals_history;


--Typ opisujacy druzyne
create or replace TYPE t_team AS OBJECT 
(
    id number,
    teamName varchar2(30),
    establishmentYear number,
    wins number,
    draws number,
    losses number,
    points number
)
--- Tabela dru¿yn
create table teams of t_team
(
    id PRIMARY KEY
)
OBJECT id PRIMARY KEY;
/

