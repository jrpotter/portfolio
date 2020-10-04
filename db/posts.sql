INSERT OR REPLACE INTO Post
( 'id'
, 'title'
, 'description'
, 'created_at'
, 'updated_at'
, 'slug'
) VALUES
( (SELECT id FROM Post WHERE slug = 'spot-it')
, 'Spotting It'
, '<a href="https://en.wikipedia.org/wiki/Dobble" target="_blank">Spot it!</a>
is a party game consisting of 55 cards, each with a variety of different
symbols, consisting of just a single matching symbol between any pair. The goal
of the game (across the various game modes described by the "Spot it!"
development team) is to find the matching symbol as quickly as possible. Here we
briefly explore how the math behind this works and how we can build a
rudimentary computer vision solution to determine the matches automatically.'
, (SELECT created_at FROM Post WHERE slug = 'spot-it')
, DATETIME('now')
, 'spot-it'
);
