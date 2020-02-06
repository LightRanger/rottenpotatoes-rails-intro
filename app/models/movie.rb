class Movie < ActiveRecord::Base
    def self.ratings
        r = ['G', 'PG', 'PG-13', 'R']
        return r
    end
    def self.with_ratings ratings
        where(rating: ratings)
    end
end
