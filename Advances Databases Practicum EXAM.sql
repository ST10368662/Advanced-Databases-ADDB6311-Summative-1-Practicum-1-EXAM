Create table EVENT
(
  EVENT_ID           number(5)        not null    primary key,
  EVENT_NAME         varchar2(100)    not null,
  EVENT_RATE        number(5)     not null
 );
 
 
Create table ARTIST
(
  ARTIST_ID            varchar2(5)    not null    primary key,
  ARTIST_NAME         varchar2(100)  not null,
  ARTIST_EMAIL        varchar2(100)  not null
  );
  
  
Create table BOOKINGS
(
  BOOKING_ID              number    not null    primary key,
  BOOKING_DATE            date           not null,
  EVENT_ID 		  number(5)	not null,
  ARTIST_ID             varchar2(5)        not null,
FOREIGN KEY (EVENT_ID) REFERENCES EVENT(EVENT_ID),
FOREIGN KEY (ARTIST_ID) REFERENCES ARTIST(ARTIST_ID)
); 


insert all
   into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1001, 'Open Air Comedy Festival', 300)
into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1002, 'Mountain Side Music Festival', 280)
into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1003, 'Beach Music Festival', 195)
  
Select * from dual;
Commit;



insert all
   into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_101', 'Max Trillion', 'maxt@isat.com')
 into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_102', 'Music Mayhem', 'mayhem@ymail.com')
into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_103', 'LOL Man', 'lol@isat.com')
       Select * from dual;
  Commit;
  
  
  
insert all
   into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(1, '15 July 2024', 1002, 'A_101')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(2, '15 July 2024', 1002, 'A_102')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(3, '27 August 2024', 1001, 'A_103')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(4, '30 August 2024', 1003, 'A_101')
into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(5, '30 August 2024', 1003, 'A_102')

      Select * from dual;
Commit;


SELECT * FROM EVENT;

SELECT * FROM ARTIST;

SELECT * FROM BOOKINGS;



--Question 1 


SELECT 
    b.BOOKING_ID, 
    b.BOOKING_DATE, 
    e.EVENT_NAME, 
    e.EVENT_RATE, 
    a.ARTIST_NAME, 
    a.ARTIST_EMAIL
FROM 
    BOOKINGS b
JOIN 
    EVENT e ON b.EVENT_ID = e.EVENT_ID
JOIN 
    ARTIST a ON b.ARTIST_ID = a.ARTIST_ID
ORDER BY 
    b.BOOKING_ID;



--Question 2



SELECT 
    a.ARTIST_NAME, 
    COUNT(b.BOOKING_ID) AS performance_count
FROM 
    ARTIST a
LEFT JOIN 
    BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
GROUP BY 
    a.ARTIST_NAME
HAVING 
    COUNT(b.BOOKING_ID) = (
        SELECT MIN(performance_count)
        FROM (
            SELECT COUNT(b2.BOOKING_ID) AS performance_count
            FROM ARTIST a2
            LEFT JOIN BOOKINGS b2 ON a2.ARTIST_ID = b2.ARTIST_ID
            GROUP BY a2.ARTIST_NAME
        )
    )
ORDER BY 
    a.ARTIST_NAME;


--Question 3


SELECT 
    a.ARTIST_NAME, 
    NVL(SUM(e.EVENT_RATE), 0) AS total_revenue
FROM 
    ARTIST a
LEFT JOIN 
    BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
LEFT JOIN 
    EVENT e ON b.EVENT_ID = e.EVENT_ID
GROUP BY 
    a.ARTIST_NAME
ORDER BY 
    total_revenue DESC;





--Question 4

SET SERVEROUTPUT ON;

DECLARE
    CURSOR artist_cursor IS
        SELECT a.ARTIST_NAME, b.BOOKING_DATE
        FROM ARTIST a
        JOIN BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
        WHERE b.EVENT_ID = 1001;
    
    v_artist_name ARTIST.ARTIST_NAME%TYPE;
    v_booking_date BOOKINGS.BOOKING_DATE%TYPE;
BEGIN
    OPEN artist_cursor;
    LOOP
        FETCH artist_cursor INTO v_artist_name, v_booking_date;
        EXIT WHEN artist_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Artist: ' || v_artist_name || 
                            ', Booking Date: ' || TO_CHAR(v_booking_date, 'DD-MON-YYYY'));
    END LOOP;
    CLOSE artist_cursor;
END;
/




--Question 5



DECLARE
    CURSOR event_cursor IS
        SELECT EVENT_NAME, EVENT_RATE
        FROM EVENT;
    
    v_event_name EVENT.EVENT_NAME%TYPE;
    v_event_rate EVENT.EVENT_RATE%TYPE;
    v_discounted_rate NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    DBMS_OUTPUT.PUT_LINE('Event Name               Price');
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    
    OPEN event_cursor;
    LOOP
        FETCH event_cursor INTO v_event_name, v_event_rate;
        EXIT WHEN event_cursor%NOTFOUND;
        
        IF v_event_rate > 250 THEN
            v_discounted_rate := v_event_rate * 0.9;
            DBMS_OUTPUT.PUT_LINE(RPAD(v_event_name, 25) || 'R' || 
                                TO_CHAR(v_discounted_rate, '999.99') || ' (Discounted from R' || 
                                TO_CHAR(v_event_rate, '999.99') || ')');
        ELSE
            DBMS_OUTPUT.PUT_LINE(RPAD(v_event_name, 25) || 'R' || 
                                TO_CHAR(v_event_rate, '999.99'));
        END IF;
    END LOOP;
    CLOSE event_cursor;
    
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
END;
/



