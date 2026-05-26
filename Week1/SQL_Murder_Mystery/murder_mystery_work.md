# This document will be used to capture my work for the SQL Murder Mystery
The detective gave you the crime scene report, but it has been lost. You recall that it was a murder that occurred sometime on **January 15, 2018** and that it took place in **SQL City**.

Using the following command, you are able to find the name of all the tables:

```sql
SELECT name
    FROM sqlite_master
where type = 'table'
```

There are 9 tables:
- crime_scene_report
- drivers_license
- facebook_event_checkin
- interview
- get_fit_now_check_in
- solution
- income
- person

The following code will allow me to explore the structure of each of the tables:
```sql
SELECT sql
    FROM sqlite_master
where name = 'crime_scene_report
```

## crime_scene_report
`CREATE TABLE crime_scene_report (date integer, type text, description text, city text)`
## drivers_license
`CREATE TABLE drivers_license ( id integer PRIMARY KEY, age integer, height integer, eye_color text, hair_color text, gender text, plate_number text, car_make text, car_model text )`
## facebook_event_checkin
`CREATE TABLE facebook_event_checkin ( person_id integer, event_id integer, event_name text, date integer, FOREIGN KEY (person_id) REFERENCES person(id) )`
## interview
`CREATE TABLE interview ( person_id integer, transcript text, FOREIGN KEY (person_id) REFERENCES person(id) )`
## get_fit_now_check_in
`CREATE TABLE get_fit_now_check_in ( membership_id text, check_in_date integer, check_in_time integer, check_out_time integer, FOREIGN KEY (membership_id) REFERENCES get_fit_now_member(id) )`
## income
`CREATE TABLE income (ssn CHAR PRIMARY KEY, annual_income integer)`
## person
`CREATE TABLE person (id integer PRIMARY KEY, name text, license_id integer, address_number integer, address_street_name text, ssn CHAR REFERENCES income (ssn), FOREIGN KEY (license_id) REFERENCES drivers_license (id))`

In order to get more information about this murder, I need to review the crime scene reports, I know when this murder took place and where it took place, so I will filter the results to only shows crimes that meet that criteria.

```sql
SELECT *
FROM crime_scene_report
WHERE city LIKE 'sql city' AND date = '20180115' AND type LIKE 'murder';
```

Running this, I get the following result:

| date | type | description | city|
|------|------|-------------|-----|
|20180115| murder | Security footage shows that there were 2 witnesses. The first witness lives at the last house on "Northwestern Dr". The second witness, named Annabel, lives somewhere on **Franklin Ave**. | SQL City |

This gives me clues to who may have seen the murder:
- One lives at the last house on **Northwestern Dr**
- One is named **Annabel** and lives on **Franklin Ave**

I am going to start with the name **Annabel**, I am going to see how many people have that name using the `person` table. I am looking for a person with the name **Annabel** who lives on **Franklin Ave**.

```sql
SELECT *
FROM person
WHERE name LIKE '%annabel%' AND address_street_name LIKE '%franklin%';
```
I get the following result:
| id | name | license_id | address_number | address_street_name | ssn |
|----|------|------------|----------------|---------------------|-----|
| 16371 | Annabel Miller | 490173 | 103 | Franklin Ave | 318771143 |

Looking at the table schema, it seems that the `id` field can be used on the `get_fit_now_member` table to get the `person_id` which lines up with the `interview` table.

```sql
SELECT *
FROM get_fit_now_member
WHERE id = '16371';
```
This returns no results - but running the following code does get a result:

```sql
SELECT *
FROM get_fit_now_member
WHERE person_id = '16371';
```

| id | person_id | name | membership_start_date | membership_status|
|----|-----------|------|-----------------------|------------------|
| 90081 | 16371 | Annabel Miller | 20160208 | gold |

I am a bit confused as to why the `person_id` number is matching the `id` number from the `person` table. I will use this information to see if I can pull from the `interview` table.

```sql
SELECT *
FROM interview
WHERE person_id = '16371';
```
This returned the following result:
| person_id | transcript |
|-----------|------------|
| 16371 | I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th |

This tells me the following things:
- She recognized the killer.
- This person belonds to her gym.
- They were at the gym on **January 9, 2018** (the murder happended on January 15, 2018)

I am assuming that the name of the gym is **Get Fit Now**, I am now going to look at that database for all checkins that happened on **January 9, 2018**. There are 10 check ins on that date:

```sql
SELECT *
FROM get_fit_now_check_in
WHERE check_in_date = '20180109';
```

