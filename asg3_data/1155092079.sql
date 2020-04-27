/* Query1 */
Spool result1.lst
select L.lid, L.league_name, L.year, r.region_name from leagues L, regions R where L.rid=R.rid and (L.season='Spring' or L.season='Winter') order by L.lid;
Spool off

/* Query2 */
Spool result2.lst
select W.tid, W.team_name, W.average_age from teams W where W.tid in (select T.tid from teams T, leagues L where T.tid=L.champion_tid and L.season='Autumn' and L.year>=2015 group by T.tid having count(*)>1) order by W.tid;
Spool off

/* Query3 */
create view geach as select T.tid, L.season, count(*) as times from teams T, leagues L where T.tid=L.champion_tid group by T.tid, L.season;
create view maxtimes as select G.season, Max(G.times) as times from geach G group by G.season;
Spool result3.lst
select T.tid, T.team_name, T.average_age, E.season, E.times as W_NUM from teams T, geach E where T.tid=E.tid and T.tid in (select G.tid from maxtimes M, geach G where G.season=M.season and G.times=M.times and G.season=E.season) order by T.tid, case when E.season='Spring' then 1 when E.season='Summer' then 2 when E.season='Autumn' then 3 when E.season='Winter' then 4 End;
Spool off
drop view geach;
drop view maxtimes;


/* Query4 */

create view spon as select Spon.sid, Sup.lid from sponsors Spon, support Sup where Spon.sid=Sup.sid order by Spon.sid;
create view sponnum as select S.sid, count(*) as L_NUM from spon S group by S.sid;
create view rawer as select S.sid, S.sponsor_name, N.L_NUM from sponnum N, sponsors S where N.sid=S.sid order by S.sid;
Spool result4.lst
select * from rawer where ROWNUM<6;
Spool off
drop view spon;
drop view sponnum;
drop view rawer;


/* Query5 */

create view seasoner as select L.lid from leagues L where L.season='Summer' or L.season='Winter';
create view valuer as select S.sid from sponsors S where S.market_value>50;
create view ager as select T.tid from teams T where T.average_age<30;
create view rawrawer as select L.lid from seasoner Sea, leagues L, valuer Spon, support Sup where Sup.sid=Spon.sid and Sup.lid=L.lid and L.lid=Sea.lid;
create view rawer as select R.lid from rawrawer R, leagues L, ager A, teams T where R.lid=L.lid and L.champion_tid=T.tid and T.tid=A.tid;
Spool result5.lst
select R.lid, L.league_name from rawer R, leagues L where R.lid=L.lid order by R.lid DESC;
Spool off
drop view seasoner;
drop view valuer;
drop view ager;
drop view rawrawer;
drop view rawer;


/* Query6 */

create view spons as select Spon.sid, R.rid, Spon.market_value, Sup.sponsorship, R.football_ranking from sponsors Spon, support Sup, leagues L, regions R where Spon.sid=Sup.sid and Sup.lid=L.lid and L.rid=R.rid;
create view hots as select S.sid, S.rid, SUM(S.sponsorship)/SQRT(S.market_value)/LOG(2,SQRT(S.football_ranking)+1) as Hot from spons S group by S.sid, S.market_value, S.rid, S.football_ranking;
create view ranker as select R.rid, Max(H.hot) as maxhot from hots H, regions R where R.football_ranking<10 and R.rid=H.rid group by R.rid;
Spool result6.lst
select H.sid, H.hot from sponsors Spon, hots H, ranker R where Spon.sid=H.sid and H.rid=R.rid and H.hot=R.maxhot and Spon.market_value>40;
Spool off
drop view ranker;


/* Query7 */
create view shots as select * from hots H where H.sid>3 and H.sid<8;
create view sids as select S.sid from sponsors S where S.sid>3 and S.sid<8;
create view rids as select DISTINCT R.rid from shots R;
create view fjoins as select S.sid, R.rid from sids S, rids R;
create view ajoins as select S.sid, S.rid from shots S;
create view njoins as select * from fjoins minus select * from ajoins;
create view nhots as select njoins.sid, njoins.rid, null as hot from njoins;
create view fhots as select * from shots union select * from nhots;
create view fhot4 as select * from fhots H where H.sid=4;
create view fhot5 as select * from fhots H where H.sid=5;
create view fhot6 as select * from fhots H where H.sid=6;
create view fhot7 as select * from fhots H where H.sid=7;
create view fhotmax as select F.rid, MAX(NVL(F.hot, 0)) HOT_HIGH from fhots F group by F.rid;
Spool result7.lst
select fhot4.rid, fhot4.hot as HOT_4, fhot5.hot as HOT_5, fhot6.hot as HOT_6, fhot7.hot as HOT_7, fhotmax.HOT_HIGH  from fhot4, fhot5, fhot6, fhot7, fhotmax where fhot4.rid=fhot5.rid and fhot5.rid=fhot6.rid and fhot6.rid=fhot7.rid and fhot4.rid=fhotmax.rid;
Spool off
drop view spons;
drop view hots;
drop view shots;
drop view sids;
drop view rids;
drop view fjoins;
drop view ajoins;
drop view njoins;
drop view nhots;
drop view fhots;
drop view fhot4;
drop view fhot5;
drop view fhot6;
drop view fhot7;
drop view fhotmax;


/* Query8 */

create view wins as select L.champion_tid as tid, COUNT(*) as times from leagues L group by L.champion_tid;
create view maxwin as select MAX(W.times) as maxwin from wins W;
create view comp as select W.tid from wins W, maxwin M where W.times=M.maxwin;
Spool result8.lst
select DISTINCT Spon.sid, Spon.sponsor_name from sponsors Spon, support Sup, leagues L, comp T where Spon.sid=Sup.sid and Sup.lid=L.lid and L.champion_tid=T.tid order by Spon.sid;
Spool off
drop view wins;
drop view maxwin;
drop view comp;
