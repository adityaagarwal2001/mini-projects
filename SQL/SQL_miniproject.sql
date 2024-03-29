/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: *******

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

SELECT name
FROM  Facilities
WHERE membercost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( * ) 
FROM Facilities
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT `facid`, `name`, `membercost`, `monthlymaintenance`
FROM Facilities
WHERE `membercost` > 0 AND `membercost` < (0.2 * `monthlymaintenance`)

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT * 
FROM `Facilities` 
WHERE `facid` IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT `name`, `monthlymaintenance`,
	CASE 
		WHEN `monthlymaintenance` <= 100 THEN 'cheap'
    		WHEN `monthlymaintenance` > 100 THEN 'expensive'
	END AS label
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT M.firstname, M.surname
FROM Members M
INNER JOIN(
    SELECT MAX(DATE(`joindate`)) AS LastDate
    FROM Members
    ) N ON DATE(M.joindate) = N.LastDate

OR

SELECT `firstname`, `surname`
FROM Members AS M
WHERE DATE(M.joindate) = (
    SELECT MAX(DATE(`joindate`)) AS LastDate
	FROM Members
	)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT F.name, M.name
FROM Bookings B
INNER JOIN(
    SELECT facid, name
    FROM Facilities
    ) F ON B.facid = F.facid
INNER JOIN(
    SELECT memid, CONCAT(firstname, ' ', surname) AS name
    FROM Members
    ) M ON B.memid = M.memid
WHERE F.name LIKE '%tennis%' 
AND F.name LIKE '%court%'
ORDER BY M.name, F.name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT F.name AS facility, CONCAT(M.firstname, ' ', M.surname) AS name,
	CASE 
		WHEN B.memid = 0 THEN F.guestcost
		WHEN B.memid != 0 THEN F.membercost
	END AS cost
FROM Bookings B
INNER JOIN Facilities F ON B.facid = F.facid
INNER JOIN Members M ON B.memid = M.memid
WHERE DATE(B.starttime) = '2012-09-14'
HAVING cost > 30
ORDER BY 3 DESC


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT F.name AS facility, M.name AS name, 
  	CASE 
		WHEN B.memid =0	THEN F.guestcost
		WHEN B.memid !=0 THEN F.membercost
   	END AS cost
FROM Bookings B
INNER JOIN (
	SELECT facid, name, guestcost, membercost
	FROM Facilities
	) F ON B.facid = F.facid
INNER JOIN (
	SELECT memid, CONCAT( firstname,  ' ', surname ) AS name
	FROM Members
	) M ON B.memid = M.memid
WHERE DATE(B.starttime) = '2012-09-14'
HAVING cost > 30
ORDER BY 3 DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


SELECT F.name, ((F.guestcost * G.guests) + (F.membercost * M.members)) AS revenue
FROM Facilities F
INNER JOIN (SELECT facid,
            (
    			CASE
    				WHEN memid = 0 THEN 'guest'
    				WHEN memid != 0 THEN 'member'
    			END) label,
			COUNT(*) as guests
			FROM Bookings
			GROUP BY 1, 2
			HAVING label = 'guest'
    		) G ON F.facid = G.facid
INNER JOIN (SELECT facid,
    		(
    			CASE
    				WHEN memid = 0 THEN 'guest'
    				WHEN memid != 0 THEN 'member'
    			END
            ) label,
			COUNT(*) as members
			FROM Bookings
			GROUP BY 1, 2
			HAVING label = 'member'
    		) M ON F.facid = M.facid
HAVING revenue < 1000
ORDER BY revenue