| membership_id | check_in_date | check_in_time | check_out_time |
|---------------|---------------|---------------|----------------|
| X0643 | 20180109 | 957 | 1164 |
| UK1F2 | 20180109 | 344 | 518 |
| XTE42 | 20180109 | 486 | 1124 |
| 1AE2H | 20180109 | 461 | 944 |
| 6LSTG | 20180109 | 399 | 515 |
| 7MWHJ | 20180109 | 273 | 885 |
| GE5Q8 | 20180109 | 367 | 959 |
| 48Z7A | 20180109 | 1600 | 1730 |
| 48Z55 | 20180109 | 1530 | 1700 |
| 90081 | 20180109 | 1600 | 1700 |

We can now use the `membership_id` to get the `names` of the 10 suspects by joining the two tables:

```sql
SELECT m.id AS membership_id, m.name, c.check_in_date
FROM get_fit_now_check_in c
INNER JOIN get_fit_now_member m ON c.membership_id = m.id
WHERE c.check_in_date = '20180109';
```

This has given me the following list of suspects, I am 

| membership_id | name | check_in_date | check_in_time | check_out_time |
|---------------|------|---------------|---------------|----------------|
| X0643 | Shondra Ledlow | 20180109 | 957 | 1164 |
UK1F2 | Zackary Cabotage | 20180109 |	344 |	518 |
XTE42 | Sarita Bartosh | 20180109 | 486 |	1124 |
1AE2H | Adriane Pelligra | 20180109 | 461 |	944 |
6LSTG | Burton Grippe | 20180109 | 399 |	515 |
7MWHJ | Blossom Crescenzo | 20180109 | 273| 885 | 
GE5Q8 | Carmen Dimick | 20180109 | 367 |	959 |
48Z7A | Joe Germuska | 20180109 | 1600 |	1730 |
48Z55 | Jeremy Bowers | 20180109 | 1530 |	1700 |
90081 | Annabel Miller | 20180109 | 1600 |	1700 |

Since Annabel stated that she saw the suspect, I am going to narrow this list down to only show individuals who had a check in and check out time that would line up with her time at the gym.

```sql
SELECT m.id AS membership_id, m.name, c.check_in_date, c.check_in_time, c.check_out_time
FROM get_fit_now_check_in c
INNER JOIN get_fit_now_member m ON c.membership_id = m.id
WHERE c.check_in_date = '20180109'
AND check_in_time < '1700'
AND check_out_time > '1600';
```

The gives me the following suspects:
| membership_id | name | check_in_date | check_in_time | check_out_time |
|---------------|------|---------------|---------------|----------------|
|48Z7A|	Joe Germuska|	20180109|	1600|	1730|
|48Z55|	Jeremy Bowers|	20180109|	1530|	1700|
|90081|	Annabel Miller|	20180109|	1600|	1700|

These gives me two suspects that are not Annabel; **Joe Germuska** and **Jeremy Bowers**.

I am going to look at the `get_fit_now_member` table to get more information about **Joe** and **Jeremy**.

```sql
SELECT *
FROM get_fit_now_member
WHERE name LIKE 'Joe Germuska';
```
| id | person_id | name | membership_start_date | membership status |
|----|-----------|------|-----------------------|-------------------|
|48Z7A|	28819|	Joe Germuska|	20160305|	gold|

```sql
SELECT *
FROM get_fit_now_member
WHERE name LIKE 'Jeremy Bowers';
```
| id | person_id | name | membership_start_date | membership status |
|----|-----------|------|-----------------------|-------------------|
|48Z55|	67318|	Jeremy Bowers|	20160101|	gold|

I now have their `person_id`.
| name | person_id |
|------|-----------|
|Joe Germuska|28819|
|Jeremy Bowers|67318|

When I check the `interview` table for those `person_id` values, I just get one hit.

**Jeremy Bowers** was interview and stated "I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.

I do not know what this person has to do with the situation - but I feel like this is a clue. I know the following things about this person:
- Woman
- Rich
- 5'5" or 5'7" (67")
- Red hair
- Drives Tesla Model S
- Attended SQL Symphony Concert 3X in December 2017

I am going to look at the `drivers_license` table to see if I can find matching information for this suspect.

```sql
SELECT *
FROM drivers_license
WHERE car_make LIKE '%tesla%'
AND car_model LIKE '%model s%'
AND hair_color LIKE '%red%'
AND gender LIKE '%female%';
```

Running this gives me the following results:

| id | age | height | eye_color | hair_color | gender | plate_number | car_make | car_model |
|----|-----|--------|-----------|------------|--------|--------------|----------|-----------|
|202298|	68|	66|	green|	red|	female|	500123|	Tesla|	Model S|
|291182|	65|	66|	blue|	red|	female|	08CM64|	Tesla|	Model S|
|918773|	48|	65|	black|	red|	female|	917UU3|	Tesla|	Model S|

