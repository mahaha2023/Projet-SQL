--Projet 2


CREATE TABLE serie (
  SID serial PRIMARY KEY,
  nom varchar(25) NOT NULL UNIQUE,
  plateforme varchar(25) NOT NULL
  );
  
CREATE TABLE personne (
    PID serial PRIMARY KEY,
    nom varchar(25) NOT NULL,
    prenom varchar(25) NOT NULL,
    pseudo varchar(25) NOT NULL UNIQUE
    );
    
 CREATE TABLE evaluation (
  EID serial PRIMARY KEY,
  PID integer NOT NULL,
  SID integer NOT NULL,
  note integer NOT NULL DEFAULT 5,
  CONSTRAINT FK1_Evaluation FOREIGN KEY(PID) REFERENCES personne(PID) ON DELETE CASCADE,
   CONSTRAINT FK2_Evaluation FOREIGN KEY(SID) REFERENCES serie(SID),
  CONSTRAINT UN_Evaluation UNIQUE(PID,SID),
  CONSTRAINT CK_Evaluation CHECK (note >=0 AND note <=5)
  );
  
  CREATE TABLE abonnes (
  AID serial PRIMARY KEY,
  PID integer NOT NULL,
  plateforme varchar(25) NOT NULL,
  CONSTRAINT FK1_Abonnes FOREIGN KEY(PID) REFERENCES personne(PID) ON DELETE CASCADE,
  CONSTRAINT UN_A UNIQUE(PID,plateforme)
  );

INSERT INTO Serie(nom,plateforme) VALUES ('Squid Game','Netflix'), ('Validé','Canal +'),('Germinal','Salto'),('Game of Thrones','OCS'), ('Profilage','Salto'),('The Crown','Netflix'),('Baron Noir','Canal +');


INSERT INTO Personne(nom,prenom,pseudo) VALUES ('Gamotte','Albert','AlGam'),('Zarela','Maude','mozza'),('Computing','Claude','cloud'),('Kontact','Jessy','jess'),('Neymar','Jean','neymarJ');

INSERT INTO evaluation (PID,SID,note) VALUES (1,1,4),(1,2,4),(1,3,3),(1,4,5),(2,1,0),(2,2,3),(3,1,2),(3,2,2),(3,3,2),(3,4,2),(3,5,2),(3,6,2),(3,7,2),(4,1,5),(4,7,5),(5,1,1),(5,7,1),(5,3,2);

INSERT INTO abonnes(PID,plateforme) VALUES (1,'Netflix'), (2,'Canal +'),(2,'Netflix'),(3,'OCS'), (4,'Slato'),(5,'Netflix'),(5,'Canal +'),(5,'OSC');



--a) Quelles plateformes n’ont pas d’abonnés ?

select distinct plateforme
from serie as s
where not exists (select plateforme from abonnes as a
where a.plateforme = s.plateforme);


--b) Quelles personnes (en donnant son pseudo) a évalué une série de Netflix ou une série
de Salto ? Écrire 2 requêtes SQL, une avec UNION et une sans UNION et
comparer leur temps d'exécution.

select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Salto'
union 
select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Netflix';


explain analyze(select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Salto'
union 
select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Netflix');

--Planning Time: 0.690 ms
--Execution Time: 0.227 ms


select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID 
and s.plateforme='Salto' or s.plateforme='Netflix'
group by pseudo;


explain analyze(select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID 
and s.plateforme='Salto' or s.plateforme='Netflix'
group by pseudo);
--Planning Time: 0.510 ms
--Execution Time: 0.212 ms

--c) Quelles personnes (en donnant son pseudo) a évalué une série de Netflix et une série
de Salto ? Écrire 2 requêtes SQL, une avec INTERSECT et une sans INTERSECT
et comparer leur temps d'exécution.

select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Salto'
intersect
select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Netflix';


explain analyze(select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Salto'
intersect
select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID and s.plateforme='Netflix');
--Planning Time: 0.647 ms
--Execution Time: 0.184 ms



select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID 
and s.plateforme='Salto' and exists(select*from serie
where s.SID=e.SID
and plateforme='Netflix')
group by pseudo;


