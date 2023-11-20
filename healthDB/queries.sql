SELECT c.ssn, b.id FROM customer_table c
INNER JOIN pays p ON c.ssn = p.c_ssn
INNER JOIN bill_view b ON p.b_id = b.id
WHERE ((b.still_due > 0) AND (b.date+days_to_pay < CURRENT_DATE));


SELECT h.id AS "Hospital ID", h.name AS "Hospital name", 
COUNT(DISTINCT i.id) AS "Number of plans" 
FROM hospital h, covers c, insurance_plan i
WHERE h.ID = c.h_id
AND c.plan_identifier=i.identifier2
GROUP BY h.id
ORDER BY "Number of plans" DESC, "Hospital name";


SELECT c.ssn AS "Customer SSN",c.first_name||' '||c.last_name AS "Customer full name",
COUNT(f.*)+1 AS "Number of members"
FROM customer_table c, family_member_table f
WHERE c.ssn=f.c_ssn
GROUP BY c.ssn
UNION
SELECT c2.ssn AS "Customer SSN",c2.first_name||' '||c2.last_name AS "Customer full name",
1 AS "Number of members"
FROM customer_table c2
WHERE c2.ssn NOT IN (SELECT DISTINCT c_ssn FROM family_member_table)
GROUP BY c2.ssn
ORDER BY "Number of members" DESC;



SELECT c.ssn AS "Customer SSN",c.first_name||' '||c.last_name AS "Customer full name",
COALESCE(ROUND(AVG(t.price),1),0) AS "Average cost on tests", 
COALESCE(ROUND(AVG(o.price),1),0) AS "Average cost on operations"
FROM customer c 
LEFT JOIN tests t ON c.ssn=t.c_ssn
LEFT JOIN operates_on o ON c.ssn=o.c_ssn
GROUP BY "Customer SSN", "Customer full name"
ORDER BY c.ssn;



SELECT c.ssn AS "Customer SSN",c.first_name||' '||c.last_name AS "Customer full name",
COALESCE(ROUND(AVG(t.price),1),0) + COALESCE(ROUND(AVG(o.price),1),0) 
AS "Total cost of customer"
FROM customer c 
LEFT JOIN tests t ON c.ssn=t.c_ssn
LEFT JOIN operates_on o ON c.ssn=o.c_ssn
GROUP BY "Customer SSN", "Customer full name"
ORDER BY "Total cost of customer" DESC LIMIT 5;




SELECT c.ssn AS "Customer SSN",c.first_name||' '||c.last_name AS "Customer full name",
COALESCE(SUM(p.amount_paid), 0) AS "Total amount paid"
FROM customer_table c
LEFT JOIN pays p ON c.ssn = p.c_ssn
GROUP BY "Customer SSN", "Customer full name"
ORDER BY "Total amount paid" DESC LIMIT 5;



SELECT c.ssn AS "Customer SSN",c.first_name||' '||c.last_name AS "Customer full name"
FROM customer_table c
WHERE c.ssn NOT IN (SELECT DISTINCT c_ssn FROM insures_table)
OR c.ssn NOT IN (
    SELECT c_ssn FROM insures_table i
    LEFT JOIN insurance_plan p ON i.plan_identifier = p.identifier2
    WHERE i.date_activated + p.time_limit > CURRENT_DATE
);


SELECT e.ssn AS "Employee SSN", e.first_name || ' ' || e.last_name 
AS "Employee Full Name", COUNT(DISTINCT c.ssn) AS "Number of Serviced Customers"
FROM employee_table e
LEFT JOIN customer_table c ON c.e_ssn=e.ssn
WHERE e.d_name='Customer Service'
GROUP BY e.ssn
ORDER BY "Number of Serviced Customers";


SELECT description AS "Test description", count(*) AS "Times Performed",
ROUND(AVG(price),1) AS "Average Test Price"
FROM tests
GROUP BY description
ORDER BY "Times Performed" DESC;


SELECT d.phone AS "Doctor phone nb", d.first_name||' '||d.last_name AS "Doctor name",
COALESCE(h.name,'N/A') AS "Hospital name", COUNT(o.*) AS "Nb of operations"
FROM doctor_table d
LEFT JOIN operates_on o ON d.phone = o.d_phone
LEFT JOIN hospital h ON o.h_id = h.id
GROUP BY "Doctor phone nb", "Doctor name", "Hospital name"
ORDER BY "Nb of operations" DESC;