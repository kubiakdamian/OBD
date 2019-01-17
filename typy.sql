---- TYPY -----

-- Typ opisujacy lige
create or replace TYPE T_LEAGUE AS OBJECT 
(
    id number(10),
    leagueName varchar2(25)
)

-- Typ opisujacy mecz
create or replace TYPE T_MATCH AS OBJECT 
(
    id number(10),
    host REF t_team,
    visitor REF t_team,
    matchDay date,
    winner REF t_team,
    loser REF t_team,
    winnerGoals number,
    loserGoals number
)
--- Tabela meczów
create table matches of t_match
(
    id PRIMARY KEY
)
OBJECT id PRIMARY KEY;

-- Typ opisujacy zawodnika
create or replace TYPE T_PLAYER AS OBJECT 
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
    redCards number
)
--- Tabela zawodników
create table players of t_player
(
    id PRIMARY KEY,
    team WITH ROWID,
    SCOPE FOR (team) IS teams
)
OBJECT id PRIMARY KEY;


--Typ opisujacy druzyne
create or replace TYPE T_TEAM AS OBJECT 
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

