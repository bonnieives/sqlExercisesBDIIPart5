---- Connecting sys as sysdba
connect sys/sys as sysdba;

-- Setting the spool file
SPOOL C:\BD2\project_part5_spool.txt

-- Showing the actual time when the script was run
SELECT to_char(sysdate,'DD Month YYYY Day HH:MI"SS') FROM dual;


-- QUESTION 1

-- Dropping the schema to restart anytime the script is run
DROP USER des03 CASCADE;

-- Running the script for Northwoods
@C:\BD1\7Northwoods.sql

-- Setting for printing
SET SERVEROUTPUT ON

-- Starting now

CREATE OR REPLACE PROCEDURE p5q1 AS
	
	CURSOR term_cursor IS
		SELECT term_id, term_desc, status
		FROM term;

		v_termid term.term_id%TYPE;
		v_termdesc term.term_desc%TYPE;
		v_status term.status%TYPE;

	BEGIN

		OPEN term_cursor;

		FETCH term_cursor INTO v_termid, v_termdesc, v_status;

		WHILE term_cursor%FOUND LOOP

		DBMS_OUTPUT.PUT_LINE('Term ID: ' || v_termid || '. Term description: ' || v_termdesc || '. Status: ' || v_status || '.');
		
		FETCH term_cursor INTO v_termid, v_termdesc, v_status;
		END LOOP;

	CLOSE term_cursor;
	
	END;
/

-- Excecuting the procedure
EXEC p5q1
	

-- QUESTION 2

-- Connecting sys as sysdba again
connect sys/sys as sysdba;

-- Dropping the user from script Clearwater
DROP USER des02 CASCADE;

-- Running the script Clearwater
@C:\BD1\7clearwater.sql

-- Once more, setting for printing
SET SERVEROUTPUT ON

-- Starting the question

CREATE OR REPLACE PROCEDURE p5q2 AS
	
	CURSOR inventory_cursor IS
		SELECT item_desc, inv_price, color, inv_qoh
		FROM item i, inventory iv
		WHERE i.item_id = iv.item_id;

		v_itemdesc item.item_desc%TYPE;
		v_invprice inventory.inv_price%TYPE;
		v_color inventory.color%TYPE;
		v_invqoh inventory.inv_qoh%TYPE;

	BEGIN

		OPEN inventory_cursor;

		FETCH inventory_cursor INTO v_itemdesc, v_invprice, v_color, v_invqoh;

		WHILE inventory_cursor%FOUND LOOP

		DBMS_OUTPUT.PUT_LINE('Item Description: ' || v_itemdesc || '. Inventory price: ' || v_invprice || 
		'. Color: ' || v_color || '. Quantity on hand: ' || v_invqoh || '.');
		
		FETCH inventory_cursor INTO v_itemdesc, v_invprice, v_color, v_invqoh;
		END LOOP;

	CLOSE inventory_cursor;
	
	END;
/

-- Executing the procedure
EXEC p5q2

-- QUESTION 3

CREATE OR REPLACE PROCEDURE p5q3 (in_perc NUMBER) AS 
	
	CURSOR update_cursor IS
		SELECT item_desc, inv_price
		FROM item i, inventory iv
		WHERE i.item_id = iv.item_id;

		v_itemdesc item.item_desc%TYPE;
		v_invprice inventory.inv_price%TYPE;
		v_itemid inventory.item_id%TYPE;
		v_newprice NUMBER;
		v_perc NUMBER;

	BEGIN
		v_perc := in_perc;

		OPEN update_cursor;

		FETCH update_cursor INTO v_itemdesc, v_invprice;

		WHILE update_cursor%FOUND LOOP

		v_newprice := v_invprice*(1 + v_perc/100);
	
		UPDATE inventory SET inv_price = v_newprice WHERE item_id = v_itemid;

		DBMS_OUTPUT.PUT_LINE('Description: ' || v_itemdesc || '. Old price: ' || v_invprice || 
		'. New price: ' || v_newprice || '. Raised: ' || v_perc || '%.');
		
		FETCH update_cursor INTO v_itemdesc, v_invprice;
		END LOOP;

	CLOSE update_cursor;
	
	END;
