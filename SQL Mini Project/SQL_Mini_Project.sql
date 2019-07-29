/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT 
	name
FROM country_club.Facilities
WHERE membercost >0

/* Q2: How many facilities do not charge a fee to members? */

SELECT 
	COUNT( name ) 
FROM country_club.Facilities
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
	facid
	, name
	, membercost
	, monthlymaintenance
FROM country_club.Facilities
WHERE membercost >0
	AND membercost < 0.2 * monthlymaintenance


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT 
	facid
	, name
	, guestcost
	, membercost
	, initialoutlay
	, monthlymaintenance
FROM country_club.Facilities
WHERE facid IN ( 1, 4 ) 

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 
	facid
	, name
	, monthlymaintenance, 
	CASE WHEN monthlymaintenance > 100 THEN  'expensive' ELSE  'cheap' END AS facility_ind
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT 
	firstname
	, surname
FROM country_club.Members
WHERE joindate = (SELECT 
					MAX( joindate ) 
				  FROM country_club.Members )

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT 
	fc.name
	, concat(mem.firstname,' ',mem.surname) full_name 
FROM Bookings bk
JOIN Facilities fc 
	ON ( bk.facid = fc.facid ) 
JOIN Members mem 
	ON ( bk.memid = mem.memid ) 
WHERE name IN ( 'Tennis Court 1', 'Tennis Court 2')
	and mem.memid <> 0      /*Memeber ID 0 excluded as it is used for guests.*/
group by fc.name, full_name
order by full_name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
	fac.name Facility_Name
	, bk.bookid      /*ID of the Booking that had cost higher than 30$.*/
	, CONCAT( mem.firstname,  ' ', mem.surname ) Member_Name
	, (CASE 
		WHEN mem.memid = 0 THEN guestcost
		ELSE membercost
	   END)*bk.slots AS Total_Cost
FROM country_club.Bookings bk
JOIN country_club.Members mem 
	ON ( bk.memid = mem.memid ) 
JOIN country_club.Facilities fac 
	ON ( bk.facid = fac.facid ) 
WHERE LEFT( bk.starttime, 10 ) =  '2012-09-14'
	AND (CASE 
			WHEN mem.memid = 0 THEN guestcost
			ELSE membercost
		 END)*bk.slots >30
order by Total_Cost desc


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT 
	fac.name Facility_Name
	, bk.bookid      /*ID of the Booking that had cost higher than 30$.*/
	, CONCAT( mem.firstname,  ' ', mem.surname ) Member_Name
	, (CASE 
		WHEN mem.memid = 0 THEN guestcost
		ELSE membercost
	   END)*bk.slots AS Total_Cost
FROM 
(SELECT * 
from country_club.Bookings 
where LEFT( starttime, 10 ) =  '2012-09-14') bk
JOIN country_club.Members mem 
	ON ( bk.memid = mem.memid ) 
JOIN country_club.Facilities fac 
	ON ( bk.facid = fac.facid ) 
WHERE 
	(CASE 
			WHEN mem.memid = 0 THEN guestcost
			ELSE membercost
		 END)*bk.slots >30
order by Total_Cost desc


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

select
	fac.name
	, sum( case 
			when bk.memid=0 then bk.slots*fac.guestcost
			else bk.slots*fac.membercost 
		  end ) revenue
from 
Bookings bk
join Facilities fac
	on (bk.facid=fac.facid)
group by fac.name
having revenue < 1000
order by revenue


