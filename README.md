# CS4416 Database Systems
Consider the relational database schema in concerts_schema.sql.

This is the schema of a relational database that contains data about artists (incl. bands), their songs,
albums and concerts. It also contains data about fans and tickets they have purchased for concerts.

Assume that a song_id identifies a particular recording/version of a song. Note that the same artists
may record the same song multiple times, and each recording would have a different song_id. Note
also that the same song_id may appear on multiple albums.
## Task 1
Propose a modified schema to eliminate data redundancy and support:
- multiple artists per album, song, and concert
- multiple favourite artists per fan
- shared tickets, i.e. multiple fans per ticket_id

In a separate file named data.sql, provide INSERT INTO statements for inserting some data into
the tables of the modified schema. Please provide data for at least two artists, at least two
albums, at least 2 concerts ad at least 2 fans who have purchased tickets for concerts.
## Task 2
Draw an entity-relationship diagram (ERD) for the modified schema using crow’s foot notation.
## Task 3
Create a view for the modified schema. The view must use a join and both GROUP BY and
HAVING clauses. Aim at demonstrating advanced SQL skills.
## Task 4
Write one BEFORE and one AFTER trigger for the modified schema.
## Task 5
Write a stored function that returns the total number of occupied seats for a given concert_id.
## Task 6
Write a stored procedure that checks whether a given song_id is associated with a given
album_id. If not, insert this association into the database. Additionally, adjust the song’s release
date if it is later than the album’s.
