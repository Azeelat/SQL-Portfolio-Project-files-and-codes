select * from  project.dbo.data1;


select * from  project.dbo.data2;

--number of rows into our data set

select count(*) from project..data1
select count(*) from project..data2

--dataset for jharkhand ans bihar 
select * from project..data1 where state in ('Jharkhand', 'Bihar')

--population of India

select sum(population) as population from project..data2

--average growth

select state,avg(growth)*100 as avg_growth from project..data1 group by state;

--avg sex ratio

select state,round(avg(sex_ratio),0)as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc;

--avg literacy rate

select state,round(avg(literacy),0)as avg_literacy_ratio from project..data1
group by state having round(avg(literacy),0)>90  order by avg_literacy_ratio desc ;

--top 3 state showinh highest growth ratio

select top 3 state,avg(growth)*100 avg_growth from project..data1 group by state order by avg_growth desc;

--top 3 state showinh lowest  growth ratio

select top 3 state,round(avg(sex_ratio),0)as avg_sex_ratio from project..data1 group by state order by avg_sex_ratio asc;

--topand buttom 3 states in literacy rate
drop table if exists #peakstates;
create table  #peakstates
( state nvarchar(255),
  peakstates float

  )

  insert into #peakstates
  select state,round(avg(literacy),0)as avg_literacy_ratio from project..data1
  group by state order by avg_literacy_ratio desc;

  select top 3* from #peakstates order by #peakstates.peakstates desc;


  drop table if exists #bottumstates;
create table  #bottumstates
( state nvarchar(255),
  bottumstates float

  )

  insert into #bottumstates
  select state,round(avg(literacy),0)as avg_literacy_ratio from project..data1
  group by state order by avg_literacy_ratio desc;

  select top 3* from #bottumstates order by #bottumstates.bottumstates asc;
  --union operator

  select * from (
  select top 3 * from #peakstates order by #peakstates.peakstates desc) a

  union

  select * from (
  select top 3 *  from #bottumstates order by #bottumstates.bottumstates asc) b;

  --states starting with letter a

  select distinct state from project..data1 where lower(state) like 'a%' or lower(state) like 'b%'

  select distinct state from project..data1 where lower(state) like 'a%' and lower(state) like '%m'


  --joining both table

  --total males and females

  select d.state,sum(d.males) total_males, sum(d.females) total_females from
  (select c.district,c.state,round(c.population/(c.sex_ratio +1),0) males,round( (c.population * c.sex_ratio) / (c.sex_ratio + 1),0) females from
  (select a.district,a.state,a.sex_ratio,b.population from project..data1 a inner join project..data2 b on a.District = b.District) c) d
  group by d.State;

  --total literacy rate

  select c.state,sum(literate_people) total_literate_pop,sum(illiterate_people) total_literate_pop  from 
 ( select d.district,d.state,round(d.literacy_ratio * d.population,0)literate_people,
 round((1-d.literacy_ratio) * d.population,0)illiterate_people from
 ( select a.district,a.state,a.literacy/100 literacy_ratio,b.population from project..data1 a
  inner join project..data2 b on a.District = b.District) d) c
  group by c.State

  ---population in pevious census

  select sum(m.previous_census_population)previous_census_population, sum(m.current_census_population)current_census_population from(
  select e.state,sum(e.previous_census_population)previous_census_population,sum(e.current_census_population) current_census_population from 
  (select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population  current_census_population from
 (select a.district,a.state,a.growth growth,b.population from project..data1 a inner join project..data2 b on a.District=b.District)  d) e
 group by e.state) m

 --population vs area

 select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, (g.total_area/current_census_population)
 as current_census_population_vs_area from
 (select q.*,r.total_area from (
 select '1' as keyy,n.* from
  ( select sum(m.previous_census_population)previous_census_population, sum(m.current_census_population)current_census_population from(
  select e.state,sum(e.previous_census_population)previous_census_population,sum(e.current_census_population) current_census_population from 
  (select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population  current_census_population from
 (select a.district,a.state,a.growth growth,b.population from project..data1 a inner join project..data2 b on a.District=b.District)  d) e
 group by e.state) m) n)q inner join (

 select '1' as keyy,z.* from (
 select sum(area_km2)total_area  from project..data2) z) r on q.keyy=r.keyy) g

 --window

 output top 3 districts from each state with highest literacy rate
 select a.* from
 (select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..data1) a
 where a.rnk in (1,2,3) order by state




  


