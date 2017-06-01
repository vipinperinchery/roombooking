DROP DATABASE IF EXISTS room_booking;
CREATE DATABASE room_booking;

\c room_booking;

CREATE TABLE user_status (
    user_status_id integer NOT NULL,
    user_status_name character varying(30) NOT NULL
);

CREATE TABLE booking_status (
    booking_status_id integer NOT NULL,
    booking_status_name character varying(30) NOT NULL
);

CREATE TABLE block (
    block_id integer NOT NULL,
    block_name character varying(10) NOT NULL
);

CREATE TABLE meeting_room (
    meeting_room_id integer NOT NULL,
    meeting_room_name character varying(30) NOT NULL
);

CREATE TABLE users (
    users_id INTEGER NOT NULL,
    username INTEGER NOT NULL,
    password CHARACTER VARYING(200) NOT NULL,
    email_id CHARACTER VARYING(50) NOT NULL,
    usr_status_id INTEGER NOT NULL
);

CREATE TABLE bookings (
    bookings_id INTEGER NOT NULL,
    users_id INTEGER NOT NULL,
    booked_date date NOT NULL,
    start_time CHARACTER VARYING(10) NOT NULL,
    end_time CHARACTER VARYING(10) NOT NULL,
    block_id INTEGER NOT NULL,
    meeting_room_id INTEGER NOT NULL,
    booking_status_id INTEGER NOT NULL
);


ALTER TABLE user_status ADD CONSTRAINT user_status_pk_idx PRIMARY KEY (user_status_id);
ALTER TABLE booking_status ADD CONSTRAINT booking_status_pk_idx PRIMARY KEY (booking_status_id);
ALTER TABLE block ADD CONSTRAINT block_pk_idx PRIMARY KEY (block_id);
ALTER TABLE meeting_room ADD CONSTRAINT meeting_room_pk_idx PRIMARY KEY (meeting_room_id);
ALTER TABLE users ADD CONSTRAINT users_pk_idx PRIMARY KEY (users_id);
ALTER TABLE bookings ADD CONSTRAINT bookings_pk_idx PRIMARY KEY (bookings_id);


CREATE UNIQUE INDEX users_username_idx ON users (username);


ALTER TABLE users ADD CONSTRAINT users_usr_status_id_fk FOREIGN KEY (usr_status_id) REFERENCES user_status(user_status_id);
ALTER TABLE bookings ADD CONSTRAINT bookings_block_id_fk FOREIGN KEY (block_id) REFERENCES block(block_id);
ALTER TABLE bookings ADD CONSTRAINT bookings_meeting_room_id_fk FOREIGN KEY (meeting_room_id) REFERENCES meeting_room(meeting_room_id);
ALTER TABLE bookings ADD CONSTRAINT bookings_booking_status_id_fk FOREIGN KEY (booking_status_id) REFERENCES booking_status(booking_status_id);


CREATE SEQUENCE user_status_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1
  CYCLE;

CREATE OR REPLACE FUNCTION user_status_bi_pk_tr_func()
  RETURNS trigger AS
  $BODY$
  BEGIN
  NEW.user_status_id := nextval('user_status_seq');
  return NEW;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER user_status_bi_pk_tr
  BEFORE INSERT
  ON user_status
  FOR EACH ROW
  EXECUTE PROCEDURE user_status_bi_pk_tr_func();

CREATE SEQUENCE booking_status_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1
  CYCLE;

CREATE OR REPLACE FUNCTION booking_status_bi_pk_tr_func()
  RETURNS trigger AS
  $BODY$
  BEGIN
  NEW.booking_status_id := nextval('booking_status_seq');
  return NEW;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;  

CREATE TRIGGER booking_status_bi_pk_tr
  BEFORE INSERT
  ON booking_status
  FOR EACH ROW
  EXECUTE PROCEDURE booking_status_bi_pk_tr_func();

CREATE SEQUENCE block_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1
  CYCLE;

CREATE OR REPLACE FUNCTION block_bi_pk_tr_func()
  RETURNS trigger AS
  $BODY$
  BEGIN
  NEW.block_id := nextval('block_seq');
  return NEW;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
    
CREATE TRIGGER block_bi_pk_tr
  BEFORE INSERT
  ON block
  FOR EACH ROW
  EXECUTE PROCEDURE block_bi_pk_tr_func();

CREATE SEQUENCE meeting_room_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1
  CYCLE;

   
CREATE OR REPLACE FUNCTION meeting_room_bi_pk_tr_func()
  RETURNS trigger AS
  $BODY$
  BEGIN
  NEW.meeting_room_id := nextval('meeting_room_seq');
  return NEW;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER meeting_room_bi_pk_tr
  BEFORE INSERT
  ON meeting_room
  FOR EACH ROW
  EXECUTE PROCEDURE meeting_room_bi_pk_tr_func();

CREATE SEQUENCE users_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1
  CYCLE;