I know that this person also **attended the SQL Symphony Concert 3 times in December 2017**, so I am going to check the `facebook_even_checkin` database to see if either of these three people attended this event. First, I am going to see which people attended the **SQL Symphony Concert** 3 times.

```sql
SELECT *, COUNT(*) AS attendance_count
FROM facebook_event_checkin
WHERE event_name LIKE '%SQL Symphony%'
GROUP BY person_id
HAVING attendance_count =3;
```

| person_id | event_id | event_name | date | attendance_count |
|-----------|----------|------------|------|------------------|
|13296|	1143|	SQL Symphony Concert|	20171120|	3|
|17602|	1143|	SQL Symphony Concert|	20170922|	3|
|17884|	1143|	SQL Symphony Concert|	20180315|	3|
|19260|	1143|	SQL Symphony Concert|	20170831|	3|
|19292|	1143|	SQL Symphony Concert|	20171213|	3|
|24556|	1143|	SQL Symphony Concert|	20171224|	3|
|28166|	1143|	SQL Symphony Concert|	20170407|	3|
|37213|	1143|	SQL Symphony Concert|	20180201|	3|
|39020|	1143|	SQL Symphony Concert|	20180224|	3|
|46399|	1143|	SQL Symphony Concert|	20170503|	3|
|46634|	1143|	SQL Symphony Concert|	20170321|	3|
|48201|	1143|	SQL Symphony Concert|	20170318|	3|
|49568|	1143|	SQL Symphony Concert|	20170520|	3|
|58898|	1143|	SQL Symphony Concert|	20171220|	3|
|60708|	1143|	SQL Symphony Concert|	20170207|	3|
|78181|	1143|	SQL Symphony Concert|	20171120|	3|
|81360|	1143|	SQL Symphony Concert|	20180312|	3|
|83144|	1143|	SQL Symphony Concert|	20170131|	3|
|86843|	1143|	SQL Symphony Concert|	20180202|	3|
|90171|	1143|	SQL Symphony Concert|	20170813|	3|
|92343|	1143|	SQL Symphony Concert|	20180106|	3|
|93726|	1143|	SQL Symphony Concert|	20170602|	3|
|99116|	1143|	SQL Symphony Concert|	20180328|	3|
|99716|	1143|	SQL Symphony Concert|	20171229|	3|
|99799|	1143|	SQL Symphony Concert|	20170815|	3|

Due to the statement grouping the `person_id` column to get attendance count, the date column will be unreliable for see which of the people attended the concert **three times in December**. I began to research `window functions` but decided that I would pull the data for all people who attended the concert between **December 01, 2017** and **December 31, 2017** and then group by `person_id` to see which person attended the concert three times in **December**.

```sql
SELECT *
FROM facebook_event_checkin
WHERE event_name LIKE '%SQL Symphony%'
AND date >=20171201
AND date <=20171231
ORDER BY person_id;
```

This returned two number `24556` and `99716`.

Now that I have these two people who attended the sql symphony in December, I can check those numbers against the `person` table to get names.

```sql
SELECT *
FROM person
WHERE id = 24556 OR id = 99716;
```

| id | name | licence_id | address_number | address_street_name | ssn |
|----|------|------------|----------------|---------------------|-----|
|24556|	Bryan Pardo|	101191|	703|	Machine Ln|	816663882|
|99716|	Miranda Priestly|	202298|	1883|	Golden Ave|	987756388|

These two people both attended the sql symphony event in December at least 3 times, and one of them seems to be a female - **Miranda Priestly**.

If I search her `licence_id` against the `drivers_license` table, I get the following information:

```sql
SELECT *
FROM drivers_license
WHERE id = 202298;
```

| id | age | height | eye_color | hair_color | gender | plate_number | car_make | car_model |
|----|-----|--------|-----------|------------|--------|--------------|----------|-----------|
|202298|	68|	66|	green|	red|	female|	500123|	Tesla|	Model S|

Mirand has the following matching characteristics:

- Woman
- 5'5" or 5'7" (67")
- Red hair
- Drives Tesla Model S
- Attended SQL Symphony Concert 3X in December 2017

I have not confirmed her wealth yet, so lets check her income with her `ssn`.

```sql
SELECT *
FROM income
WHERE ssn = 987756388;
```

| ssn | annual_income |
|-----|---------------|
| 987756388 | 310,000 |

With an income of $310,000 a year, I would say that makes her pretty wealthy.

# Conclusion

## My guess is that the person who committed the murder on **January 15, 2018** in **SQL City** is **Miranda Priestly**.