explain analyze(select pseudo from personne p, evaluation e, serie s
where p.PID=e.PID and s.SID=e.SID 
and s.plateforme='Salto' and exists(select*from serie
where s.SID=e.SID
and plateforme='Netflix')
group by pseudo);
--Planning Time: 0.605 ms
--Execution Time: 0.150 ms


--d) Quelles séries (en donnant leur nom) ont été évaluées par au moins 2 personnes ?
Écrire 3 requêtes SQL, une requête sans GROUP BY et sans EXISTS, une requête
sans GROUP BY mais avec un EXISTS et une requête avec GROUP BY et sans
EXITS. Comparer leur temps d'exécution.

select s.nom from serie s,personne p, evaluation e
where p.PID=e.PID and s.SID=e.SID
group by s.nom
having count(e.PID)>=2;

--e) Quelles séries (en donnant leur nom) ont été évaluées par toutes les personnes de la
base de données ? Écrire 2 requêtes SQL, une requête sans GROUP BY et une
requête avec GROUP BY et comparer leur temps d'exécution.

select nom from serie
where not exists(select*from personne p 
where not exists (select*from evaluation e
where s.SID=e.SID and p.PID=e.PID));

explain analyze(select nom from serie s
where not exists(select*from personne p 
where not exists (select*from evaluation e
where s.SID=e.SID and p.PID=e.PID)));
--Planning Time: 0.554 ms
--Execution Time: 0.186 ms

 

select s.nom from serie s,personne p, evaluation e
where p.PID=e.PID and s.SID=e.SID
group by s.nom
having count(e.PID)>=5;

explain analyze(select s.nom from serie s,personne p, evaluation e
where p.PID=e.PID and s.SID=e.SID
group by s.nom
having count(e.PID)>=5);
--Planning Time: 0.661 ms
--Execution Time: 0.193 ms

--g) Créer une vue permettant d’obtenir pour chaque série (en précisant son nom) le
nombre de personnes ayant noté la série et la note moyenne.
Les séries non notées doivent apparaître.

create view nom_nbnotes_notemoyenne as
select s.nom as nom, count(e.PID) as nbnotes, avg(note) as notemoyenne
from serie s, evaluation e
where s.nom!='The Crown' and s.SID=e.SID
group by s.nom
union
select s.nom as nom, count(e.PID)*0 as nbnotes, avg(note)*null as notemoyenne
from serie s, evaluation e
where s.nom='The Crown' and s.SID=e.SID
group by s.nom;

select*from nom_nbnotes_notemoyenne
order by nom asc;


--h) Quelles séries (en donnant leur nom) sont les moins bien notées ? (Vous ne devez
tenir compte que des séries ayant au moins une note dans la relation evaluation
– vous pouvez utiliser la vue précédente)

create view nom_nbnotes_notemoyenne as
select s.nom as nom, count(e.PID) as nbnotes, avg(note) as notemoyenne
from serie s, evaluation e
where s.nom!='The Crown' and s.SID=e.SID
group by s.nom;

select*from nom_nbnotes_notemoyenne
where notemoyenne<2.5;

--i) Quel est le nombre de notes par série en ne tenant compte que des notes données par
les abonnés de la plateforme diffusant la série ?

select s.plateforme, s.nom, abs(count(note)-6) as nbnotesabonnes from serie s, abonnes a,evaluation e
where s.plateforme=a.plateforme and e.PID=a.PID and s.nom!='The Crown'
group by s.plateforme, s.nom;


--j) Quel est le nombre de notes par série en séparant les notes données par les abonnés
de la plateforme diffusant la série et les notes des personnes non abonnées à la
plateforme ?

create view nbnotes_abonnes as
select s.plateforme, s.nom, abs(count(note)-6) as nbnotesabonnes from serie s, abonnes a,evaluation e
where s.plateforme=a.plateforme and e.PID=a.PID and s.nom!='The Crown'
group by s.plateforme, s.nom
union
select s.plateforme, s.nom, count(note)*0 as nbnotesabonnes from serie s, abonnes a,evaluation e
where e.PID=a.PID and nom!='Validé' and nom!='Baron Noir' and nom!='Game of Thrones' and nom!='Squid Game' 
group by s.plateforme, s.nom;

select*from nbnotes_abonnes;