CREATE OR REPLACE FUNCTION users_bi_pk_tr_func()
  RETURNS trigger AS
  $BODY$
  BEGIN
  NEW.users_id := nextval('users_seq');
  return NEW;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE TRIGGER users_bi_pk_tr
  BEFORE INSERT
  ON users
  FOR EACH ROW
  EXECUTE PROCEDURE users_bi_pk_tr_func();

CREATE SEQUENCE bookings_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1
  CYCLE;

CREATE OR REPLACE FUNCTION bookings_bi_pk_tr_func()
  RETURNS trigger AS
  $BODY$
  BEGIN
  NEW.bookings_id := nextval('bookings_seq');
  return NEW;
  END;
  $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
        
CREATE TRIGGER bookings_bi_pk_tr
  BEFORE INSERT
  ON bookings
  FOR EACH ROW
  EXECUTE PROCEDURE bookings_bi_pk_tr_func();



CREATE OR REPLACE FUNCTION crypt(text, text)
  RETURNS text AS
'$libdir/pgcrypto', 'pg_crypt'
  LANGUAGE c IMMUTABLE STRICT
  COST 1;


CREATE OR REPLACE FUNCTION gen_salt(text, integer)
  RETURNS text AS
'$libdir/pgcrypto', 'pg_gen_salt_rounds'
  LANGUAGE c VOLATILE STRICT
  COST 1;


CREATE OR REPLACE FUNCTION check_user_login(IN p_username INTEGER,
		                                    IN p_password CHARACTER VARYING,
		                                    OUT o_users_id INTEGER,
		                                    OUT s_status INTEGER, 
		                                    OUT e_error_msg CHARACTER VARYING
                                            )
RETURNS  record AS
$BODY$
DECLARE
      v_usr_status_id         INTEGER;
      v_user_status_id_master  INTEGER;
BEGIN

        s_status          := -100;
        e_error_msg       := 'Initialize Message';

	  SELECT u.users_id,u.usr_status_id
        INTO o_users_id, v_usr_status_id
        FROM users u
       WHERE u.username=p_username
         AND u.password=crypt(p_password,u.password);

      SELECT us.user_status_id
        INTO v_user_status_id_master
        FROM user_status us
       WHERE us.user_status_name='Active';

	IF o_users_id IS NULL THEN
		s_status          := -1;
		e_error_msg       := 'Wrong credentials';
    ELSIF v_usr_status_id!= v_user_status_id_master THEN
		s_status          := 2;
		e_error_msg       := 'user account is not active';
    ELSE
	    s_status          := 1;
	    e_error_msg       := 'Authentication is succesfull';
    END IF;

EXCEPTION
WHEN OTHERS THEN
        s_status        := -99;
        e_error_msg     := 'Exception in  check_user_login - '||SQLERRM||' SQLSTATE:  '||SQLSTATE;           
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
COST 100;


CREATE OR REPLACE FUNCTION get_booking_history(IN p_user_id INTEGER,
                                               OUT o_bookings_id INTEGER,
                                               OUT o_users_id INTEGER,
                                               OUT o_booked_date DATE ,
                                               OUT o_start_time CHARACTER VARYING,
                                               OUT o_end_time CHARACTER VARYING,
                                               OUT o_block_name CHARACTER VARYING,
                                               OUT o_meeting_room_name CHARACTER VARYING,
                                               OUT o_booking_status_name CHARACTER VARYING,
                                               OUT s_status SMALLINT,
                                               OUT e_error_msg CHARACTER VARYING
                                              )
RETURNS  SETOF RECORD AS
$BODY$
DECLARE
        r           RECORD;
BEGIN

        s_status     := 1;
        e_error_msg  := 'No error';

                FOR r IN(SELECT b.bookings_id,b.users_id,b.booked_date,b.start_time,b.end_time,bl.block_name,mr.meeting_room_name,bs.booking_status_name
                           FROM bookings b
                           JOIN booking_status bs
                             ON b.booking_status_id=bs.booking_status_id
                           JOIN meeting_room mr
                             ON mr.meeting_room_id=b.meeting_room_id
                           JOIN block bl
                             ON bl.block_id=b.block_id
                           JOIN users u
                             ON u.users_id=b.users_id
                          WHERE u.username=p_user_id
                       ORDER BY b.booked_date DESC
                        )
                    LOOP
 
                o_bookings_id          := r.bookings_id;
                o_users_id             := r.users_id;
                o_booked_date          := r.booked_date;
                o_start_time           := r.start_time;
                o_end_time             := r.end_time;
                o_block_name           := r.block_name;
                o_meeting_room_name    := r.meeting_room_name;
                o_booking_status_name  := r.booking_status_name;

                RETURN NEXT;
      END LOOP;

EXCEPTION
WHEN OTHERS THEN
        s_status    := -99;
        e_error_msg := 'Exception from get_booking_history : '||SQLERRM||' SQLSTATE: '||SQLSTATE;
        RETURN NEXT;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
COST 100;