/

-- Executing the procedure
EXEC p5q3(30)
EXEC p5q3(100)
EXEC p5q3(-50)


-- QUESTION 4

-- Connecting sys as sysdba again
connect sys/sys as sysdba;

-- Running Scott schema
@C:\BD2\scott_emp_dept.sql

-- Once more, setting for printing
SET SERVEROUTPUT ON

-- Starting the procedure

CREATE OR REPLACE PROCEDURE p5q4 (num_emp NUMBER) AS

	CURSOR emp_cursor IS
		SELECT empno
		FROM emp
		ORDER BY sal DESC;

		v_ename emp.ename%TYPE;
		v_sal emp.sal%TYPE;
		v_numemp NUMBER;
		v_counter NUMBER := 0;
		v_empno emp.empno%TYPE;

	BEGIN
		
		DBMS_OUTPUT.PUT_LINE('Top: ' || num_emp || ' salaries,');


		OPEN emp_cursor;
		v_numemp := num_emp;
	
		FETCH emp_cursor INTO v_empno;

		LOOP
			
			SELECT ename, sal
			INTO v_ename, v_sal
			FROM emp
			WHERE v_empno = empno;
	

			DBMS_OUTPUT.PUT_LINE('Employee name: ' || v_ename || '. Employee salary: $' || v_sal || '.');
			
			v_counter := v_counter + 1;
	
		EXIT WHEN v_counter >= num_emp ;

		FETCH emp_cursor INTO v_empno;

		END LOOP;
	END;
/

EXEC p5q4(3)
EXEC p5q4(5)
EXEC p5q4(9)

-- QUESTION 5

CREATE OR REPLACE PROCEDURE p5q5 (num_emp NUMBER) AS

	-- Starting declaring the cursor

		CURSOR cursor_topemp IS
			SELECT empno, ename, sal
			FROM emp
			ORDER BY sal DESC;

		v_ename emp.ename%TYPE;
		v_sal emp.sal%TYPE;
		v_topsal emp.sal%TYPE;
		v_empno emp.empno%TYPE;
		v_numemp NUMBER;
		v_saltemp NUMBER;
		v_counter NUMBER := 1;

		BEGIN

	-- Loop for store the nth max salary into a temporary variable

		SELECT MAX(sal)
		INTO v_saltemp
		FROM emp
		ORDER BY sal DESC;
		
		WHILE num_emp <> 1 LOOP
			SELECT MAX(sal)
			INTO v_sal
			FROM emp
			WHERE sal < v_saltemp;

			v_saltemp := v_sal;
			v_counter := v_counter + 1;
		
		EXIT WHEN v_counter >= num_emp ;

		END LOOP;

	-- Here ends the first loop

		SELECT MAX(sal)
		INTO v_topsal
		FROM emp;

	-- Opening the cursor

		OPEN cursor_topemp;

	-- First fetching on the cursor

		FETCH cursor_topemp INTO v_empno, v_ename, v_sal;

	-- Starting a loop

	DBMS_OUTPUT.PUT_LINE('Top ' || num_emp || ' salaries and the employees.');


	WHILE cursor_topemp%FOUND LOOP

		SELECT empno, ename, sal
		INTO v_empno, v_ename, v_sal
		FROM emp
		WHERE v_empno = empno;
		

		DBMS_OUTPUT.PUT_LINE('Employee name: ' || v_ename || '. Employee salary: $' || v_sal || '.');

	-- Final fetching on the cursor

		FETCH cursor_topemp INTO v_empno, v_ename, v_sal;
	
	EXIT WHEN v_sal < v_saltemp;

	END LOOP;	

	END;
/

exec p5q5(1)
exec p5q5(4)
exec p5q5(8)
exec p5q5(20)

SPOOL OFF;