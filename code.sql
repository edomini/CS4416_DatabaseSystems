-- Task 3: Create a View 

CREATE VIEW concert_stats AS
SELECT a.artist_id, -- Gets artistID
       a.artist_name, -- Gets artist name
       
       SUM( -- Sums all artists' time at concerts together
              (SELECT ROUND(SUM(s.length), 2) -- Calculates the time an artist played for at a concert
               FROM songs s
               JOIN concert_to_songs cts ON s.song_id = cts.song_id -- Join used to find which songs have been played at a concert
               JOIN artist_to_song ats ON s.song_id = ats.song_id -- Finds which artist played each of these songs
               WHERE cts.concert_id = atc.concert_id -- Matches to the current concert 
                 AND ats.artist_id = a.artist_id ) -- Checks the current artist
       ) AS total_time_played_for,
       
       SUM( -- Sums all the revenue each artist made at a concert
              (SELECT ROUND(SUM(DISTINCT ct.ticket_price) / (SELECT COUNT(DISTINCT atc2.artist_id) -- Divides the revenue evenly between each artist
                                                             FROM artist_to_concert atc2
                                                             WHERE atc2.concert_id = atc.concert_id), 2)
               FROM concert_tickets ct
               WHERE atc.concert_id = ct.concert_id ) -- Gets the tickets of the concert
       ) AS total_revenue_made

FROM artists a
JOIN artist_to_concert atc ON a.artist_id = atc.artist_id -- Join artists to their concerts
GROUP BY a.artist_id, a.artist_name -- Separates the values by the artist
HAVING total_time_played_for > 7; -- Only includes artists that have significant playtime

DELIMITER //

-- Task 4: Before and After Triggers

CREATE TRIGGER CheckAge -- checks age before inserting data, throws error is under 16
BEFORE INSERT ON fans
FOR EACH ROW
BEGIN
    -- check if age of new fan is under 16
    IF NEW.age < 16 
    THEN 
        -- throw ERROR and do not add data
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TRIGGER: Age below 16.';
    END IF;
END//

CREATE TRIGGER DeleteTicket -- deletes all ticket data after ticket deletion
AFTER DELETE ON concert_tickets
FOR EACH ROW
BEGIN
    -- delete entries in ticket_to_fan for matching ticket_id
    DELETE FROM ticket_to_fan
    WHERE ticket_id = OLD.ticket_id;
END//

-- Task 5: Stored function

CREATE FUNCTION calculate_occupied_seats (input_concert_id INT) -- Creates Function
RETURNS INT -- Function gives back an integer
NOT DETERMINISTIC -- Makes the function able to change based on data in the database
BEGIN
    DECLARE total_seats INT DEFAULT	0; -- Initalise local variable to 0

    -- Calculate the number of seats associated with all tickets for the given concert
    SELECT COUNT(tf.seat_number) -- Counts the number of seats in ticket_to_fan
    INTO total_seats -- stores in local variable total_seats
    FROM concert_tickets AS ct JOIN ticket_to_fan AS tf ON ct.ticket_id = sa.ticket_id -- Joins concert_tickets and ticket_to_fan for the corresponding ticket_id
    WHERE ct.concert_id = input_concert_id; -- where the inputted concert_id is equal to the concert_id in concert_tickets

    RETURN total_seats; -- Return the total seat count
END//

-- Task 6: Procedure

CREATE PROCEDURE AddSongAlbumAssoc(IN this_song_id INTEGER(10), IN this_album_id INTEGER(10))
BEGIN
    -- create variables
	DECLARE assocExists INTEGER;
    DECLARE song_release_date DATE;
    DECLARE album_release_date DATE;
    
    -- check if the association already exists
    SELECT COUNT(*) INTO assocExists
    FROM song_to_album
    WHERE song_id = this_song_id AND album_id = this_album_id;
    
    -- if it doesn't exist, then assocExists = 0
    IF assocExists = 0 THEN
        -- create the association
        INSERT INTO song_to_album(song_id, album_id)
        VALUES(this_song_id, this_album_id);
        
        -- get the song's release date
        SELECT release_date INTO song_release_date
        FROM songs
        WHERE song_id = this_song_id;
        
        -- get the album's release date
        SELECT release_date INTO album_release_date
        FROM albums
        WHERE album_id = this_album_id;
        
        -- if the song was released after the album, 
        -- set the song's release date to the album's release date
        IF song_release_date > album_release_date
        THEN UPDATE songs
        	SET release_date = album_release_date
            WHERE song_id = this_song_id;
        END IF;
	END IF;
END//