--Question 6


CREATE OR REPLACE VIEW Event_Schedules AS
SELECT 
    e.EVENT_NAME
FROM 
    EVENT e
JOIN 
    BOOKINGS b ON e.EVENT_ID = b.EVENT_ID
WHERE 
    b.BOOKING_DATE BETWEEN TO_DATE('01-JUL-2024', 'DD-MON-YYYY') 
                        AND TO_DATE('28-AUG-2024', 'DD-MON-YYYY')
ORDER BY 
    b.BOOKING_DATE;



SELECT * FROM Event_Schedules
ORDER BY EVENT_NAME;




--Question 7


CREATE OR REPLACE PROCEDURE get_artist_bookings(
    p_artist_name IN ARTIST.ARTIST_NAME%TYPE
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Booking Details for ' || p_artist_name);
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    DBMS_OUTPUT.PUT_LINE('Booking ID | Booking Date  | Event Name                | Event Rate');
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
    
    FOR booking_rec IN (
        SELECT b.BOOKING_ID, b.BOOKING_DATE, e.EVENT_NAME, e.EVENT_RATE
        FROM BOOKINGS b
        JOIN EVENT e ON b.EVENT_ID = e.EVENT_ID
        JOIN ARTIST a ON b.ARTIST_ID = a.ARTIST_ID
        WHERE a.ARTIST_NAME = p_artist_name
        ORDER BY b.BOOKING_DATE
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(
            RPAD(booking_rec.BOOKING_ID, 10) || ' | ' ||
            RPAD(TO_CHAR(booking_rec.BOOKING_DATE, 'DD-MON-YYYY'), 12) || ' | ' ||
            RPAD(booking_rec.EVENT_NAME, 25) || ' | ' ||
            'R' || booking_rec.EVENT_RATE
        );
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('----------------------------------');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No bookings found for artist: ' || p_artist_name);
END;
/

-- Execution Code:
BEGIN
    get_artist_bookings('Max Trillion');
END;
/



--Question 8



CREATE OR REPLACE FUNCTION calculate_artist_revenue(
    p_artist_id IN ARTIST.ARTIST_ID%TYPE
) RETURN NUMBER
IS
    v_total_revenue NUMBER := 0;
    v_artist_exists NUMBER;
BEGIN
    -- Check if artist exists
    SELECT COUNT(*) INTO v_artist_exists
    FROM ARTIST
    WHERE ARTIST_ID = p_artist_id;
    
    IF v_artist_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Artist ID ' || p_artist_id || ' does not exist');
    END IF;
    
    -- Calculate total revenue
    SELECT NVL(SUM(e.EVENT_RATE), 0) INTO v_total_revenue
    FROM BOOKINGS b
    JOIN EVENT e ON b.EVENT_ID = e.EVENT_ID
    WHERE b.ARTIST_ID = p_artist_id;
    
    RETURN v_total_revenue;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculating revenue: ' || SQLERRM);
        RETURN NULL;
END;
/

-- Execution Code with Exception Handling:
DECLARE
    v_revenue NUMBER;
BEGIN
    v_revenue := calculate_artist_revenue('A_101');
    IF v_revenue IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Total revenue for artist A_101: R' || v_revenue);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/





--Question 11

SELECT owner, table_name 
FROM all_tables 
WHERE table_name = 'BOOKINGS';


CREATE OR REPLACE TRIGGER trg_prevent_weekend_booking
    BEFORE INSERT OR UPDATE ON BOOKINGS
    FOR EACH ROW
DECLARE
    v_day_number NUMBER;
    v_day_name VARCHAR2(10);
BEGIN
    -- Get day of week as number (1=Sunday, 2=Monday, ..., 7=Saturday)
    v_day_number := TO_NUMBER(TO_CHAR(:NEW.BOOKING_DATE, 'D'));
    
    -- Get day name for error message
    v_day_name := TRIM(TO_CHAR(:NEW.BOOKING_DATE, 'DAY'));
    
    -- Check if booking is on weekend (Sunday=1 or Saturday=7)
    IF v_day_number = 1 OR v_day_number = 7 THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'ERROR: Bookings cannot be made on weekends (' || v_day_name || '). ' ||
            'Please choose a weekday (Monday-Friday).');
    END IF;
END;
/

-- Saturday test (should fail)
INSERT INTO BOOKINGS VALUES (6, DATE '2024-08-03', 1001, 'A_103');

-- Monday test (should work)
INSERT INTO BOOKINGS VALUES (6, DATE '2024-08-05', 1001, 'A_103');


