CREATE OR REPLACE FUNCTION create_user(IN p_username INTEGER,
		                               IN p_password CHARACTER VARYING,
                                       IN p_email_id CHARACTER VARYING,
		                               OUT s_status INTEGER, 
		                               OUT e_error_msg CHARACTER VARYING
                                      )
RETURNS  record AS
$BODY$
DECLARE
      v_users_id         INTEGER;
      v_user_status_id   INTEGER;
      v_password         CHARACTER VARYING;
BEGIN

        s_status          := -100;
        e_error_msg       := 'Initialize Message';

	  SELECT u.users_id
        INTO v_users_id
        FROM users u
       WHERE u.username=p_username;

      SELECT us.user_status_id
        INTO v_user_status_id
        FROM user_status us
       WHERE us.user_status_name='Active';

	IF v_users_id IS NOT NULL THEN
		s_status          := -1;
		e_error_msg       := 'Username already exists';
    ELSE
       v_password = crypt(p_password,gen_salt('bf',8));

       INSERT INTO users (username,password,email_id,usr_status_id)
                VALUES(p_username,v_password,p_email_id,v_user_status_id);

	    s_status          := 1;
	    e_error_msg       := 'User is created successfully';
    END IF;

EXCEPTION
WHEN OTHERS THEN
        s_status        := -99;
        e_error_msg     := 'Exception in  create_user - '||SQLERRM||' SQLSTATE:  '||SQLSTATE;           
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
COST 100;


CREATE OR REPLACE FUNCTION get_active_bookings(IN p_user_id INTEGER,
                                               OUT o_bookings_id INTEGER,
                                               OUT o_users_id INTEGER,
                                               OUT o_booked_date DATE ,
                                               OUT o_start_time CHARACTER VARYING,
                                               OUT o_end_time CHARACTER VARYING,
                                               OUT o_block_name CHARACTER VARYING,
                                               OUT o_meeting_room_name CHARACTER VARYING,
                                               OUT o_booking_status_name CHARACTER VARYING,
                                               OUT s_status SMALLINT,
                                               OUT e_error_msg CHARACTER VARYING
                                              )
RETURNS  SETOF RECORD AS
$BODY$
DECLARE
        r           RECORD;
BEGIN

        s_status     := 1;
        e_error_msg  := 'No error';

                FOR r IN(SELECT b.bookings_id,b.users_id,b.booked_date,b.start_time,b.end_time,bl.block_name,mr.meeting_room_name,bs.booking_status_name
                           FROM bookings b
                           JOIN booking_status bs
                             ON b.booking_status_id=bs.booking_status_id
                           JOIN meeting_room mr
                             ON mr.meeting_room_id=b.meeting_room_id
                           JOIN block bl
                             ON bl.block_id=b.block_id
                           JOIN users u
                             ON u.users_id=b.users_id
                          WHERE u.username=p_user_id
                            AND bs.booking_status_name='Active'
                       ORDER BY b.booked_date DESC
                        )
                    LOOP
 
                o_bookings_id          := r.bookings_id;
                o_users_id             := r.users_id;
                o_booked_date          := r.booked_date;
                o_start_time           := r.start_time;
                o_end_time             := r.end_time;
                o_block_name           := r.block_name;
                o_meeting_room_name    := r.meeting_room_name;
                o_booking_status_name  := r.booking_status_name;

                RETURN NEXT;
      END LOOP;

EXCEPTION
WHEN OTHERS THEN
        s_status    := -99;
        e_error_msg := 'Exception from get_active_bookings : '||SQLERRM||' SQLSTATE: '||SQLSTATE;
        RETURN NEXT;
END;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER
COST 100;


INSERT INTO user_status VALUES (1,'Active');
INSERT INTO user_status VALUES (2,'Inactive');

INSERT INTO booking_status VALUES (1,'Active');
INSERT INTO booking_status VALUES (2,'Cancelled');
INSERT INTO booking_status VALUES (3,'In Progress');

INSERT INTO block VALUES (1,'A');
INSERT INTO block VALUES (2,'B');

INSERT INTO meeting_room VALUES (1,'Floor4/Odc1/Room1');
INSERT INTO meeting_room VALUES (2,'Floor4/Common/Room1');

INSERT INTO users VALUES (1,683649,'temporary','vipin.perinchery@tcs.com',1);
INSERT INTO users VALUES (2,683650,'temporary','rijo.charles@tcs.com',1);
INSERT INTO users VALUES (3,683651,'temporary','rachel.sebastian@tcs.com',1);
INSERT INTO users VALUES (4,683652,'temporary','maya.unknown@tcs.com',1);

SELECT * FROM create_user(683600,'Password@123','sailesh.ms@tcs.com');


INSERT INTO bookings VALUES (1,1,'4/11/2017','9AM','10AM',1,1,1);
INSERT INTO bookings VALUES (2,1,'4/07/2017','9AM','10AM',1,1,1);
INSERT INTO bookings VALUES (3,1,'4/07/2017','9AM','10AM',1,1,2);
INSERT INTO bookings VALUES (4,2,'4/10/2017','9AM','10AM',1,1,1);